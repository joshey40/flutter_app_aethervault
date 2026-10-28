import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_app_aethervault/services/app_preferences_storage.dart';
import 'package:flutter_app_aethervault/services/auth/auth_api_client.dart';
import 'package:flutter_app_aethervault/services/auth/auth_controller.dart';
import 'package:flutter_app_aethervault/services/auth/auth_token_storage.dart';

/// Records calls and answers with configurable results instead of HTTP.
class FakeAuthApiClient implements AuthApiClient {
  String token = 'token-1';
  TokenStatus status = TokenStatus.valid;
  AuthException? error;

  final calls = <String>[];
  String? lastDeviceName;
  Uri? lastServer;

  /// Holds back the next answer of a call ('status', 'logout', ...) until the
  /// completer is completed, to simulate slow requests.
  final gates = <String, Completer<void>>{};

  Future<T> _answer<T>(String call, Uri server, T result) async {
    calls.add(call);
    lastServer = server;
    final gate = gates.remove(call.split(' ').first);
    if (gate != null) {
      await gate.future;
    }
    final error = this.error;
    if (error != null) {
      throw error;
    }
    return result;
  }

  @override
  Future<String> register(Uri server, String u, String p, String device) {
    lastDeviceName = device;
    return _answer('register $u $p', server, token);
  }

  @override
  Future<String> login(Uri server, String u, String p, String device) {
    lastDeviceName = device;
    return _answer('login $u $p', server, token);
  }

  @override
  Future<void> logout(Uri server, String token) {
    return _answer('logout $token', server, null);
  }

  @override
  Future<TokenStatus> checkStatus(Uri server, String token) {
    return _answer('status $token', server, status);
  }

  @override
  void dispose() {}
}

