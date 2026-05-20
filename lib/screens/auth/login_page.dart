import 'package:flutter/material.dart';

import '../../models/vault_user.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/localization_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.authService,
    required this.onSignUpTap,
    required this.onSignInSuccess,
  });

  final FirebaseAuthService authService;
  final VoidCallback onSignUpTap;
  final ValueChanged<VaultUser> onSignInSuccess;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final result = await widget.authService.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    if (result.success && result.user != null) {
      widget.onSignInSuccess(result.user!);
      return;
    }

    setState(() {
      _errorText = appLocalizations.translate(result.errorKey ?? 'errors.invalidCredentials');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.15),
              theme.scaffoldBackgroundColor,
              theme.colorScheme.secondary.withValues(alpha: 0.12),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            appLocalizations.translate('app.name'),
                            style: theme.textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            appLocalizations.translate('app.subtitle'),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(labelText: appLocalizations.translate('auth.email')),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return appLocalizations.translate('errors.emptyFields');
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(labelText: appLocalizations.translate('auth.password')),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return appLocalizations.translate('errors.emptyFields');
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: _errorText == null
                                ? const SizedBox.shrink()
                                : Padding(
                                    key: const ValueKey('error'),
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      _errorText!,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.error,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(minimumSize: const Size(120, 44)),
                            onPressed: _isSubmitting ? null : _submit,
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(appLocalizations.translate('auth.signInAction')),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            style: TextButton.styleFrom(minimumSize: const Size(80, 40)),
                            onPressed: _isSubmitting ? null : widget.onSignUpTap,
                            child: Text(appLocalizations.translate('auth.switchToSignUp')),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
