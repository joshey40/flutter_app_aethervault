import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../../services/app_settings_scope.dart';
import '../../../services/auth/auth_api_client.dart';
import '../../../services/auth/auth_controller.dart';
import '../../../services/localization_service.dart';
import '../../auth/auth_error_message.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.authController});

  final AuthController authController;

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

          _AccountSection(authController: authController),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appLocalizations.translate('settings.preferencesSection'),
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
                      appLocalizations.translate('settings.darkMode'),
                    ),
                  ),

                  const Divider(),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.language),
                    title: Text(
                      appLocalizations.translate('settings.language'),
                    ),
                    subtitle: Text(
                      settings.locale.languageCode == 'de'
                          ? appLocalizations.translate('settings.german')
                          : appLocalizations.translate('settings.english'),
                    ),
                    trailing: DropdownButton<String>(
                      value: settings.locale.languageCode,
                      underline: const SizedBox.shrink(),
                      items: [
                        DropdownMenuItem(
                          value: 'en',
                          child: Text(
                            appLocalizations.translate('settings.englishShort'),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'de',
                          child: Text(
                            appLocalizations.translate('settings.germanShort'),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        settings.onLocaleChanged(Locale(value));
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
                    appLocalizations.translate('settings.downloadSection'),
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

class _AccountSection extends StatefulWidget {
  const _AccountSection({required this.authController});

  final AuthController authController;

  @override
  State<_AccountSection> createState() => _AccountSectionState();
}

class _AccountSectionState extends State<_AccountSection> {
  late final _serverController = TextEditingController(
    text: widget.authController.serverUrl?.toString() ?? '',
  );

  String? _serverError;

  AuthController get _auth => widget.authController;

  @override
  void dispose() {
    _serverController.dispose();
    super.dispose();
  }

  /// Saves the typed address, returns false if it is invalid.
  Future<bool> _saveServerUrl() async {
    try {
      await _auth.setServerUrl(_serverController.text);
      _serverController.text = _auth.serverUrl?.toString() ?? '';
      setState(() {
        _serverError = null;
      });
      return true;
    } on AuthException catch (e) {
      setState(() {
        _serverError = authErrorMessage(e);
      });
      return false;
    }
  }

  Future<void> _open(String location) async {
    if (await _saveServerUrl() && mounted) {
      context.push(location);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([_auth, _serverController]),
      builder: (context, _) {
        final session = _auth.session;
        final hasValidServer = parseServerUrl(_serverController.text) != null;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  appLocalizations.translate('settings.accountSection'),
                  style: theme.textTheme.titleLarge,
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: _serverController,
                  enabled: session == null,
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  onSubmitted: (_) => _saveServerUrl(),
                  onTapOutside: (_) {
                    FocusScope.of(context).unfocus();
                    _saveServerUrl();
                  },
                  decoration: InputDecoration(
                    labelText: appLocalizations.translate(
                      'settings.serverAddress',
                    ),
                    hintText: 'https://example.com',
                    helperText: session == null
                        ? null
                        : appLocalizations.translate(
                            'settings.serverLockedHint',
                          ),
                    errorText: _serverError,
                    border: const OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                if (session == null)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.login),
                          label: Text(appLocalizations.translate('auth.login')),
                          onPressed: hasValidServer
                              ? () => _open('/settings/login')
                              : null,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.person_add),
                          label: Text(
                            appLocalizations.translate('auth.register'),
                          ),
                          onPressed: hasValidServer
                              ? () => _open('/settings/register')
                              : null,
                        ),
                      ),
                    ],
                  )
                else ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      _auth.isOffline ? Icons.cloud_off : Icons.account_circle,
                    ),
                    title: Text(
                      '${appLocalizations.translate('settings.loggedInAs')} '
                      '${session.username}',
                    ),
                    subtitle: _auth.isOffline
                        ? Text(appLocalizations.translate('settings.offline'))
                        : null,
                  ),

                  const SizedBox(height: 8),

                  OutlinedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: Text(appLocalizations.translate('auth.logout')),
                    onPressed: _auth.isLoggingOut ? null : _auth.logout,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
