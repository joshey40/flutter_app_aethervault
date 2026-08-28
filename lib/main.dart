import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'services/app_settings_scope.dart';
import 'services/app_preferences_storage.dart';
import 'services/card_database/scryfall_download.dart';
import 'services/localization_service.dart';
import 'services/routing/router.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait only.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final preferencesStorage = AppPreferencesStorage();

  final initialThemeMode =
      await preferencesStorage.loadThemeMode();

  final initialLocale =
      await preferencesStorage.loadLocale();

  await initializeLocalizations(
    initialLocale.languageCode,
  );

  // Check whether the initial Scryfall data download is required.
  final needsDownload = await _checkDownloadNeed();

  runApp(
    AetherVaultApp(
      preferencesStorage: preferencesStorage,
      initialThemeMode: initialThemeMode,
      initialLocale: initialLocale,
      needsDownload: needsDownload,
    ),
  );
}

Future<bool> _checkDownloadNeed() async {
  final service = ScryfallDownloadService();

  try {
    final needsDownload =
        await service.needsBulkDataDownload();

    return needsDownload.values.any((value) => value);
  } catch (_) {
    // If we cannot determine the state, require a download.
    return true;
  } finally {
    service.dispose();
  }
}

class AetherVaultApp extends StatefulWidget {
  const AetherVaultApp({
    super.key,
    required this.preferencesStorage,
    required this.initialThemeMode,
    required this.initialLocale,
    required this.needsDownload,
  });

  final AppPreferencesStorage preferencesStorage;

  final ThemeMode initialThemeMode;
  final Locale initialLocale;
  final bool needsDownload;

  @override
  State<AetherVaultApp> createState() => _AetherVaultAppState();
}

class _AetherVaultAppState extends State<AetherVaultApp> {
  late ThemeMode _themeMode;
  late Locale _locale;

  late final router = createAppRouter(
    initialLocation: widget.needsDownload
        ? '/download?forced=false'
        : '/overview',
  );

  @override
  void initState() {
    super.initState();

    _themeMode = widget.initialThemeMode;
    _locale = widget.initialLocale;
  }

  /// Set the app's locale and save it to preferences.
  Future<void> _setLocale(Locale locale) async {
    await initializeLocalizations(
      locale.languageCode,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _locale = locale;
    });

    await widget.preferencesStorage.saveLocale(
      locale,
    );
  }

  /// Set the app's theme mode and save it to preferences.
  Future<void> _setThemeMode(
    ThemeMode themeMode,
  ) async {
    if (!mounted) {
      return;
    }

    setState(() {
      _themeMode = themeMode;
    });

    await widget.preferencesStorage.saveThemeMode(
      themeMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      themeMode: _themeMode,
      onThemeModeChanged: _setThemeMode,
      locale: _locale,
      onLocaleChanged: _setLocale,

      child: MaterialApp.router(
        title: 'Aethervault',
        debugShowCheckedModeBanner: false,

        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,

        locale: _locale,

        routerConfig: router,
      ),
    );
  }
}