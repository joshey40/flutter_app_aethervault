import 'dart:convert';

import 'package:flutter/services.dart';

class AppLocalizations {
  Map<String, dynamic> _localizedStrings = {};

  static const Set<String> _supportedLanguages = {'en', 'de'};

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

  Future<String> _loadJson(String languageCode) async {
    return rootBundle.loadString('lib/l10n/$languageCode.json');
  }

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

AppLocalizations appLocalizations = AppLocalizations();

Future<void> initializeLocalizations(String localeCode) async {
  appLocalizations = AppLocalizations();
  await appLocalizations.load(localeCode);
}
