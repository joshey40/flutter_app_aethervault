import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app_aethervault/services/auth/auth_token_storage.dart';

void main() {
  late AuthTokenStorage storage;

  final session = AuthSession(
    token: 'abc',
    username: 'jace',
    server: Uri.parse('http://192.168.0.10:3333'),
  );

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    storage = AuthTokenStorage();
  });

  test('returns null when no session is saved', () async {
    expect(await storage.loadSession(), isNull);
  });

  test('saves and loads a session', () async {
    await storage.saveSession(session);

    final loaded = await storage.loadSession();

    expect(loaded, isNotNull);
    expect(loaded!.token, 'abc');
    expect(loaded.username, 'jace');
    expect(loaded.server, Uri.parse('http://192.168.0.10:3333'));
  });

  test('clears the session', () async {
    await storage.saveSession(session);

    await storage.clearSession();

    expect(await storage.loadSession(), isNull);
  });

  test('returns null when the saved session is incomplete', () async {
    FlutterSecureStorage.setMockInitialValues({'auth.token': 'abc'});

    expect(await storage.loadSession(), isNull);
  });
}
