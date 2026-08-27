import 'dart:convert';

import 'package:flutter/services.dart';

class AppLocalizations {
  Map<String, dynamic> _localizedStrings = {};

  static const Set<String> _supportedLanguages = {'en', 'de'};

  /// Load the localization JSON file for the given [localeCode].
  Future<void> load(String localeCode) async {
    try {
      var languageCode = localeCode.split('_').first;
      if (!_supportedLanguages.contains(languageCode)) {
        languageCode = 'en';
      }
      final jsonString = await _loadJson(languageCode);
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      _localizedStrings = jsonMap;
    } catch (_) {
      _localizedStrings = {};
    }
  }

  /// Load the JSON file for the given [languageCode] from the assets.
  Future<String> _loadJson(String languageCode) async {
    return rootBundle.loadString('lib/l10n/$languageCode.json');
  }

  /// Translate the given [key] into the localized string. If the key is not found, return the key itself.
  String translate(String key) {
    dynamic value = _localizedStrings;
    for (final segment in key.split('.')) {
      if (value is Map<String, dynamic>) {
        value = value[segment];
      } else {
        return key;
      }
    }
    return value?.toString() ?? key;
  }
}

/// Global instance of AppLocalizations to be used throughout the app.
AppLocalizations appLocalizations = AppLocalizations();

/// Initialize the localization service with the given [localeCode].
/// This function should be called before the app starts to ensure that the correct localization is loaded.
Future<void> initializeLocalizations(String localeCode) async {
  appLocalizations = AppLocalizations();
  await appLocalizations.load(localeCode);
}
