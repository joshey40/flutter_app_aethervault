import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth/auth_api_client.dart';
import '../../services/auth/auth_controller.dart';
import '../../services/localization_service.dart';
import 'auth_error_message.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordRepeatController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordRepeatController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) {
      return;
    }

    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _error = appLocalizations.translate('auth.errors.emptyFields');
      });
      return;
    }
    if (password != _passwordRepeatController.text) {
      setState(() {
        _error = appLocalizations.translate('auth.errors.passwordMismatch');
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await widget.authController.register(username, password);
      if (mounted) {
        context.pop();
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _error = authErrorMessage(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(appLocalizations.translate('auth.register'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              appLocalizations.translate('auth.registerTitle'),
              style: theme.textTheme.headlineMedium,
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _usernameController,
              autofillHints: const [AutofillHints.newUsername],
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: appLocalizations.translate('auth.username'),
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              autofillHints: const [AutofillHints.newPassword],
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: appLocalizations.translate('auth.password'),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _passwordRepeatController,
              obscureText: _obscurePassword,
              autofillHints: const [AutofillHints.newPassword],
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: appLocalizations.translate('auth.passwordRepeat'),
                border: const OutlineInputBorder(),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],

            const SizedBox(height: 24),

            FilledButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(appLocalizations.translate('auth.register')),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () {
                context.pushReplacement('/settings/login');
              },
              child: Text(appLocalizations.translate('auth.haveAccount')),
            ),
          ],
        ),
      ),
    );
  }
}
