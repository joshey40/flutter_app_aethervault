import 'package:flutter/material.dart';

import '../../../services/localization_service.dart';

import '../../download_parser/download_screen.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.locale,
    required this.onLocaleChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final Locale locale;
  final Future<void> Function(Locale locale) onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(appLocalizations.translate('settings.title'), style: theme.textTheme.headlineMedium),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appLocalizations.translate('settings.preferencesSection'), style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: themeMode == ThemeMode.dark,
                    onChanged: (value) => onThemeModeChanged(value ? ThemeMode.dark : ThemeMode.light),
                    title: Text(appLocalizations.translate('settings.darkMode')),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.language),
                    title: Text(appLocalizations.translate('settings.language')),
                    subtitle: Text(locale.languageCode == 'de'
                        ? appLocalizations.translate('settings.german')
                        : appLocalizations.translate('settings.english')),
                    trailing: DropdownButton<String>(
                      value: locale.languageCode,
                      underline: const SizedBox.shrink(),
                      items: [
                        DropdownMenuItem(
                          value: 'en',
                          child: Text(appLocalizations.translate('settings.englishShort')),
                        ),
                        DropdownMenuItem(
                          value: 'de',
                          child: Text(appLocalizations.translate('settings.germanShort')),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        onLocaleChanged(Locale(value));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appLocalizations.translate('settings.downloadSection'), style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.download_rounded),
                    title: Text(appLocalizations.translate('settings.downloadData')),
                    subtitle: Text(appLocalizations.translate('settings.downloadDataDescription')),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DownloadScreen(
                            themeMode: themeMode,
                            onThemeModeChanged: onThemeModeChanged,
                            locale: locale,
                            onLocaleChanged: onLocaleChanged,
                            forcedDownload: true,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
