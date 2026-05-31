import 'package:flutter/widgets.dart';

import 'app_preferences_storage.dart';
import 'firebase_auth_service.dart';

/// Inherited widget that exposes app-wide services to the widget tree.
class ServicesProvider extends InheritedWidget {
  const ServicesProvider({
    super.key,
    required this.preferencesStorage,
    required this.authService,
    required super.child,
  });

  final AppPreferencesStorage preferencesStorage;
  final FirebaseAuthService authService;

  static ServicesProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ServicesProvider>();
  }

  @override
  bool updateShouldNotify(covariant ServicesProvider oldWidget) {
    return preferencesStorage != oldWidget.preferencesStorage || authService != oldWidget.authService;
  }
}
