import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/vault_user.dart';
import 'credentials/firebase_options.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/sign_up_page.dart';
import 'screens/home/home_shell.dart';
import 'services/app_preferences_storage.dart';
import 'services/firebase_auth_service.dart';
import 'services/localization_service.dart';
import 'services/scryfall/download_service.dart';
import 'services/scryfall/bulk_data_type.dart';
import 'services/services_provider.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Lock orientation to portrait only. (Keeping screen awake removed temporarily.)
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final preferencesStorage = AppPreferencesStorage();
  final authService = FirebaseAuthService();

  final initialThemeMode = await preferencesStorage.loadThemeMode();
  final initialLocale = await preferencesStorage.loadLocale();
  await initializeLocalizations(initialLocale.languageCode);
  final currentUser = await authService.loadCurrentUser();

  runApp(
    AetherVaultApp(
      preferencesStorage: preferencesStorage,
      authService: authService,
      initialThemeMode: initialThemeMode,
      initialLocale: initialLocale,
      currentUser: currentUser,
    ),
  );
}

class AetherVaultApp extends StatefulWidget {
  const AetherVaultApp({
    super.key,
    required this.preferencesStorage,
    required this.authService,
    required this.initialThemeMode,
    required this.initialLocale,
    required this.currentUser,
  });

  final AppPreferencesStorage preferencesStorage;
  final FirebaseAuthService authService;
  final ThemeMode initialThemeMode;
  final Locale initialLocale;
  final VaultUser? currentUser;

  @override
  State<AetherVaultApp> createState() => _AetherVaultAppState();
}

class _AetherVaultAppState extends State<AetherVaultApp> {
  late ThemeMode _themeMode;
  late Locale _locale;
  bool _showSignUp = false;
  StreamSubscription<VaultUser?>? _authStateSubscription;
  bool _initializing = true;
  double _initProgress = 0.0;
  String _initStatus = '';

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
    _locale = widget.initialLocale;
    _authStateSubscription = widget.authService.authStateChanges().listen((user) {
      if (!mounted || user != null || !_showSignUp) {
        return;
      }

      setState(() {
        _showSignUp = false;
      });
    });

    _runStartupInitialization();
  }

  Future<void> _runStartupInitialization() async {
    if (!mounted) return;
    setState(() {
      _initStatus = 'Fetching Scryfall metadata...';
      _initProgress = 0.0;
    });

    try {
      final service = DownloadService.instance;
      await _ensureBulkDataFile(
        service: service,
        type: ScryfallBulkDataType.oracleCards,
        progressStart: 0.0,
        progressEnd: 0.20,
      );
      await _ensureBulkDataFile(
        service: service,
        type: ScryfallBulkDataType.defaultCards,
        progressStart: 0.20,
        progressEnd: 0.45,
      );
      await _ensureBulkDataFile(
        service: service,
        type: ScryfallBulkDataType.allCards,
        progressStart: 0.45,
        progressEnd: 1.0,
      );

      if (mounted) {
        setState(() {
          _initStatus = 'Scryfall data ready.';
          _initProgress = 1.0;
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _initStatus = 'Scryfall initialization failed: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _initializing = false;
        });
      }
    }
  }

  Future<void> _ensureBulkDataFile({
    required DownloadService service,
    required ScryfallBulkDataType type,
    required double progressStart,
    required double progressEnd,
  }) async {
    setState(() {
      _initStatus = 'Checking ${type.userFacingName}...';
      _initProgress = progressStart;
    });

    final available = await service.isFileUpToDate(type: type);
    if (available) return;

    await service.downloadBulkData(
      type: type,
      force: false,
      onProgress: (received, total) {
        if (!mounted) return;
        setState(() {
          if (total != null && total > 0) {
            final fileProgress = (received / total).clamp(0.0, 1.0);
            _initProgress = progressStart + (progressEnd - progressStart) * fileProgress;
            _initStatus =
                'Downloading ${type.userFacingName}: ${(fileProgress * 100).toStringAsFixed(0)}%';
          } else {
            _initStatus = 'Downloading ${type.userFacingName}: $received bytes';
          }
        });
      },
    );
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _setLocale(Locale locale) async {
    await initializeLocalizations(locale.languageCode);
    setState(() {
      _locale = locale;
    });
    await widget.preferencesStorage.saveLocale(locale);
  }

  Future<void> _setThemeMode(ThemeMode themeMode) async {
    setState(() {
      _themeMode = themeMode;
    });
    await widget.preferencesStorage.saveThemeMode(themeMode);
  }

  void _showLogin() {
    setState(() {
      _showSignUp = false;
    });
  }

  void _showSignUpPage() {
    setState(() {
      _showSignUp = true;
    });
  }

  Future<void> _handleAuthenticated(VaultUser _) async {
    setState(() {
      _showSignUp = false;
    });
  }

  Future<void> _handleSignOut() async {
    await widget.authService.signOut();
    setState(() {
      _showSignUp = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return MaterialApp(
        title: 'Aethervault',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        locale: _locale,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Text(_initStatus.isEmpty ? 'Preparing data...' : _initStatus),
                  const SizedBox(height: 12),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  if (_initProgress > 0 && _initProgress <= 1)
                    Column(
                      children: [
                        LinearProgressIndicator(value: _initProgress),
                        const SizedBox(height: 8),
                        Text('${(_initProgress * 100).toStringAsFixed(0)}%'),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Aethervault',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      locale: _locale,
      home: ServicesProvider(
        child: StreamBuilder<VaultUser?>(
          stream: widget.authService.authStateChanges(),
          initialData: widget.currentUser,
          builder: (context, snapshot) {
            final currentUser = snapshot.data;
            if (currentUser == null) {
              return _showSignUp
                  ? SignUpPage(
                      authService: widget.authService,
                      onLoginTap: _showLogin,
                      onSignUpSuccess: _handleAuthenticated,
                    )
                  : LoginPage(
                      authService: widget.authService,
                      onSignUpTap: _showSignUpPage,
                      onSignInSuccess: _handleAuthenticated,
                    );
            }

            return HomeShell(
              user: currentUser,
              themeMode: _themeMode,
              onThemeModeChanged: _setThemeMode,
              locale: _locale,
              onLocaleChanged: _setLocale,
              onSignOut: _handleSignOut,
            );
          },
        ),
      ),
    );
  }
}
