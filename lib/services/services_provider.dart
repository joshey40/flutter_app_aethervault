import 'package:flutter/widgets.dart';

/// Inherited widget that exposes app-wide services to the widget tree.
class ServicesProvider extends InheritedWidget {
  const ServicesProvider({
    super.key,
    required super.child,
  });

  static ServicesProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ServicesProvider>();
  }

  @override
  bool updateShouldNotify(covariant ServicesProvider oldWidget) {
    return false;
  }
}
