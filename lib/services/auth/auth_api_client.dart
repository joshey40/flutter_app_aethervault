import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

enum AuthErrorType {
  invalidCredentials,
  userAlreadyExists,
  invalidRequest,
  unauthorized,
  invalidServerUrl,
  serverLocked,
  noServer,
  serverNotConnected,
  server,
  network,
}

class AuthException implements Exception {
  const AuthException(this.type, [this.message]);

  final AuthErrorType type;
  final String? message;

  @override
  String toString() =>
      'AuthException($type${message == null ? '' : ': $message'})';
}

enum TokenStatus { valid, invalid }

/// Parses a server address typed by the user.
Uri? parseServerUrl(String input) {
  var text = input.trim();
  if (text.isEmpty) {
    return null;
  }

  if (!text.contains('://')) {
    text = 'http://$text';
  }

  final uri = Uri.tryParse(text);
  if (uri == null ||
      (uri.scheme != 'http' && uri.scheme != 'https') ||
      uri.host.isEmpty) {
    return null;
  }

  var path = uri.path;
  while (path.endsWith('/')) {
    path = path.substring(0, path.length - 1);
  }

  return uri.replace(path: path);
}

/// Talks to the `/auth` endpoints of an Aethervault server.
class AuthApiClient {
  AuthApiClient({http.Client? client}) : _client = client ?? http.Client();

  static const _timeout = Duration(seconds: 10);

  final http.Client _client;

  Future<String> register(
    Uri server,
    String username,
    String password,
    String deviceName,
  ) async {
    final response = await _send(
      () => _client.put(
        _endpoint(server, 'auth/register'),
        headers: _jsonHeaders,
        body: _credentialsBody(username, password, deviceName),
      ),
    );

    _throwOnError(response);
    return _readToken(response);
  }

  Future<String> login(
    Uri server,
    String username,
    String password,
    String deviceName,
  ) async {
    final response = await _send(
      () => _client.post(
        _endpoint(server, 'auth/login'),
        headers: _jsonHeaders,
        body: _credentialsBody(username, password, deviceName),
      ),
    );

    if (response.statusCode == HttpStatus.unauthorized) {
      throw const AuthException(AuthErrorType.invalidCredentials);
    }
    _throwOnError(response);
    return _readToken(response);
  }

  Future<void> logout(Uri server, String token) async {
    final response = await _send(
      () => _client.post(
        _endpoint(server, 'auth/logout'),
        headers: _bearerHeaders(token),
      ),
    );

    _throwOnError(response);
  }

  Future<TokenStatus> checkStatus(Uri server, String token) async {
    final response = await _send(
      () => _client.get(
        _endpoint(server, 'auth/status'),
        headers: _bearerHeaders(token),
      ),
    );

    if (response.statusCode == HttpStatus.unauthorized) {
      return TokenStatus.invalid;
    }
    _throwOnError(response);
    return TokenStatus.valid;
  }

  Future<bool> isAethervaultServer(Uri server) async {
    final response = await _send(() => _client.get(_endpoint(server, 'alive')));

    return response.statusCode == HttpStatus.ok;
  }

  void dispose() {
    _client.close();
  }

  static const _jsonHeaders = {'Content-Type': 'application/json'};

  Map<String, String> _bearerHeaders(String token) {
    return {'Authorization': 'Bearer $token'};
  }

  Uri _endpoint(Uri server, String path) {
    return server.replace(path: '${server.path}/$path');
  }

  String _credentialsBody(String username, String password, String device) {
    return jsonEncode({
      'username': username,
      'passwd': password,
      'currDevice': device,
    });
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(_timeout);
    } on SocketException catch (e) {
      throw AuthException(AuthErrorType.network, e.message);
    } on http.ClientException catch (e) {
      throw AuthException(AuthErrorType.network, e.message);
    } on TimeoutException {
      throw const AuthException(AuthErrorType.network, 'timeout');
    }
  }

  void _throwOnError(http.Response response) {
    final status = response.statusCode;
    if (status >= 200 && status < 300) {
      return;
    }

    final message = _readErrorMessage(response);
    throw switch (status) {
      HttpStatus.badRequest => AuthException(
        AuthErrorType.invalidRequest,
        message,
      ),
      HttpStatus.unauthorized => AuthException(
        AuthErrorType.unauthorized,
        message,
      ),
      HttpStatus.conflict => AuthException(
        AuthErrorType.userAlreadyExists,
        message,
      ),
      _ => AuthException(AuthErrorType.server, message),
    };
  }

  /// Reads the error message from the response body.
  String? _readErrorMessage(http.Response response) {
    try {
      final json = jsonDecode(response.body);
      if (json is Map<String, dynamic> && json['status'] is String) {
        return json['status'] as String;
      }
    } on FormatException {
      // plain text body
    }

    final text = response.body.trim();
    return text.isEmpty ? null : text;
  }

  String _readToken(http.Response response) {
    try {
      final json = jsonDecode(response.body);
      if (json is Map<String, dynamic> && json['authToken'] is String) {
        return json['authToken'] as String;
      }
    } on FormatException {
      // plain text body
    }

    throw const AuthException(
      AuthErrorType.server,
      'response did not contain an auth token',
    );
  }
}
