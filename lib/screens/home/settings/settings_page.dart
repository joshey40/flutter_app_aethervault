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

  /// Saves and checks the typed address, unless it is already the saved one.
  Future<void> _saveServerUrl() async {
    final text = _serverController.text;
    final unchanged = text.trim().isEmpty
        ? _auth.serverUrl == null
        : parseServerUrl(text) == _auth.serverUrl;
    if (unchanged && _serverError == null) {
      return;
    }

    try {
      await _auth.setServerUrl(text);
      if (!mounted) {
        return;
      }
      _serverController.text = _auth.serverUrl?.toString() ?? '';
      setState(() {
        _serverError = null;
      });
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _serverError = authErrorMessage(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([_auth, _serverController]),
      builder: (context, _) {
        final session = _auth.session;
        // Only a saved address that was checked successfully allows login.
        final canAuthenticate =
            _auth.serverStatus == ServerStatus.connected &&
            parseServerUrl(_serverController.text) == _auth.serverUrl;

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

                if (_auth.serverStatus != ServerStatus.none) ...[
                  const SizedBox(height: 12),
                  _ConnectionStatus(authController: _auth),
                ],

                const SizedBox(height: 16),

                if (session == null)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.login),
                          label: Text(appLocalizations.translate('auth.login')),
                          onPressed: canAuthenticate
                              ? () => context.push('/settings/login')
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
                          onPressed: canAuthenticate
                              ? () => context.push('/settings/register')
                              : null,
                        ),
                      ),
                    ],
                  )
                else ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.account_circle),
                    title: Text(
                      '${appLocalizations.translate('settings.loggedInAs')} '
                      '${session.username}',
                    ),
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

/// Shows whether the app can reach the configured server.
class _ConnectionStatus extends StatelessWidget {
  const _ConnectionStatus({required this.authController});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = authController.serverStatus;
    final server =
        (authController.session?.server ?? authController.serverUrl)
            ?.toString() ??
        '';

    final (IconData icon, Color color, String key) = switch (status) {
      ServerStatus.connected => (
        Icons.cloud_done,
        theme.colorScheme.primary,
        'connected',
      ),
      ServerStatus.unreachable => (
        Icons.cloud_off,
        theme.colorScheme.error,
        'unreachable',
      ),
      ServerStatus.notAethervault => (
        Icons.error_outline,
        theme.colorScheme.error,
        'notAethervault',
      ),
      ServerStatus.checking => (
        Icons.sync,
        theme.colorScheme.onSurfaceVariant,
        'checking',
      ),
      ServerStatus.unknown || ServerStatus.none => (
        Icons.help_outline,
        theme.colorScheme.onSurfaceVariant,
        'unknown',
      ),
    };

    return Row(
      children: [
        if (status == ServerStatus.checking)
          const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          Icon(icon, color: color, size: 20),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            appLocalizations
                .translate('settings.connection.$key')
                .replaceAll('{server}', server),
            style: theme.textTheme.bodyMedium?.copyWith(color: color),
          ),
        ),

        if (status != ServerStatus.checking && status != ServerStatus.connected)
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: appLocalizations.translate('settings.connection.retry'),
            onPressed: authController.checkConnection,
          ),
      ],
    );
  }
}
