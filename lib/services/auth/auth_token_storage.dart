import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A logged in account
class AuthSession {
  const AuthSession({
    required this.token,
    required this.username,
    required this.server,
  });

  final String token;
  final String username;
  final Uri server;
}

class AuthTokenStorage {
  AuthTokenStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String _tokenKey = 'auth.token';
  static const String _usernameKey = 'auth.username';
  static const String _serverKey = 'auth.server';

  final FlutterSecureStorage _secureStorage;

  Future<void> saveSession(AuthSession session) async {
    await _secureStorage.write(key: _tokenKey, value: session.token);
    await _secureStorage.write(key: _usernameKey, value: session.username);
    await _secureStorage.write(
      key: _serverKey,
      value: session.server.toString(),
    );
  }

  Future<AuthSession?> loadSession() async {
    final token = await _secureStorage.read(key: _tokenKey);
    final username = await _secureStorage.read(key: _usernameKey);
    final server = await _secureStorage.read(key: _serverKey);

    if (token == null || username == null || server == null) {
      return null;
    }

    final serverUri = Uri.tryParse(server);
    if (serverUri == null) {
      return null;
    }

    return AuthSession(token: token, username: username, server: serverUri);
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _usernameKey);
    await _secureStorage.delete(key: _serverKey);
  }
}
