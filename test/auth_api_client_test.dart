import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:flutter_app_aethervault/services/auth/auth_api_client.dart';

void main() {
  final server = Uri.parse('http://192.168.0.10:3333');

  AuthApiClient clientReturning(
    int statusCode, {
    String body = '',
    void Function(http.Request request)? onRequest,
  }) {
    return AuthApiClient(
      client: MockClient((request) async {
        onRequest?.call(request);
        return http.Response(body, statusCode);
      }),
    );
  }

  Matcher authError(AuthErrorType type) {
    return throwsA(isA<AuthException>().having((e) => e.type, 'type', type));
  }

  group('register', () {
    test('sends PUT /auth/register with credentials and device', () async {
      late http.Request sent;
      final client = clientReturning(
        201,
        body: '{"authToken":"abc"}',
        onRequest: (request) => sent = request,
      );

      await client.register(server, 'jace', 'secret', 'Pixel 8');

      expect(sent.method, 'PUT');
      expect(sent.url.toString(), 'http://192.168.0.10:3333/auth/register');
      expect(sent.headers['Content-Type'], startsWith('application/json'));
      expect(jsonDecode(sent.body), {
        'username': 'jace',
        'passwd': 'secret',
        'currDevice': 'Pixel 8',
      });
    });

    test('returns the auth token on 201', () async {
      final client = clientReturning(201, body: '{"authToken":"abc"}');

      expect(await client.register(server, 'jace', 'secret', 'Pixel'), 'abc');
    });

    test('throws userAlreadyExists on 409', () async {
      final client = clientReturning(
        409,
        body: '{"status":"The user already exists"}',
      );

      expect(
        client.register(server, 'jace', 'secret', 'Pixel'),
        authError(AuthErrorType.userAlreadyExists),
      );
    });

    test('throws invalidRequest on 400', () async {
      final client = clientReturning(400, body: '{"status":"Invalid Request"}');

      expect(
        client.register(server, 'jace', 'secret', 'Pixel'),
        authError(AuthErrorType.invalidRequest),
      );
    });

    test('throws server on 500', () async {
      final client = clientReturning(500, body: '{"status":"Internal Error"}');

      expect(
        client.register(server, 'jace', 'secret', 'Pixel'),
        authError(AuthErrorType.server),
      );
    });

    test('throws server when the response has no token', () async {
      final client = clientReturning(201, body: 'not json');

      expect(
        client.register(server, 'jace', 'secret', 'Pixel'),
        authError(AuthErrorType.server),
      );
    });
  });

  group('login', () {
    test('sends POST /auth/login with credentials and device', () async {
      late http.Request sent;
      final client = clientReturning(
        201,
        body: '{"authToken":"abc"}',
        onRequest: (request) => sent = request,
      );

      await client.login(server, 'jace', 'secret', 'Pixel 8');

      expect(sent.method, 'POST');
      expect(sent.url.toString(), 'http://192.168.0.10:3333/auth/login');
      expect(jsonDecode(sent.body), {
        'username': 'jace',
        'passwd': 'secret',
        'currDevice': 'Pixel 8',
      });
    });

    test('returns the auth token on 201', () async {
      final client = clientReturning(201, body: '{"authToken":"abc"}');

      expect(await client.login(server, 'jace', 'secret', 'Pixel'), 'abc');
    });

    test('also accepts 200 in case the backend changes it', () async {
      final client = clientReturning(200, body: '{"authToken":"abc"}');

      expect(await client.login(server, 'jace', 'secret', 'Pixel'), 'abc');
    });

    test('throws invalidCredentials on 401', () async {
      final client = clientReturning(
        401,
        body: '{"status":"Username or password wrong"}',
      );

      expect(
        client.login(server, 'jace', 'wrong', 'Pixel'),
        authError(AuthErrorType.invalidCredentials),
      );
    });
  });

  group('logout', () {
    test('sends POST /auth/logout with bearer token', () async {
      late http.Request sent;
      final client = clientReturning(200, onRequest: (r) => sent = r);

      await client.logout(server, 'abc');

      expect(sent.method, 'POST');
      expect(sent.url.toString(), 'http://192.168.0.10:3333/auth/logout');
      expect(sent.headers['Authorization'], 'Bearer abc');
    });

    test('throws unauthorized on 401', () async {
      final client = clientReturning(401, body: 'Device was not found\n');

      expect(
        client.logout(server, 'abc'),
        authError(AuthErrorType.unauthorized),
      );
    });
  });

  group('checkStatus', () {
    test('sends GET /auth/status with bearer token', () async {
      late http.Request sent;
      final client = clientReturning(200, onRequest: (r) => sent = r);

      await client.checkStatus(server, 'abc');

      expect(sent.method, 'GET');
      expect(sent.url.toString(), 'http://192.168.0.10:3333/auth/status');
      expect(sent.headers['Authorization'], 'Bearer abc');
    });

    test('returns valid on 200', () async {
      final client = clientReturning(200);

      expect(await client.checkStatus(server, 'abc'), TokenStatus.valid);
    });

    test('returns invalid on 401 with a plain text body', () async {
      final client = clientReturning(401, body: 'Device was not found\n');

      expect(await client.checkStatus(server, 'abc'), TokenStatus.invalid);
    });

    test('throws server on 500', () async {
      final client = clientReturning(500);

      expect(
        client.checkStatus(server, 'abc'),
        authError(AuthErrorType.server),
      );
    });
  });

  group('isAethervaultServer', () {
    test('sends GET /alive without a token', () async {
      late http.Request sent;
      final client = clientReturning(200, onRequest: (r) => sent = r);

      await client.isAethervaultServer(server);

      expect(sent.method, 'GET');
      expect(sent.url.toString(), 'http://192.168.0.10:3333/alive');
      expect(sent.headers.containsKey('Authorization'), isFalse);
    });

    test('keeps a path prefix of the server url', () async {
      late http.Request sent;
      final client = clientReturning(200, onRequest: (r) => sent = r);

      await client.isAethervaultServer(
        Uri.parse('https://example.com/aethervault'),
      );

      expect(sent.url.toString(), 'https://example.com/aethervault/alive');
    });

    test('returns true when /alive answers 200', () async {
      final client = clientReturning(200);

      expect(await client.isAethervaultServer(server), isTrue);
    });

    test('returns false for a server without /alive', () async {
      final client = clientReturning(404, body: 'Not Found');

      expect(await client.isAethervaultServer(server), isFalse);
    });

    test('returns false when /alive needs authentication', () async {
      final client = clientReturning(401, body: 'no token found\n');

      expect(await client.isAethervaultServer(server), isFalse);
    });

    test('returns false when the server reports an error', () async {
      final client = clientReturning(500);

      expect(await client.isAethervaultServer(server), isFalse);
    });

    test('throws network when the server is unreachable', () async {
      final client = AuthApiClient(
        client: MockClient((_) async {
          throw const SocketException('Connection refused');
        }),
      );

      expect(
        client.isAethervaultServer(server),
        authError(AuthErrorType.network),
      );
    });
  });

  group('errors and urls', () {
    test('throws network when the server is unreachable', () async {
      final client = AuthApiClient(
        client: MockClient((_) async {
          throw const SocketException('Connection refused');
        }),
      );

      expect(
        client.login(server, 'jace', 'secret', 'Pixel'),
        authError(AuthErrorType.network),
      );
    });

    test('throws network on http client errors', () async {
      final client = AuthApiClient(
        client: MockClient((_) async {
          throw http.ClientException('Failed host lookup');
        }),
      );

      expect(
        client.checkStatus(server, 'abc'),
        authError(AuthErrorType.network),
      );
    });

    test('keeps a path prefix of the server url', () async {
      late http.Request sent;
      final client = clientReturning(200, onRequest: (r) => sent = r);

      await client.checkStatus(
        Uri.parse('https://example.com/aethervault'),
        'abc',
      );

      expect(
        sent.url.toString(),
        'https://example.com/aethervault/auth/status',
      );
    });
  });

  group('parseServerUrl', () {
    test('accepts a full url', () {
      expect(
        parseServerUrl('https://vault.example.com'),
        Uri.parse('https://vault.example.com'),
      );
    });

    test('adds http when no scheme is given', () {
      expect(
        parseServerUrl('192.168.0.10:3333'),
        Uri.parse('http://192.168.0.10:3333'),
      );
    });

    test('trims whitespace and trailing slashes', () {
      expect(
        parseServerUrl('  http://localhost:3333/  '),
        Uri.parse('http://localhost:3333'),
      );
    });

    test('rejects empty input', () {
      expect(parseServerUrl('   '), isNull);
    });

    test('rejects other schemes', () {
      expect(parseServerUrl('ftp://example.com'), isNull);
    });

    test('rejects input without host', () {
      expect(parseServerUrl('http://'), isNull);
    });
  });
}
