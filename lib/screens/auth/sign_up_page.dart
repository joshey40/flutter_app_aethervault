import 'package:flutter/material.dart';

import '../../models/vault_user.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/localization_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({
    super.key,
    required this.authService,
    required this.onLoginTap,
    required this.onSignUpSuccess,
  });

  final FirebaseAuthService authService;
  final VoidCallback onLoginTap;
  final ValueChanged<VaultUser> onSignUpSuccess;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

    final result = await widget.authService.signUp(
      displayName: _displayNameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    if (result.success && result.user != null) {
      widget.onSignUpSuccess(result.user!);
      return;
    }

    setState(() {
      _errorText = appLocalizations.translate(result.errorKey ?? 'errors.emptyFields');
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
              theme.colorScheme.secondary.withValues(alpha: 0.15),
              theme.scaffoldBackgroundColor,
              theme.colorScheme.primary.withValues(alpha: 0.10),
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
                            appLocalizations.translate('auth.createAccountTitle'),
                            style: theme.textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            appLocalizations.translate('auth.createAccountSubtitle'),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _displayNameController,
                            decoration: InputDecoration(labelText: appLocalizations.translate('auth.displayName')),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return appLocalizations.translate('errors.emptyFields');
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
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
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(labelText: appLocalizations.translate('auth.confirmPassword')),
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
                            onPressed: _isSubmitting ? null : _submit,
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(appLocalizations.translate('auth.signUpAction')),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _isSubmitting ? null : widget.onLoginTap,
                            child: Text(appLocalizations.translate('auth.switchToSignIn')),
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
