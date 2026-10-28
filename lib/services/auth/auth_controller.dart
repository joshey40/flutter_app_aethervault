import 'package:flutter/foundation.dart';

import '../app_preferences_storage.dart';
import 'auth_api_client.dart';
import 'auth_token_storage.dart';
import 'device_name.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    AuthApiClient? apiClient,
    AuthTokenStorage? tokenStorage,
    AppPreferencesStorage? preferencesStorage,
    Future<String> Function()? deviceNameLoader,
  }) : _apiClient = apiClient ?? AuthApiClient(),
       _tokenStorage = tokenStorage ?? AuthTokenStorage(),
       _preferencesStorage = preferencesStorage ?? AppPreferencesStorage(),
       _deviceNameLoader = deviceNameLoader ?? loadDeviceName;

  final AuthApiClient _apiClient;
  final AuthTokenStorage _tokenStorage;
  final AppPreferencesStorage _preferencesStorage;
  final Future<String> Function() _deviceNameLoader;

  AuthSession? _session;
  Uri? _serverUrl;
  bool _isOffline = false;

  AuthSession? get session => _session;
  bool get isLoggedIn => _session != null;

  /// Logged in, but the server could not be reached on the last check.
  bool get isOffline => _isOffline;

  Uri? get serverUrl => _serverUrl;

  /// A logout request is running, further logout calls join it.
  bool get isLoggingOut => _logoutFuture != null;

  Future<void>? _logoutFuture;

  /// Loads the persisted server address and session once on app start.
  Future<void> initialize() async {
    final savedUrl = await _preferencesStorage.loadServerUrl();
    _serverUrl = savedUrl == null ? null : parseServerUrl(savedUrl);
    _session = await _tokenStorage.loadSession();
  }

  /// Asks the server whether the saved token is still valid and drops the session if it is not. An unreachable server only marks the app offline.
  Future<void> verifySession() async {
    final session = _session;
    if (session == null) {
      return;
    }

    try {
      final status = await _apiClient.checkStatus(
        session.server,
        session.token,
      );
      // The user may have logged out or in again while the check was running.
      if (!identical(_session, session)) {
        return;
      }
      if (status == TokenStatus.invalid) {
        await _clearSession();
      } else {
        _isOffline = false;
      }
    } on AuthException {
      if (!identical(_session, session)) {
        return;
      }
      _isOffline = true;
    }
    notifyListeners();
  }

  /// Saves the server address typed by the user, empty input removes it.
  ///
  /// The address is locked while logged in, because the token is only valid
  /// on the server that issued it.
  Future<void> setServerUrl(String input) async {
    if (_session != null) {
      throw const AuthException(AuthErrorType.serverLocked);
    }

    Uri? url;
    if (input.trim().isNotEmpty) {
      url = parseServerUrl(input);
      if (url == null) {
        throw const AuthException(AuthErrorType.invalidServerUrl);
      }
    }

    _serverUrl = url;
    await _preferencesStorage.saveServerUrl(url?.toString());
    notifyListeners();
  }

  Future<void> login(String username, String password) {
    return _authenticate(username, _apiClient.login, password);
  }

  Future<void> register(String username, String password) {
    return _authenticate(username, _apiClient.register, password);
  }

  /// Logs out on the server and always clears the local session, even when the server cannot be reached.
  Future<void> logout() {
    final running = _logoutFuture;
    if (running != null) {
      return running;
    }

    final session = _session;
    if (session == null) {
      return Future.value();
    }

    final logout = _logoutFuture = _logout(session);
    notifyListeners();
    return logout;
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }

  Future<void> _authenticate(
    String username,
    Future<String> Function(Uri, String, String, String) request,
    String password,
  ) async {
    final server = _serverUrl;
    if (server == null) {
      throw const AuthException(AuthErrorType.noServer);
    }

    final name = username.trim();
    final deviceName = await _deviceNameLoader();
    final token = await request(server, name, password, deviceName);

    final session = AuthSession(token: token, username: name, server: server);
    await _tokenStorage.saveSession(session);
    _session = session;
    _isOffline = false;
    notifyListeners();
  }

  Future<void> _logout(AuthSession session) async {
    try {
      try {
        await _apiClient.logout(session.server, session.token);
      } on AuthException {
        // the device entry stays on the server, the local session is gone anyway
      }
      await _clearSession();
    } finally {
      _logoutFuture = null;
      notifyListeners();
    }
  }

  Future<void> _clearSession() async {
    await _tokenStorage.clearSession();
    _session = null;
    _isOffline = false;
  }
}
