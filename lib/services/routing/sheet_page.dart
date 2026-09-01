import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Page<void> buildSheetPage({required LocalKey key, required Widget child}) {
  return CustomTransitionPage<void>(
    key: key,
    opaque: false,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return SlideTransition(position: slide, child: child);
    },
  );
}