void main() {
  late FakeAuthApiClient api;
  late AuthTokenStorage tokenStorage;
  late AppPreferencesStorage preferences;
  late AuthController controller;

  final server = Uri.parse('http://192.168.0.10:3333');
  final savedSession = AuthSession(
    token: 'saved-token',
    username: 'jace',
    server: server,
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    api = FakeAuthApiClient();
    tokenStorage = AuthTokenStorage();
    preferences = AppPreferencesStorage();
    controller = AuthController(
      apiClient: api,
      tokenStorage: tokenStorage,
      preferencesStorage: preferences,
      deviceNameLoader: () async => 'Pixel 8',
    );
  });

  Future<void> loggedIn() async {
    await preferences.saveServerUrl(server.toString());
    await tokenStorage.saveSession(savedSession);
    await controller.initialize();
  }

  group('initialize', () {
    test('starts logged out without server', () async {
      await controller.initialize();

      expect(controller.isLoggedIn, isFalse);
      expect(controller.session, isNull);
      expect(controller.serverUrl, isNull);
    });

    test('loads saved server url', () async {
      await preferences.saveServerUrl(server.toString());

      await controller.initialize();

      expect(controller.serverUrl, server);
    });

    test('loads saved session without contacting the server', () async {
      await loggedIn();

      expect(controller.isLoggedIn, isTrue);
      expect(controller.session!.username, 'jace');
      expect(api.calls, isEmpty);
    });
  });

  group('verifySession', () {
    test('ignores a late answer for a session that was replaced', () async {
      await loggedIn();
      final slowStatus = api.gates['status'] = Completer<void>();
      api.status = TokenStatus.invalid;

      final check = controller.verifySession();
      await controller.logout();
      await controller.login('liliana', 'secret');
      slowStatus.complete();
      await check;

      expect(controller.isLoggedIn, isTrue);
      expect(controller.session!.username, 'liliana');
      expect(controller.isOffline, isFalse);
      expect((await tokenStorage.loadSession())!.username, 'liliana');
    });

    test('ignores a late answer after logout', () async {
      await loggedIn();
      final slowStatus = api.gates['status'] = Completer<void>();
      api.error = const AuthException(AuthErrorType.network);

      final check = controller.verifySession();
      await controller.logout();
      slowStatus.complete();
      await check;

      expect(controller.isLoggedIn, isFalse);
      expect(controller.isOffline, isFalse);
    });

    test('does nothing when logged out', () async {
      await controller.initialize();

      await controller.verifySession();

      expect(api.calls, isEmpty);
    });

    test('keeps a valid session', () async {
      await loggedIn();

      await controller.verifySession();

      expect(api.calls, ['status saved-token']);
      expect(controller.isLoggedIn, isTrue);
      expect(controller.isOffline, isFalse);
    });

    test('logs out locally when the token is invalid', () async {
      await loggedIn();
      api.status = TokenStatus.invalid;

      await controller.verifySession();

      expect(controller.isLoggedIn, isFalse);
      expect(await tokenStorage.loadSession(), isNull);
    });

    test('stays logged in but offline when server is unreachable', () async {
      await loggedIn();
      api.error = const AuthException(AuthErrorType.network);

      await controller.verifySession();

      expect(controller.isLoggedIn, isTrue);
      expect(controller.isOffline, isTrue);
    });

    test('clears offline flag once the server answers again', () async {
      await loggedIn();
      api.error = const AuthException(AuthErrorType.network);
      await controller.verifySession();

      api.error = null;
      await controller.verifySession();

      expect(controller.isOffline, isFalse);
    });

    test('notifies listeners when the session is dropped', () async {
      await loggedIn();
      api.status = TokenStatus.invalid;
      var notified = 0;
      controller.addListener(() => notified++);

      await controller.verifySession();

      expect(notified, greaterThan(0));
    });
  });

  group('setServerUrl', () {
    test('normalizes and saves the address', () async {
      await controller.initialize();

      await controller.setServerUrl(' 192.168.0.10:3333/ ');

      expect(controller.serverUrl, server);
      expect(await preferences.loadServerUrl(), 'http://192.168.0.10:3333');
    });

    test('clears the address for empty input', () async {
      await preferences.saveServerUrl(server.toString());
      await controller.initialize();

      await controller.setServerUrl('');

      expect(controller.serverUrl, isNull);
      expect(await preferences.loadServerUrl(), isNull);
    });

    test('throws invalidServerUrl for unusable input', () async {
      await controller.initialize();

      expect(
        controller.setServerUrl('ftp://example.com'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.type,
            'type',
            AuthErrorType.invalidServerUrl,
          ),
        ),
      );
    });

    test('throws serverLocked while logged in', () async {
      await loggedIn();

      await expectLater(
        controller.setServerUrl('https://other.example.com'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.type,
            'type',
            AuthErrorType.serverLocked,
          ),
        ),
      );
    });

    test('keeps session and address when locked', () async {
      await loggedIn();

      await expectLater(
        controller.setServerUrl(''),
        throwsA(isA<AuthException>()),
      );

      expect(api.calls, isEmpty);
      expect(controller.isLoggedIn, isTrue);
      expect(controller.serverUrl, server);
      expect(await preferences.loadServerUrl(), server.toString());
    });

    test('can change the address again after logout', () async {
      await loggedIn();
      await controller.logout();

      await controller.setServerUrl('https://other.example.com');

      expect(controller.serverUrl, Uri.parse('https://other.example.com'));
    });
  });

  group('login', () {
    test('throws noServer when no server is set', () async {
      await controller.initialize();

      expect(
        controller.login('jace', 'secret'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.type,
            'type',
            AuthErrorType.noServer,
          ),
        ),
      );
    });

    test('logs in with the device name and stores the session', () async {
      await preferences.saveServerUrl(server.toString());
      await controller.initialize();

      await controller.login(' jace ', 'secret');

      expect(api.calls, ['login jace secret']);
      expect(api.lastServer, server);
      expect(api.lastDeviceName, 'Pixel 8');
      expect(controller.isLoggedIn, isTrue);
      expect(controller.session!.username, 'jace');

      final stored = await tokenStorage.loadSession();
      expect(stored!.token, 'token-1');
      expect(stored.server, server);
    });

    test('passes api errors on and stays logged out', () async {
      await preferences.saveServerUrl(server.toString());
      await controller.initialize();
      api.error = const AuthException(AuthErrorType.invalidCredentials);

      await expectLater(
        controller.login('jace', 'wrong'),
        throwsA(isA<AuthException>()),
      );
      expect(controller.isLoggedIn, isFalse);
      expect(await tokenStorage.loadSession(), isNull);
    });

    test('notifies listeners after login', () async {
      await preferences.saveServerUrl(server.toString());
      await controller.initialize();
      var notified = 0;
      controller.addListener(() => notified++);

      await controller.login('jace', 'secret');

      expect(notified, greaterThan(0));
    });
  });

  group('register', () {
    test('registers and stores the session', () async {
      await preferences.saveServerUrl(server.toString());
      await controller.initialize();

      await controller.register('liliana', 'secret');

      expect(api.calls, ['register liliana secret']);
      expect(api.lastDeviceName, 'Pixel 8');
      expect(controller.session!.username, 'liliana');
      expect((await tokenStorage.loadSession())!.username, 'liliana');
    });

    test('throws noServer when no server is set', () async {
      await controller.initialize();

      expect(
        controller.register('liliana', 'secret'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.type,
            'type',
            AuthErrorType.noServer,
          ),
        ),
      );
    });
  });

  group('logout', () {
    test('sends only one request when called twice', () async {
      await loggedIn();
      final slowLogout = api.gates['logout'] = Completer<void>();

      final first = controller.logout();
      final second = controller.logout();
      slowLogout.complete();
      await Future.wait([first, second]);

      expect(api.calls, ['logout saved-token']);
      expect(controller.isLoggedIn, isFalse);
    });

    test('reports isLoggingOut while the request runs', () async {
      await loggedIn();
      final slowLogout = api.gates['logout'] = Completer<void>();
      final states = <bool>[];
      controller.addListener(() => states.add(controller.isLoggingOut));

      final logout = controller.logout();
      expect(controller.isLoggingOut, isTrue);
      slowLogout.complete();
      await logout;

      expect(controller.isLoggingOut, isFalse);
      expect(states, [true, false]);
    });

    test('logs out on the server and clears the session', () async {
      await loggedIn();

      await controller.logout();

      expect(api.calls, ['logout saved-token']);
      expect(api.lastServer, server);
      expect(controller.isLoggedIn, isFalse);
      expect(await tokenStorage.loadSession(), isNull);
    });

    test('clears the session locally when offline', () async {
      await loggedIn();
      api.error = const AuthException(AuthErrorType.network);

      await controller.logout();

      expect(controller.isLoggedIn, isFalse);
      expect(controller.isOffline, isFalse);
      expect(await tokenStorage.loadSession(), isNull);
    });

    test('keeps the server address', () async {
      await loggedIn();

      await controller.logout();

      expect(controller.serverUrl, server);
    });
  });
}
