import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CardDetailSheetScaffold extends StatelessWidget {
  const CardDetailSheetScaffold({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.pop(),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: FractionallySizedBox(
              heightFactor: 0.85,
              widthFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  border: Border(top: BorderSide(color: colorScheme.outline)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 36, height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.outline,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(child: child),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}