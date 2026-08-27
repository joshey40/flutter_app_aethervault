import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesStorage {
  static const String _themeModeKey = 'settings.themeMode';
  static const String _localeKey = 'settings.locale';
  static const String _lifecounterKey = 'lifecounter.current_game';
  static const String _scryfallBulkDataItemsKey = 'scryfall.bulk_data_items';
  static const String _scryfallBulkDataMetadataKeyPrefix = 'scryfall.bulk_data_metadata.';

  // ==============================================================================
  // Settings
  // =============================================================================

  /// Read the theme mode from shared preferences. If not set, defaults to ThemeMode.dark.
  Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    switch (prefs.getString(_themeModeKey)) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      case 'dark':
      default:
        return ThemeMode.dark;
    }
  }

  /// Save the [themeMode] to shared preferences.
  Future<void> saveThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    final value = switch (themeMode) {
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
    };
    await prefs.setString(_themeModeKey, value);
  }

  /// Read the locale from shared preferences. If not set, defaults to Locale('en').
  Future<Locale> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey);
    return switch (localeCode) {
      'de' => const Locale('de'),
      _ => const Locale('en'),
    };
  }

  /// Save the [locale] to shared preferences.
  Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  // ==============================================================================
  // Lifecounter
  // =============================================================================
  
  /// Save the current lifecounter game state as a [json] string.
  Future<void> saveLifecounterGame(String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lifecounterKey, json);
  }

  /// Load the current lifecounter game state as a JSON string. Returns null if no game state is saved.
  Future<String?> loadLifecounterGame() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lifecounterKey);
  }

  /// Clear the current lifecounter game state from shared preferences.
  Future<void> clearLifecounterGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lifecounterKey);
  }

  // ==============================================================================
  // Scryfall Data
  // ============================================================================
  
  /// Save the Scryfall bulk data items as a [json] string.
  Future<void> saveScryfallBulkDataItems(String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_scryfallBulkDataItemsKey, json);
  }

  /// Load the Scryfall bulk data items as a JSON string. Returns null if no data is saved.
  Future<String?> loadScryfallBulkDataItems() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_scryfallBulkDataItemsKey);
  }

  /// Save the Scryfall bulk data metadata for a specific [bulkDataType] as a [json] string.
  Future<void> saveScryfallBulkDataMetadata(String bulkDataType, String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_scryfallBulkDataMetadataKeyPrefix$bulkDataType',
      json,
    );
  }

  /// Load the Scryfall bulk data metadata for a specific [bulkDataType] as a JSON string. Returns null if no data is saved.
  Future<String?> loadScryfallBulkDataMetadata(String bulkDataType) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_scryfallBulkDataMetadataKeyPrefix$bulkDataType');
  }

  /// Remove the Scryfall bulk data metadata for a specific [bulkDataType] from shared preferences.
  Future<void> removeScryfallBulkDataMetadata(String bulkDataType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_scryfallBulkDataMetadataKeyPrefix$bulkDataType');
  }
}
