import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'models/vault_user.dart';
import 'credentials/firebase_options.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/sign_up_page.dart';
import 'screens/home/home_shell.dart';
import 'services/app_preferences_storage.dart';
import 'services/firebase_auth_service.dart';
import 'services/localization_service.dart';
import 'services/scryfall_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final preferencesStorage = AppPreferencesStorage();
  final authService = FirebaseAuthService();
  final scry = ScryfallService();

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
      scryfallService: scry,
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
    required this.scryfallService,
  });

  final AppPreferencesStorage preferencesStorage;
  final FirebaseAuthService authService;
  final ThemeMode initialThemeMode;
  final Locale initialLocale;
  final VaultUser? currentUser;
  final ScryfallService scryfallService;

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

    // start Scryfall initialization (show loading screen while running)
    _runStartupInitialization();
  }

  Future<void> _runStartupInitialization() async {
    final scry = widget.scryfallService;

    // First, quickly check whether any bulk requires download.
    final types = [
      ScryfallBulkType.oracleCards,
      ScryfallBulkType.defaultCards,
      ScryfallBulkType.allCards,
    ];
    bool needsDownload = false;
    try {
      for (final type in types) {
        final hasCache = await scry.hasLocalCache(bulkType: type);
        final stale = !hasCache ? true : await scry.isCacheStale(bulkType: type);
        if (!hasCache || stale) {
          needsDownload = true;
          break;
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Scryfall pre-check failed: $e');
      // If pre-check fails, assume we need to initialize to be safe
      needsDownload = true;
    }

    // If nothing needs downloading, skip the full-screen initializer and open the app.
    if (!needsDownload) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
      });
      return;
    }

    // Otherwise proceed with full initialization and show loader.
    setState(() {
      _initializing = true;
      _initProgress = 0.0;
      _initStatus = 'Checking local cache';
    });

    try {
      final total = types.length;
      for (var i = 0; i < total; i++) {
        final type = types[i];
        final typeName = type.apiValue;
        // update status
        setState(() {
          _initStatus = 'Processing $typeName (${i + 1}/$total)';
          _initProgress = i / total;
        });

        final hasCache = await scry.hasLocalCache(bulkType: type);
        final stale = !hasCache ? true : await scry.isCacheStale(bulkType: type);

        if (!hasCache || stale) {
          final uri = await scry.fetchBulkIndexAndChooseUri(bulkType: type);
          if (uri != null) {
            await scry.downloadBulk(uri, bulkType: type, onProgress: (p) {
              if (!mounted) return;
              setState(() {
                // overall progress: (completed types + current progress) / total
                _initProgress = (i + p) / total;
                _initStatus = 'Downloading $typeName (${((_initProgress) * 100).toStringAsFixed(0)}%)';
              });
            });
            // ensure progress reflects completed type
            if (!mounted) return;
            setState(() {
              _initProgress = (i + 1) / total;
            });
          } else {
            // couldn't find uri; skip
            if (!mounted) return;
            setState(() {
              _initProgress = (i + 1) / total;
            });
          }
        } else {
          // already fresh; mark as completed
          if (!mounted) return;
          setState(() {
            _initProgress = (i + 1) / total;
          });
        }
        // Respect Scryfall API rate limits: pause briefly between API requests
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e, st) {
      if (kDebugMode) debugPrint('Scryfall initialization error: $e\n$st');
      // ignore errors and proceed
    }

    if (!mounted) return;
    setState(() {
      _initializing = false;
      _initProgress = 0.0;
      _initStatus = '';
    });
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
      home: StreamBuilder<VaultUser?>(
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
    );
  }
}
