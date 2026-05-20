// ignore_for_file: use_build_context_synchronously, unused_element_parameter
import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../../services/localization_service.dart';

Future<void> showRandomPicker(BuildContext context, {int? maxPlayers}) async {
  final loc = appLocalizations;
  final selection = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(loc.translate('lifecounter.random') != 'lifecounter.random' ? loc.translate('lifecounter.random') : 'Flip / Roll'),
      content: SizedBox(
        width: 360,
        height: 300,
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: [
                  _diceButton(ctx, 'coin', Icons.monetization_on, loc.translate('lifecounter.random.coin') != 'lifecounter.random.coin' ? loc.translate('lifecounter.random.coin') : 'Coin'),
                  _diceButton(ctx, 'd4', Icons.casino, 'd4'),
                  _diceButton(ctx, 'd6', Icons.casino, 'd6'),
                  _diceButton(ctx, 'd8', Icons.casino, 'd8'),
                  _diceButton(ctx, 'd10', Icons.casino, 'd10'),
                  _diceButton(ctx, 'd12', Icons.casino, 'd12'),
                  _diceButton(ctx, 'd20', Icons.casino, 'd20'),
                  _diceButton(ctx, 'player', Icons.person, loc.translate('lifecounter.random.player') != 'lifecounter.random.player' ? loc.translate('lifecounter.random.player') : 'Player'),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(ctx).pop(null),
                child: Text(loc.translate('cancel') != 'cancel' ? loc.translate('cancel') : 'Cancel'),
              ),
            )
          ],
        ),
      ),
    ),
  );

  if (selection == null) return;

  if (selection == 'coin') {
    String result = math.Random().nextBool()
        ? (loc.translate('coin.heads') != 'coin.heads' ? loc.translate('coin.heads') : 'Heads')
        : (loc.translate('coin.tails') != 'coin.tails' ? loc.translate('coin.tails') : 'Tails');
    bool flash = false;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
        return AlertDialog(
          content: _polygonBadge('coin', result, textColor: flash ? Theme.of(ctx).colorScheme.primary : null),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  result = math.Random().nextBool()
                      ? (loc.translate('coin.heads') != 'coin.heads' ? loc.translate('coin.heads') : 'Heads')
                      : (loc.translate('coin.tails') != 'coin.heads' ? loc.translate('coin.tails') : 'Tails');
                  flash = true;
                });
                Future.delayed(const Duration(milliseconds: 320), () {
                  try {
                    setState(() {
                      flash = false;
                    });
                  } catch (_) {}
                });
              },
                child: Text(loc.translate('lifecounter.random.rollAgain') != 'lifecounter.random.rollAgain' ? loc.translate('lifecounter.random.rollAgain') : 'Roll again'),
            ),
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(loc.translate('ok') != 'ok' ? loc.translate('ok') : 'OK')),
          ],
        );
      }),
    );
    return;
  }

  if (selection == 'player') {
    // Pick a random player between 1 and maxPlayers (defaults to 6)
    final max = maxPlayers ?? 6;
    int starter = math.Random().nextInt(max) + 1;
    bool flash = false;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
        return AlertDialog(
          content: _polygonBadge('d20', 'P$starter', textColor: flash ? Theme.of(ctx).colorScheme.primary : null),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  starter = math.Random().nextInt(max) + 1;
                  flash = true;
                });
                Future.delayed(const Duration(milliseconds: 320), () {
                  try {
                    setState(() {
                      flash = false;
                    });
                  } catch (_) {}
                });
              },
              child: Text(loc.translate('lifecounter.random.rollAgain') != 'lifecounter.random.rollAgain' ? loc.translate('lifecounter.random.rollAgain') : 'Roll again'),
            ),
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(loc.translate('ok') != 'ok' ? loc.translate('ok') : 'OK')),
          ],
        );
      }),
    );
    return;
  }

  final sides = int.tryParse(selection.substring(1)) ?? 6;
  int roll() => math.Random().nextInt(sides) + 1;
  int value = roll();
  bool flash = false;
  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _polygonBadge(selection, '$value', textColor: flash ? Theme.of(ctx).colorScheme.primary : null),
            const SizedBox(height: 12),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                value = roll();
                flash = true;
              });
              Future.delayed(const Duration(milliseconds: 320), () {
                try {
                  setState(() {
                    flash = false;
                  });
                } catch (_) {}
              });
            },
            child: Text(loc.translate('lifecounter.random.rollAgain') != 'lifecounter.random.rollAgain' ? loc.translate('lifecounter.random.rollAgain') : 'Roll again'),
          ),
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(loc.translate('ok') != 'ok' ? loc.translate('ok') : 'OK')),
        ],
      );
    }),
  );
}

Widget _diceButton(BuildContext ctx, String value, IconData icon, String label) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.all(8),
      minimumSize: const Size(88, 88),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    onPressed: () => Navigator.of(ctx).pop(value),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 40, height: 40, child: _PolygonIcon(forValue: value, useOnPrimary: true)),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );
}

Widget _polygonBadge(String value, String display, {Color? textColor}) {
  return SizedBox(
    width: 220,
    height: 220,
    child: Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          _PolygonIcon(forValue: value, size: 200),
          Builder(builder: (ctx) {
            final color = textColor ?? Theme.of(ctx).textTheme.headlineLarge?.color ?? Theme.of(ctx).colorScheme.onSurface;
            return AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: color),
              child: Text(display),
            );
          }),
        ],
      ),
    ),
  );
}

class _PolygonIcon extends StatelessWidget {
  final String forValue;
  final double size;
  final bool useOnPrimary;
  const _PolygonIcon({super.key, required this.forValue, this.size = 40, this.useOnPrimary = false});

  int _sidesFor(String v) {
    switch (v) {
      case 'd4':
        return 3;
      case 'd6':
        return 4;
      case 'd8':
        return 6;
      case 'd10':
        return 4; // diamond (rotated square)
      case 'd12':
        return 10; // as requested 'Zehneck'
      case 'd20':
        return 6; // hexagon per request
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sides = _sidesFor(forValue);
    final baseColor = useOnPrimary ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface;
    if (forValue == 'coin') {
      return CustomPaint(size: Size(size, size), painter: _CirclePainter(color: baseColor));
    }
    if (forValue == 'player') {
      return Icon(Icons.person, color: baseColor, size: size * 0.9);
    }
    // Choose rotation per dice type: d6 should be axis-aligned square, d10 a diamond.
    double rotation = -math.pi / 2;
    if (forValue == 'd6') rotation = -math.pi / 4; // rotate so sides are flat
    if (forValue == 'd10') rotation = -math.pi / 2; // diamond
    return CustomPaint(
      size: Size(size, size),
      painter: _PolygonPainter(sides: sides, color: baseColor, rotation: rotation),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final Color color;
  _CirclePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withAlpha((0.28 * 255).round());
    final stroke = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 3.0;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2 - 2, paint);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2 - 2, stroke);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PolygonPainter extends CustomPainter {
  final int sides;
  final Color color;
  final double rotation;
  _PolygonPainter({required this.sides, required this.color, this.rotation = -math.pi / 2});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    final path = Path();
    if (sides <= 0) return;
    final rotationOffset = rotation;
    for (int i = 0; i < sides; i++) {
      final angle = (i / sides) * 2 * math.pi + rotationOffset;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    final fill = Paint()..color = color.withAlpha((0.28 * 255).round());
    final stroke = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 3.0;
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
