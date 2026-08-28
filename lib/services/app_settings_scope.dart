import 'package:flutter/material.dart';

class AppSettingsScope extends InheritedWidget {
  const AppSettingsScope({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.locale,
    required this.onLocaleChanged,
    required super.child,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  final Locale locale;
  final Future<void> Function(Locale locale) onLocaleChanged;

  static AppSettingsScope of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<AppSettingsScope>();

    assert(
      result != null,
      'No AppSettingsScope found in context.',
    );

    return result!;
  }

  @override
  bool updateShouldNotify(AppSettingsScope oldWidget) {
    return themeMode != oldWidget.themeMode ||
        locale != oldWidget.locale;
  }
}