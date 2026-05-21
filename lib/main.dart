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

  // Scryfall data initialization handled inside the app (service removed).

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
  // CardsDataService removed

  @override
  State<AetherVaultApp> createState() => _AetherVaultAppState();
}

class _AetherVaultAppState extends State<AetherVaultApp> {
  late ThemeMode _themeMode;
  late Locale _locale;
  bool _showSignUp = false;
  StreamSubscription<VaultUser?>? _authStateSubscription;
  // startup download state
  bool _initializing = true;
  double _initProgress = 0.0;
  String _initStatus = '';
  // parsed cards data service removed

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

    // Start initialization as before (CardsDataService removed).
    _initializing = true;
    _runStartupInitialization();
  }

  Future<void> _runStartupInitialization() async {
    // Download Scryfall data and prepare it for use.
    if (!mounted) return;
    setState(() {
      _initStatus = 'Fetching Scryfall metadata...';
      _initProgress = 0.0;
    });

    try {
      final svc = DownloadService.instance;
      setState(() {
        _initStatus = 'Downloading All Cards (this may take a while)...';
        _initProgress = 0.0;
      });

      final file = await svc.downloadAllCards(force: false, onProgress: (received, total) {
        if (!mounted) return;
        setState(() {
          if (total != null && total > 0) {
            _initProgress = received / total;
            _initStatus = 'Downloading All Cards: ${(_initProgress * 100).toStringAsFixed(0)}%';
          } else {
            // Unknown total size: show received bytes in status
            _initStatus = 'Downloading All Cards: $received bytes';
          }
        });
      });

      if (mounted) {
        setState(() {
          _initStatus = 'Scryfall data ready: ${file.path}';
          _initProgress = 1.0;
        });
        // Download complete; parsing/service removed per project cleanup.
      }
    } catch (e) {
      setState(() {
        _initStatus = 'Scryfall initialization failed: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _initializing = false;
        });
      }
    }
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
    // While initializing Scryfall data, show a full-screen loading indicator
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
                  // Always show a spinner to indicate activity, and also show
                  // the linear progress bar when we have progress information.
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
        }),
      )
    );
  }
}
