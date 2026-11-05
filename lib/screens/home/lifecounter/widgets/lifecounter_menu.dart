import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

class LifecounterMenuItem {
  const LifecounterMenuItem({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  /// Highlights toggles that are currently switched on.
  final bool active;
}

/// Round menu button that rests at [anchor] and, when tapped, moves to
/// [openCenter] and opens [items] as a ring of icons around it. Icons read
/// the same from every seat at the table.
///
/// Fills its parent, which both positions refer to.
class LifecounterMenu extends StatefulWidget {
  const LifecounterMenu({
    super.key,
    required this.anchor,
    required this.openCenter,
    required this.items,
    required this.tooltip,
  });

  /// Where the closed button sits.
  final Offset anchor;

  /// Where the button and the ring go while the menu is open.
  final Offset openCenter;
  final List<LifecounterMenuItem> items;
  final String tooltip;

  @override
  State<LifecounterMenu> createState() => _LifecounterMenuState();
}

class _LifecounterMenuState extends State<LifecounterMenu> {
  static const _buttonSize = 44.0;
  static const _itemSize = 48.0;
  static const _radius = 76.0;
  static const _duration = Duration(milliseconds: 160);

  bool _open = false;

  void _toggle() => setState(() => _open = !_open);

  void _select(LifecounterMenuItem item) {
    setState(() => _open = false);
    item.onPressed();
  }

  /// Moves the ring away from the edges so every icon stays on screen.
  Offset _ringCenter(Size size) {
    const margin = _radius + _itemSize / 2 + 4;
    double clamp(double value, double max) =>
        max < 2 * margin ? max / 2 : value.clamp(margin, max - margin);
    return Offset(
      clamp(widget.openCenter.dx, size.width),
      clamp(widget.openCenter.dy, size.height),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final ringCenter = _ringCenter(size);
        final buttonCenter = _open ? ringCenter : widget.anchor;
        final count = widget.items.length;

        return Stack(
          children: [
            // Dims the table, a tap outside the ring closes the menu.
            IgnorePointer(
              ignoring: !_open,
              child: AnimatedOpacity(
                opacity: _open ? 1 : 0,
                duration: _duration,
                child: GestureDetector(
                  onTap: _toggle,
                  child: const ColoredBox(
                    color: Colors.black54,
                    child: SizedBox.expand(),
                  ),
                ),
              ),
            ),

            for (var i = 0; i < count; i++)
              _positioned(
                // Starts at the top and goes around clockwise.
                ringCenter +
                    Offset.fromDirection(
                      -math.pi / 2 + 2 * math.pi * i / count,
                      _radius,
                    ),
                _itemSize,
                IgnorePointer(
                  ignoring: !_open,
                  child: AnimatedScale(
                    scale: _open ? 1 : 0,
                    duration: _duration,
                    curve: Curves.easeOutBack,
                    child: _RoundButton(
                      size: _itemSize,
                      icon: widget.items[i].icon,
                      tooltip: widget.items[i].label,
                      color: widget.items[i].active
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surface,
                      iconColor: widget.items[i].active
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurface,
                      onPressed: () => _select(widget.items[i]),
                    ),
                  ),
                ),
              ),

            AnimatedPositioned(
              duration: _duration,
              curve: Curves.easeOut,
              left: buttonCenter.dx - _buttonSize / 2,
              top: buttonCenter.dy - _buttonSize / 2,
              width: _buttonSize,
              height: _buttonSize,
              child: _RoundButton(
                key: const Key('lifecounterMenuButton'),
                size: _buttonSize,
                icon: _open ? Icons.close : Icons.menu,
                tooltip: widget.tooltip,
                color: theme.colorScheme.surface,
                iconColor: theme.colorScheme.onSurface,
                onPressed: _toggle,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _positioned(Offset center, double size, Widget child) {
    return Positioned(
      left: center.dx - size / 2,
      top: center.dy - size / 2,
      width: size,
      height: size,
      child: child,
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    super.key,
    required this.size,
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.iconColor,
    required this.onPressed,
  });

  final double size;
  final IconData icon;
  final String tooltip;
  final Color color;
  final Color iconColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: CircleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(60),
        ),
      ),
      elevation: 2,
      child: IconButton(
        iconSize: size * 0.45,
        icon: Icon(icon, color: iconColor),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }
}
