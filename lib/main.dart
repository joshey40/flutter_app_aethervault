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
import 'services/scryfall/scryfall_sqlite_search_index.dart';
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
        progressEnd: 0.70,
        reportProgress: true,
      );
      await _ensureSearchIndex(
        service: service,
        type: ScryfallBulkDataType.oracleCards,
        progress: 0.92,
        reportProgress: true,
      );

      if (mounted) {
        setState(() {
          _initStatus = 'Scryfall data ready.';
          _initProgress = 1.0;
        });
      }

      unawaited(_prepareOptionalScryfallData(service));
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

  Future<void> _prepareOptionalScryfallData(DownloadService service) async {
    for (final type in const <ScryfallBulkDataType>[
      ScryfallBulkDataType.defaultCards,
      ScryfallBulkDataType.allCards,
    ]) {
      try {
        await _ensureBulkDataFile(
          service: service,
          type: type,
          progressStart: 0.0,
          progressEnd: 1.0,
          reportProgress: false,
        );
        await _ensureSearchIndex(
          service: service,
          type: type,
          progress: 1.0,
          reportProgress: false,
        );
      } catch (_) {
        // Optional indexes are best-effort. If one fails, SearchRepository can
        // still fall back to remote Scryfall for unsupported/local-missing data.
      }
    }
  }

  Future<void> _ensureBulkDataFile({
    required DownloadService service,
    required ScryfallBulkDataType type,
    required double progressStart,
    required double progressEnd,
    required bool reportProgress,
  }) async {
    if (reportProgress && mounted) {
      setState(() {
        _initStatus = 'Checking ${type.userFacingName}...';
        _initProgress = progressStart;
      });
    }

    final available = await service.isFileUpToDate(type: type);
    if (available) return;

    await service.downloadBulkData(
      type: type,
      force: false,
      onProgress: reportProgress
          ? (received, total) {
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
            }
          : null,
    );
  }

  Future<void> _ensureSearchIndex({
    required DownloadService service,
    required ScryfallBulkDataType type,
    required double progress,
    required bool reportProgress,
  }) async {
    final file = await service.getLocalFile(type: type);
    if (file == null) return;

    final ready = await ScryfallSqliteSearchIndex.instance.isIndexReady(
      type: type,
      sourceFile: file,
    );
    if (ready) return;

    if (reportProgress && mounted) {
      setState(() {
        _initStatus = 'Indexing ${type.userFacingName}...';
        _initProgress = progress;
      });
    }

    await ScryfallSqliteSearchIndex.instance.ensureIndex(
      type: type,
      sourceFile: file,
    );
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _setLocale(Locale locale) async {
    if (_locale == locale) return;
    await initializeLocalizations(locale.languageCode);
    await widget.preferencesStorage.saveLocale(locale);
    if (!mounted) return;
    setState(() => _locale = locale);
  }

  Future<void> _setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;
    await widget.preferencesStorage.saveThemeMode(themeMode);
    if (!mounted) return;
    setState(() => _themeMode = themeMode);
  }

  void _toggleAuthMode() => setState(() => _showSignUp = !_showSignUp);

  @override
  Widget build(BuildContext context) {
    return ServicesProvider(
      preferencesStorage: widget.preferencesStorage,
      authService: widget.authService,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AetherVault',
        theme: buildAetherVaultTheme(Brightness.light),
        darkTheme: buildAetherVaultTheme(Brightness.dark),
        themeMode: _themeMode,
        locale: _locale,
        home: _initializing
            ? _StartupLoadingScreen(
                progress: _initProgress,
                status: _initStatus,
              )
            : widget.currentUser == null
                ? _showSignUp
                    ? SignUpPage(onLoginTap: _toggleAuthMode)
                    : LoginPage(onSignUpTap: _toggleAuthMode)
                : HomeShell(
                    onLocaleChanged: _setLocale,
                    onThemeModeChanged: _setThemeMode,
                  ),
      ),
    );
  }
}

class _StartupLoadingScreen extends StatelessWidget {
  const _StartupLoadingScreen({
    required this.progress,
    required this.status,
  });

  final double progress;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 46, color: AppTheme.vaultAmber),
              const SizedBox(height: 20),
              Text(
                'AetherVault',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(value: progress.clamp(0.0, 1.0)),
              const SizedBox(height: 12),
              Text(status, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
