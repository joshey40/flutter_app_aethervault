import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../services/localization_service.dart';
import 'commander_adjust_box.dart';

class PlayerPanel extends StatefulWidget {
  final int index;
  final int life;
  final int quarterTurns;
  final void Function(int delta) onIncrement;
  final VoidCallback onReset;
  final int commanderTax;
  final void Function(int delta) onTaxChange;
  final VoidCallback? onCommanderPressed;
  final bool showCommanderOverlay;
  final VoidCallback? onCommanderOverlayTap;
  final List<int>? commanderDamageFromSource;
  final void Function(int delta, int slot)? onCommanderOverlayAdjust;
  final bool isCommanderTarget;
  final bool lost;
  final bool partnerEnabled;
  final ValueChanged<bool>? onPartnerChanged;
  final int partnerTax;
  final void Function(int delta)? onPartnerTaxChange;

  const PlayerPanel({
    super.key,
    required this.index,
    required this.life,
    required this.quarterTurns,
    required this.onIncrement,
    required this.onReset,
    required this.commanderTax,
    required this.onTaxChange,
    this.partnerEnabled = false,
    this.onPartnerChanged,
    this.partnerTax = 0,
    this.onPartnerTaxChange,
    this.onCommanderPressed,
    this.showCommanderOverlay = false,
    this.onCommanderOverlayTap,
    this.commanderDamageFromSource,
    this.onCommanderOverlayAdjust,
    this.isCommanderTarget = false,
    this.lost = false,
  });

  @override
  State<PlayerPanel> createState() => _PlayerPanelState();
}

class _PlayerPanelState extends State<PlayerPanel> {
  int _tempDelta = 0;
  Timer? _hideTimer;
  late bool _partnerEnabled;
  // No measurement keys — layout uses stretch behavior for equal heights

  void _handleIncrement(int delta) {
    setState(() {
      _tempDelta += delta;
    });
    widget.onIncrement(delta);
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 2), () {
      setState(() {
        _tempDelta = 0;
      });
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _partnerEnabled = widget.partnerEnabled;
  }

