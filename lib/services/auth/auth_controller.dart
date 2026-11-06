import 'package:flutter/foundation.dart';

import '../app_preferences_storage.dart';
import 'auth_api_client.dart';
import 'auth_token_storage.dart';
import 'device_name.dart';

enum ServerStatus {
  /// No server address is set.
  none,

  /// An address is set, but it was not checked yet.
  unknown,
  checking,
  connected,
  unreachable,

  /// Something answers under the address, but it is no Aethervault server.
  notAethervault,
}

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
  ServerStatus _serverStatus = ServerStatus.none;

  /// Increased whenever session or address change, so answers of requests
  /// started before can be recognized as outdated and ignored.
  int _generation = 0;

  AuthSession? get session => _session;
  bool get isLoggedIn => _session != null;

  Uri? get serverUrl => _serverUrl;
  ServerStatus get serverStatus => _serverStatus;

  /// Logged in, but the server could not be reached on the last check.
  bool get isOffline => isLoggedIn && _serverStatus == ServerStatus.unreachable;

  /// A logout request is running, further logout calls join it.
  bool get isLoggingOut => _logoutFuture != null;

  Future<void>? _logoutFuture;

  /// Loads the persisted server address and session once on app start.
  Future<void> initialize() async {
    final savedUrl = await _preferencesStorage.loadServerUrl();
    _serverUrl = savedUrl == null ? null : parseServerUrl(savedUrl);
    _session = await _tokenStorage.loadSession();
    _serverStatus = _serverUrl == null && _session == null
        ? ServerStatus.none
        : ServerStatus.unknown;
  }

  /// Checks the connection to the server. When logged in, it also asks whether the saved token is still valid and drops the session if it is not.
  Future<void> checkConnection() async {
    final session = _session;
    final server = session?.server ?? _serverUrl;
    if (server == null) {
      return;
    }

    final generation = ++_generation;
    _serverStatus = ServerStatus.checking;
    notifyListeners();

    ServerStatus result;
    var tokenInvalid = false;
    try {
      if (session != null) {
        final status = await _apiClient.checkStatus(server, session.token);
        tokenInvalid = status == TokenStatus.invalid;
        result = ServerStatus.connected;
      } else {
        result = await _apiClient.isAethervaultServer(server)
            ? ServerStatus.connected
            : ServerStatus.notAethervault;
      }
    } on AuthException {
      result = ServerStatus.unreachable;
    }

    // Address or session may have changed while the request was running.
    if (generation != _generation) {
      return;
    }
    if (tokenInvalid) {
      await _clearSession();
    }
    _serverStatus = result;
    notifyListeners();
  }

  /// Saves the server address typed by the user and checks it, empty input removes it.
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

    _generation++;
    _serverUrl = url;
    _serverStatus = url == null ? ServerStatus.none : ServerStatus.unknown;
    await _preferencesStorage.saveServerUrl(url?.toString());
    notifyListeners();

    await checkConnection();
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

    _generation++;
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
    if (_serverStatus != ServerStatus.connected) {
      throw const AuthException(AuthErrorType.serverNotConnected);
    }

    final name = username.trim();
    final deviceName = await _deviceNameLoader();

    final String token;
    try {
      token = await request(server, name, password, deviceName);
    } on AuthException catch (e) {
      if (e.type == AuthErrorType.network) {
        _generation++;
        _serverStatus = ServerStatus.unreachable;
        notifyListeners();
      }
      rethrow;
    }

    final session = AuthSession(token: token, username: name, server: server);
    await _tokenStorage.saveSession(session);
    _generation++;
    _session = session;
    _serverStatus = ServerStatus.connected;
    notifyListeners();
  }

  Future<void> _logout(AuthSession session) async {
    try {
      try {
        await _apiClient.logout(session.server, session.token);
        _serverStatus = ServerStatus.connected;
      } on AuthException catch (e) {
        // the device entry stays on the server, the local session is gone anyway
        _serverStatus = e.type == AuthErrorType.network
            ? ServerStatus.unreachable
            : ServerStatus.connected;
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
  }
}
