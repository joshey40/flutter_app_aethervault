import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesStorage {
  static const String _themeModeKey = 'settings.themeMode';
  static const String _localeKey = 'settings.locale';
  static const String _lifecounterKey = 'lifecounter.current_game';

  Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    switch (prefs.getString(_themeModeKey)) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }

  Future<void> saveThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    final value = switch (themeMode) {
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
    };
    await prefs.setString(_themeModeKey, value);
  }

  Future<Locale> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey);
    return switch (localeCode) {
      'de' => const Locale('de'),
      _ => const Locale('en'),
    };
  }

  Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  // Lifecounter persistence (JSON encoded game)
  Future<void> saveLifecounterGame(String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lifecounterKey, json);
  }

  Future<String?> loadLifecounterGame() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lifecounterKey);
  }

  Future<void> clearLifecounterGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lifecounterKey);
  }
}