  @override
  void didUpdateWidget(covariant PlayerPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.partnerEnabled != oldWidget.partnerEnabled) {
      _partnerEnabled = widget.partnerEnabled;
    }
  }

  void _openSettingsDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(appLocalizations.translate('lifecounter.playerSettingsTitle').replaceAll('{index}', '${widget.index + 1}')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: Text(appLocalizations.translate('lifecounter.partner')),
                  value: _partnerEnabled,
                  onChanged: (v) {
                    setState(() {
                      _partnerEnabled = v;
                    });
                    widget.onPartnerChanged?.call(v);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(appLocalizations.translate('close')),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // No measurement or debug logging — use layout stretch for matching heights.

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: widget.lost
            ? Border.all(color: Theme.of(context).colorScheme.error.withAlpha((0.95 * 255).round()), width: 3)
            : null,
      ),
      child: RotatedBox(
        quarterTurns: widget.quarterTurns,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: LayoutBuilder(builder: (context, constraints) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left column: Settings
                      SizedBox(
                        width: 48,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Settings button (opens partner dialog)
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                alignment: Alignment.center,
                                icon: const Icon(Icons.settings, size: 20),
                                onPressed: _openSettingsDialog,
                              ),
                            ),
                            // Commander Tax box moved to left under settings
                            Expanded(
                              child: Center(
                                child: SizedBox(
                                  height: 120,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Theme.of(context).colorScheme.onSurface.withAlpha((0.12 * 255).round()), width: 1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Positioned.fill(
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () => widget.onTaxChange(2),
                                                  onLongPress: () => widget.onTaxChange(1),
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
                                                  onTap: () => widget.onTaxChange(-2),
                                                  onLongPress: () => widget.onTaxChange(-1),
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
                                        Center(child: Text('${widget.commanderTax}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 48,
                              height: 48,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Center life tracker
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(
                              height: 24,
                              child: Center(
                                  child: Text(appLocalizations.translate('lifecounter.playerLabel').replaceAll('{index}', '${widget.index + 1}'), style: Theme.of(context).textTheme.titleMedium),
                                ),
                            ),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Theme.of(context).colorScheme.onSurface.withAlpha((0.12 * 255).round()), width: 1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Positioned.fill(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              onTap: () => _handleIncrement(-1),
                                              onLongPress: () => _handleIncrement(-10),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                                  child: Text('-', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 20, color: Theme.of(context).colorScheme.onSurface.withAlpha((0.7 * 255).round()))),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              onTap: () => _handleIncrement(1),
                                              onLongPress: () => _handleIncrement(10),
                                              child: Align(
                                                alignment: Alignment.centerRight,
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                                  child: Text('+', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 20, color: Theme.of(context).colorScheme.onSurface.withAlpha((0.7 * 255).round()))),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Center(
                                      child: IgnorePointer(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text('${widget.life}', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 48), textAlign: TextAlign.center),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 24,
                              child: Center(
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 180),
                                  opacity: _tempDelta != 0 ? 1 : 0,
                                  child: Text(
                                    (_tempDelta > 0 ? '+$_tempDelta' : '$_tempDelta'),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: _tempDelta > 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 6),

                      // Right: Commander Tax with invisible top/bottom labels to reserve space
                      SizedBox(
                        width: 48,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            // Commander damage button moved to top-right
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                alignment: Alignment.center,
                                icon: const Icon(Icons.military_tech, size: 20),
                                onPressed: widget.onCommanderPressed,
                              ),
                            ),
                            widget.partnerEnabled
                                ? Expanded(
                                    child: Center(
                                      child: SizedBox(
                                        height: 120,
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Theme.of(context).colorScheme.onSurface.withAlpha((0.12 * 255).round()), width: 1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Positioned.fill(
                                                child: Column(
                                                  children: [
                                                    Expanded(
                                                      child: InkWell(
                                                        onTap: () => widget.onPartnerTaxChange?.call(2),
                                                        onLongPress: () => widget.onPartnerTaxChange?.call(1),
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
                                                        onTap: () => widget.onPartnerTaxChange?.call(-2),
                                                        onLongPress: () => widget.onPartnerTaxChange?.call(-1),
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
                                              Center(child: Text('${widget.partnerTax}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : const Expanded(child: SizedBox()),
                            SizedBox(
                              width: 48,
                              height: 48,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            if (widget.showCommanderOverlay)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: Material(
                    color: (widget.isCommanderTarget ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.tertiary).withAlpha((0.70 * 255).round()),
                    child: InkWell(
                      onTap: widget.onCommanderOverlayTap,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(30),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Primary commander box
                              CommanderAdjustBox(
                                value: widget.commanderDamageFromSource != null && widget.commanderDamageFromSource!.isNotEmpty ? widget.commanderDamageFromSource![0] : 0,
                                onIncrement: () => widget.onCommanderOverlayAdjust?.call(1, 0),
                                onDecrement: () => widget.onCommanderOverlayAdjust?.call(-1, 0),
                                onLongIncrement: () => widget.onCommanderOverlayAdjust?.call(5, 0),
                                onLongDecrement: () => widget.onCommanderOverlayAdjust?.call(-5, 0),
                              ),
                              if (widget.partnerEnabled) const SizedBox(width: 16),
                              if (widget.partnerEnabled)
                                CommanderAdjustBox(
                                  value: widget.commanderDamageFromSource != null && widget.commanderDamageFromSource!.length > 1 ? widget.commanderDamageFromSource![1] : 0,
                                  onIncrement: () => widget.onCommanderOverlayAdjust?.call(1, 1),
                                  onDecrement: () => widget.onCommanderOverlayAdjust?.call(-1, 1),
                                  onLongIncrement: () => widget.onCommanderOverlayAdjust?.call(5, 1),
                                  onLongDecrement: () => widget.onCommanderOverlayAdjust?.call(-5, 1),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
