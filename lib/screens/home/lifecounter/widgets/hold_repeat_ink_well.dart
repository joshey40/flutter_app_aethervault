import 'dart:async';

import 'package:material_ui/material_ui.dart';

/// An [InkWell] whose long press keeps firing while the finger stays down.
///
/// [onLongPress] is called once when the long press is recognized and then
/// again every [repeatInterval] until the pointer is released or cancelled.
class HoldRepeatInkWell extends StatefulWidget {
  const HoldRepeatInkWell({
    super.key,
    required this.onTap,
    required this.onLongPress,
    this.repeatInterval = const Duration(milliseconds: 500),
    required this.child,
  });

  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Duration repeatInterval;
  final Widget child;

  @override
  State<HoldRepeatInkWell> createState() => _HoldRepeatInkWellState();
}

class _HoldRepeatInkWellState extends State<HoldRepeatInkWell> {
  Timer? _repeatTimer;

  void _startRepeating() {
    widget.onLongPress();
    _repeatTimer?.cancel();
    _repeatTimer = Timer.periodic(
      widget.repeatInterval,
      (_) => widget.onLongPress(),
    );
  }

  void _stopRepeating() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  @override
  void dispose() {
    _stopRepeating();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // InkWell reports no end of a long press, the Listener catches the release
    // without taking part in the gesture arena.
    return Listener(
      onPointerUp: (_) => _stopRepeating(),
      onPointerCancel: (_) => _stopRepeating(),
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: _startRepeating,
        child: widget.child,
      ),
    );
  }
}
