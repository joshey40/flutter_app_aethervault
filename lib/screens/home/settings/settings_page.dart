import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../services/app_settings_scope.dart';
import '../../../services/localization_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = AppSettingsScope.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            appLocalizations.translate('settings.title'),
            style: theme.textTheme.headlineMedium,
          ),

          const SizedBox(height: 20),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appLocalizations.translate(
                      'settings.preferencesSection',
                    ),
                    style: theme.textTheme.titleLarge,
                  ),

                  const SizedBox(height: 12),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: settings.themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      settings.onThemeModeChanged(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                    title: Text(
                      appLocalizations.translate(
                        'settings.darkMode',
                      ),
                    ),
                  ),

                  const Divider(),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.language),
                    title: Text(
                      appLocalizations.translate(
                        'settings.language',
                      ),
                    ),
                    subtitle: Text(
                      settings.locale.languageCode == 'de'
                          ? appLocalizations.translate(
                              'settings.german',
                            )
                          : appLocalizations.translate(
                              'settings.english',
                            ),
                    ),
                    trailing: DropdownButton<String>(
                      value: settings.locale.languageCode,
                      underline: const SizedBox.shrink(),
                      items: [
                        DropdownMenuItem(
                          value: 'en',
                          child: Text(
                            appLocalizations.translate(
                              'settings.englishShort',
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'de',
                          child: Text(
                            appLocalizations.translate(
                              'settings.germanShort',
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        settings.onLocaleChanged(
                          Locale(value),
                        );
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
                  Text(
                    appLocalizations.translate(
                      'settings.downloadSection',
                    ),
                    style: theme.textTheme.titleLarge,
                  ),

                  const SizedBox(height: 12),

                  ListTile(
                    leading: const Icon(Icons.download),
                    title: Text(
                      appLocalizations.translate('settings.downloadData'),
                    ),
                    subtitle: Text(
                      appLocalizations.translate(
                        'settings.downloadDataDescription',
                      ),
                    ),
                    onTap: () {
                      context.push('/download?forced=true');
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.sync),
                    title: Text(
                      appLocalizations.translate('settings.parseData'),
                    ),
                    subtitle: Text(
                      appLocalizations.translate(
                        'settings.parseDataDescription',
                      ),
                    ),
                    onTap: () {
                      context.push('/parser');
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