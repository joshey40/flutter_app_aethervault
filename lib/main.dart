import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/download/download_screen.dart';
import 'screens/home/home_shell.dart';
import 'services/app_preferences_storage.dart';
import 'services/localization_service.dart';
import 'services/scryfall_download_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock orientation to portrait only. (Keeping screen awake removed temporarily.)
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final preferencesStorage = AppPreferencesStorage();

  final initialThemeMode = await preferencesStorage.loadThemeMode();
  final initialLocale = await preferencesStorage.loadLocale();
  await initializeLocalizations(initialLocale.languageCode);

  runApp(
    AetherVaultApp(
      preferencesStorage: preferencesStorage,
      initialThemeMode: initialThemeMode,
      initialLocale: initialLocale,
    ),
  );
}

class AetherVaultApp extends StatefulWidget {
  const AetherVaultApp({
    super.key,
    required this.preferencesStorage,
    required this.initialThemeMode,
    required this.initialLocale,
  });

  final AppPreferencesStorage preferencesStorage;
  final ThemeMode initialThemeMode;
  final Locale initialLocale;

  @override
  State<AetherVaultApp> createState() => _AetherVaultAppState();
}

class _AetherVaultAppState extends State<AetherVaultApp> {
  late ThemeMode _themeMode;
  late Locale _locale;
  bool _isCheckingDownloads = true;
  Map<String,dynamic> _needsDownload = { for (var type in ScryfallDownloadService.bulkDataTypes) type: false };

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
    _locale = widget.initialLocale;
    _checkDownloadNeed();
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

  Future<void> _checkDownloadNeed() async {
    if (!mounted) return;
    final service = ScryfallDownloadService();
    try {
      final needsDownload = await service.needsBulkDataDownload();
      if (!mounted) return;
      setState(() {
        _needsDownload = needsDownload;
        _isCheckingDownloads = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _needsDownload = { for (var type in ScryfallDownloadService.bulkDataTypes) type: true };
        _isCheckingDownloads = false;
      });
    } finally {
      service.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_needsDownload.containsValue(true)) {
      return MaterialApp(
        title: 'Aethervault',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        locale: _locale,
        home: DownloadScreen(
          themeMode: _themeMode,
          onThemeModeChanged: _setThemeMode,
          locale: _locale,
          onLocaleChanged: _setLocale,
          forcedDownload: true,
        ),
      );
    } else {
      return MaterialApp(
        title: 'Aethervault',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        locale: _locale,
        home: HomeShell(
          themeMode: _themeMode,
          onThemeModeChanged: _setThemeMode,
          locale: _locale,
          onLocaleChanged: _setLocale,
        ));
    }
  }
}