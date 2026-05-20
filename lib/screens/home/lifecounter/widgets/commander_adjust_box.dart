import 'package:flutter/material.dart';

class CommanderAdjustBox extends StatelessWidget {
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onLongIncrement;
  final VoidCallback onLongDecrement;

  const CommanderAdjustBox({
    super.key,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
    required this.onLongIncrement,
    required this.onLongDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 120,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Theme.of(context).colorScheme.onSurface.withAlpha((0.12 * 255).round()), width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Column(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: onIncrement,
                        onLongPress: onLongIncrement,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Text('+', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: onDecrement,
                        onLongPress: onLongDecrement,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Text('-', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Center(child: Text('$value', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
            ],
          ),
        ),
      ),
    );
  }
}
