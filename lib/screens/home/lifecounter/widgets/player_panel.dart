import 'dart:async';
import 'package:flutter/material.dart';
import 'package:icons_flutter/icons_flutter.dart';
import '../../../../../services/localization_service.dart';
import '../../../../../services/life_counter/lifecounter_model.dart';
import 'commander_adjust_box.dart';

class _PanelColorOption {
  final String key;
  final String label;
  final Color color;
  final Color onColor;

  const _PanelColorOption({
    required this.key,
    required this.label,
    required this.color,
    required this.onColor,
  });
}

class _CounterDefinition {
  final String localizationKey;
  final IconData icon;

  const _CounterDefinition(this.localizationKey, this.icon);
}

const _counterDefinitions = <_CounterDefinition>[
  _CounterDefinition('lifecounter.counterPoison', RpgAwesome.skull),
  _CounterDefinition('lifecounter.counterEnergy', Icons.bolt),
  _CounterDefinition(
    'lifecounter.counterExperience',
    MaterialCommunityIcons.star_circle,
  ),
  _CounterDefinition(
    'lifecounter.counterRadiation',
    MaterialCommunityIcons.radioactive,
  ),
  _CounterDefinition('lifecounter.counterAcorn', RpgAwesome.acorn),
  _CounterDefinition(
    'lifecounter.counterTicket',
    MaterialCommunityIcons.ticket_confirmation,
  ),
];

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
  final String playerName;
  final String panelColor;
  final List<int> counters;
  final void Function(int counterIndex, int delta)? onCounterChange;
  final bool isMonarch;
  final VoidCallback? onMonarchPressed;
  final ValueChanged<String>? onPlayerNameChanged;
  final ValueChanged<String>? onPanelColorChanged;

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
    this.playerName = '',
    this.panelColor = 'default',
    this.counters = const [0, 0, 0, 0, 0, 0],
    this.onCounterChange,
    this.isMonarch = false,
    this.onMonarchPressed,
    this.onPlayerNameChanged,
    this.onPanelColorChanged,
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
  Timer? _clearDeltaTimer;
  bool _isTempDeltaVisible = false;
  bool _showCounters = false;
  late bool _partnerEnabled;
  // No measurement keys, layout uses stretch behavior for equal heights

  void _handleIncrement(int delta) {
    _hideTimer?.cancel();
    _clearDeltaTimer?.cancel();
    setState(() {
      _tempDelta += delta;
      _isTempDeltaVisible = true;
    });
    widget.onIncrement(delta);
    _hideTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isTempDeltaVisible = false;
      });
      _clearDeltaTimer = Timer(const Duration(milliseconds: 180), () {
        if (!mounted) return;
        setState(() {
          _tempDelta = 0;
        });
      });
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _clearDeltaTimer?.cancel();
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

  Future<void> _openSettingsDialog() async {
    final nameController = TextEditingController(text: widget.playerName);
    var selectedColor = lifecounterPanelColorKeys.contains(widget.panelColor)
        ? widget.panelColor
        : 'default';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              title: Text(
                appLocalizations
                    .translate('lifecounter.playerSettingsTitle')
                    .replaceAll('{index}', '${widget.index + 1}'),
              ),
              content: SizedBox(
                width: 360,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        maxLength: 8,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: appLocalizations.translate(
                            'lifecounter.playerName',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          appLocalizations.translate(
                            'lifecounter.panelBackground',
                          ),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: _panelColorOptions(context).map((option) {
                          final selected = selectedColor == option.key;
                          return Tooltip(
                            message: option.label,
                            child: Semantics(
                              label: option.label,
                              selected: selected,
                              button: true,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  setDialogState(() {
                                    selectedColor = option.key;
                                  });
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: option.color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: selected
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withAlpha(70),
                                      width: selected ? 3 : 1,
                                    ),
                                  ),
                                  child: selected
                                      ? Icon(
                                          Icons.check,
                                          size: 16,
                                          color: option.onColor,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: Text(
                          appLocalizations.translate('lifecounter.partner'),
                        ),
                        value: _partnerEnabled,
                        onChanged: (v) {
                          setDialogState(() {
                            _partnerEnabled = v;
                          });
                          widget.onPartnerChanged?.call(v);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    widget.onPlayerNameChanged?.call(
                      nameController.text.trim(),
                    );
                    widget.onPanelColorChanged?.call(selectedColor);
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(appLocalizations.translate('save')),
                ),
              ],
            );
          },
        );
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      nameController.dispose();
    });
  }

  List<_PanelColorOption> _panelColorOptions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      _PanelColorOption(
        key: 'default',
        label: appLocalizations.translate('lifecounter.colorDefault'),
        color: Theme.of(context).colorScheme.surface,
        onColor: Theme.of(context).colorScheme.onSurface,
      ),
      _PanelColorOption(
        key: 'green',
        label: appLocalizations.translate('lifecounter.colorGreen'),
        color: isDark ? const Color(0xFF1D4D35) : const Color(0xFFD9F0DE),
        onColor: isDark ? Colors.white : const Color(0xFF173D27),
      ),
      _PanelColorOption(
        key: 'blue',
        label: appLocalizations.translate('lifecounter.colorBlue'),
        color: isDark ? const Color(0xFF1E4468) : const Color(0xFFDCEBFA),
        onColor: isDark ? Colors.white : const Color(0xFF173653),
      ),
      _PanelColorOption(
        key: 'red',
        label: appLocalizations.translate('lifecounter.colorRed'),
        color: isDark ? const Color(0xFF5A2929) : const Color(0xFFF8DDDD),
        onColor: isDark ? Colors.white : const Color(0xFF4B1D1D),
      ),
      _PanelColorOption(
        key: 'purple',
        label: appLocalizations.translate('lifecounter.colorPurple'),
        color: isDark ? const Color(0xFF49305E) : const Color(0xFFE9DDF5),
        onColor: isDark ? Colors.white : const Color(0xFF362344),
      ),
      _PanelColorOption(
        key: 'orange',
        label: appLocalizations.translate('lifecounter.colorOrange'),
        color: isDark ? const Color(0xFF67421F) : const Color(0xFFFCE5C7),
        onColor: isDark ? Colors.white : const Color(0xFF4A2C12),
      ),
    ];
  }

  Color? _panelBackgroundColor(BuildContext context) {
    if (widget.panelColor == 'default' ||
        !lifecounterPanelColorKeys.contains(widget.panelColor)) {
      return null;
    }
    return _panelColorOptions(
      context,
    ).firstWhere((option) => option.key == widget.panelColor).color;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: widget.lost
            ? Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.error.withAlpha((0.95 * 255).round()),
                width: 3,
              )
            : null,
      ),
      child: RotatedBox(
        quarterTurns: widget.quarterTurns,
        child: Card(
          color: _panelBackgroundColor(context),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      // Left column: Settings
                      // Center: Life tracker
                      // Right column: Commander Tax
                      children: [
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
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 6.0,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withAlpha((0.12 * 255).round()),
                                          width: 1,
                                        ),
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
                                                    onTap: () =>
                                                        widget.onTaxChange(2),
                                                    onLongPress: () =>
                                                        widget.onTaxChange(1),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.topCenter,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 6.0,
                                                            ),
                                                        child: Text(
                                                          '+',
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .titleMedium
                                                              ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () =>
                                                        widget.onTaxChange(-2),
                                                    onLongPress: () =>
                                                        widget.onTaxChange(-1),
                                                    child: Align(
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 6.0,
                                                            ),
                                                        child: Text(
                                                          '-',
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .titleMedium
                                                              ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Center(
                                            child: Text(
                                              '${widget.commanderTax}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 48,
                                height: 48,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    RpgAwesome.crown,
                                    size: 20,
                                    color: widget.isMonarch
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.secondary
                                        : null,
                                  ),
                                  tooltip: appLocalizations.translate(
                                    'lifecounter.monarch',
                                  ),
                                  onPressed: widget.onMonarchPressed,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SizedBox(
                                height: 24,
                                child: Center(
                                  child: Text(
                                    widget.playerName.trim().isEmpty
                                        ? appLocalizations
                                              .translate(
                                                'lifecounter.playerLabel',
                                              )
                                              .replaceAll(
                                                '{index}',
                                                '${widget.index + 1}',
                                              )
                                        : widget.playerName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: widget.isMonarch
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.secondary
                                              : null,
                                          fontWeight: widget.isMonarch
                                              ? FontWeight.bold
                                              : null,
                                        ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6.0,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withAlpha((0.12 * 255).round()),
                                      width: 1,
                                    ),
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
                                                onTap: () =>
                                                    _handleIncrement(-1),
                                                onLongPress: () =>
                                                    _handleIncrement(-10),
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12.0,
                                                        ),
                                                    child: Text(
                                                      '-',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20,
                                                            color: Theme.of(context)
                                                                .colorScheme
                                                                .onSurface
                                                                .withAlpha(
                                                                  (0.7 * 255)
                                                                      .round(),
                                                                ),
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: InkWell(
                                                onTap: () =>
                                                    _handleIncrement(1),
                                                onLongPress: () =>
                                                    _handleIncrement(10),
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12.0,
                                                        ),
                                                    child: Text(
                                                      '+',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20,
                                                            color: Theme.of(context)
                                                                .colorScheme
                                                                .onSurface
                                                                .withAlpha(
                                                                  (0.7 * 255)
                                                                      .round(),
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
                                      Center(
                                        child: IgnorePointer(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              '${widget.life}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 48,
                                                    color: widget.isMonarch
                                                        ? Theme.of(context)
                                                              .colorScheme
                                                              .secondary
                                                        : null,
                                                  ),
                                              textAlign: TextAlign.center,
                                            ),
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
                                    opacity: _isTempDeltaVisible ? 1 : 0,
                                    child: Text(
                                      (_tempDelta > 0
                                          ? '+$_tempDelta'
                                          : '$_tempDelta'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: _tempDelta > 0
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
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
                                  icon: const Icon(
                                    MaterialCommunityIcons.target,
                                    size: 20,
                                  ),
                                  tooltip: appLocalizations.translate(
                                    'lifecounter.commanderDamage',
                                  ),
                                  onPressed: widget.onCommanderPressed,
                                ),
                              ),
                              widget.partnerEnabled
                                  ? Expanded(
                                      child: Center(
                                        child: SizedBox(
                                          height: 120,
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 6.0,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withAlpha(
                                                      (0.12 * 255).round(),
                                                    ),
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Positioned.fill(
                                                  child: Column(
                                                    children: [
                                                      Expanded(
                                                        child: InkWell(
                                                          onTap: () => widget
                                                              .onPartnerTaxChange
                                                              ?.call(2),
                                                          onLongPress: () => widget
                                                              .onPartnerTaxChange
                                                              ?.call(1),
                                                          child: Align(
                                                            alignment: Alignment
                                                                .topCenter,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    vertical:
                                                                        6.0,
                                                                  ),
                                                              child: Text(
                                                                '+',
                                                                style: Theme.of(context)
                                                                    .textTheme
                                                                    .titleMedium
                                                                    ?.copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: InkWell(
                                                          onTap: () => widget
                                                              .onPartnerTaxChange
                                                              ?.call(-2),
                                                          onLongPress: () => widget
                                                              .onPartnerTaxChange
                                                              ?.call(-1),
                                                          child: Align(
                                                            alignment: Alignment
                                                                .bottomCenter,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    vertical:
                                                                        6.0,
                                                                  ),
                                                              child: Text(
                                                                '-',
                                                                style: Theme.of(context)
                                                                    .textTheme
                                                                    .titleMedium
                                                                    ?.copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Center(
                                                  child: Text(
                                                    '${widget.partnerTax}',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                ),
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
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                    MaterialCommunityIcons.counter,
                                    size: 20,
                                  ),
                                  tooltip: appLocalizations.translate(
                                    'lifecounter.counters',
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showCounters = !_showCounters;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              if (widget.showCommanderOverlay)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(220),
                        border: widget.isCommanderTarget
                            ? Border.all(
                                color: const Color(0xFF8B1E2D),
                                width: 5,
                              )
                            : null,
                      ),
                      child: Material(
                        color: Colors.transparent,
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
                                    value:
                                        widget.commanderDamageFromSource !=
                                                null &&
                                            widget
                                                .commanderDamageFromSource!
                                                .isNotEmpty
                                        ? widget.commanderDamageFromSource![0]
                                        : 0,
                                    onIncrement: () => widget
                                        .onCommanderOverlayAdjust
                                        ?.call(1, 0),
                                    onDecrement: () => widget
                                        .onCommanderOverlayAdjust
                                        ?.call(-1, 0),
                                    onLongIncrement: () => widget
                                        .onCommanderOverlayAdjust
                                        ?.call(5, 0),
                                    onLongDecrement: () => widget
                                        .onCommanderOverlayAdjust
                                        ?.call(-5, 0),
                                  ),
                                  if (widget.partnerEnabled)
                                    const SizedBox(width: 16),
                                  if (widget.partnerEnabled)
                                    CommanderAdjustBox(
                                      value:
                                          widget.commanderDamageFromSource !=
                                                  null &&
                                              widget
                                                      .commanderDamageFromSource!
                                                      .length >
                                                  1
                                          ? widget.commanderDamageFromSource![1]
                                          : 0,
                                      onIncrement: () => widget
                                          .onCommanderOverlayAdjust
                                          ?.call(1, 1),
                                      onDecrement: () => widget
                                          .onCommanderOverlayAdjust
                                          ?.call(-1, 1),
                                      onLongIncrement: () => widget
                                          .onCommanderOverlayAdjust
                                          ?.call(5, 1),
                                      onLongDecrement: () => widget
                                          .onCommanderOverlayAdjust
                                          ?.call(-5, 1),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (_showCounters)
                Positioned.fill(
                  child: _CounterOverlay(
                    counters: widget.counters,
                    onCounterChange: widget.onCounterChange,
                    onClose: () {
                      setState(() {
                        _showCounters = false;
                      });
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CounterOverlay extends StatelessWidget {
  final List<int> counters;
  final void Function(int counterIndex, int delta)? onCounterChange;
  final VoidCallback onClose;

  const _CounterOverlay({
    required this.counters,
    required this.onCounterChange,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Material(
        color: Colors.black.withAlpha(220),
        child: InkWell(
          onTap: onClose,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(maxWidth: 320),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(2, (row) {
                  return Row(
                    children: List.generate(3, (column) {
                      final index = row * 3 + column;
                      final value = index < counters.length
                          ? counters[index]
                          : 0;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: _CounterCell(
                            definition: _counterDefinitions[index],
                            value: value,
                            onChange: (delta) =>
                                onCounterChange?.call(index, delta),
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CounterCell extends StatelessWidget {
  final _CounterDefinition definition;
  final int value;
  final ValueChanged<int> onChange;

  const _CounterCell({
    required this.definition,
    required this.value,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(6),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Tooltip(
                  message: appLocalizations.translate(
                    definition.localizationKey,
                  ),
                  child: Icon(definition.icon, size: 16),
                ),
                const SizedBox(width: 4),
                Text(
                  '$value',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 24,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => onChange(-1),
                    child: const Center(child: Text('-')),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => onChange(1),
                    child: const Center(child: Text('+')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
