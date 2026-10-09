import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/localization_service.dart';
import '../../../services/life_counter/lifecounter_model.dart';
import '../../../services/life_counter/lifecounter_controller.dart';

class _SeatPosition {
  final double x;
  final double y;
  final int quarterTurns;

  const _SeatPosition(this.x, this.y, this.quarterTurns);
}

class _SeatLayoutOption {
  final String key;
  final List<_SeatPosition> positions;

  const _SeatLayoutOption(this.key, this.positions);
}

class LifecounterStartScreen extends StatefulWidget {
  final int? initialStartLife;
  final int? initialPlayers;
  final LifecounterController controller;

  const LifecounterStartScreen({
    super.key,
    this.initialStartLife,
    this.initialPlayers,
    required this.controller,
  });

  @override
  State<LifecounterStartScreen> createState() => _LifecounterStartScreenState();
}

class _LifecounterStartScreenState extends State<LifecounterStartScreen> {
  late int _selectedStart;
  late int _players;
  String _selectedSeatLayout = 'option1';
  String _selectedFormat = 'Standard';

  static const Map<String, Map<String, int>> _presets = {
    'Standard': {'start': 20, 'players': 2},
    'Commander': {'start': 40, 'players': 4},
  };
  List<_SeatLayoutOption> _seatLayoutsForPlayers(int players) {
    switch (players) {
      case 1:
        return const [
          _SeatLayoutOption('option1', [_SeatPosition(0.5, 0.5, 1)]),
        ];
      case 2:
        return const [
          _SeatLayoutOption('option1', [
            _SeatPosition(0.5, 0.2, 2),
            _SeatPosition(0.5, 0.8, 0),
          ]),
          _SeatLayoutOption('option2', [
            _SeatPosition(0.5, 0.3, 1),
            _SeatPosition(0.5, 0.7, 1),
          ]),
        ];
      case 3:
        return const [
          _SeatLayoutOption('option1', [
            _SeatPosition(0.25, 0.25, 1),
            _SeatPosition(0.75, 0.25, 3),
            _SeatPosition(0.5, 0.8, 0),
          ]),
          _SeatLayoutOption('option2', [
            _SeatPosition(0.2, 0.3, 1),
            _SeatPosition(0.2, 0.7, 1),
            _SeatPosition(0.8, 0.5, 3),
          ]),
        ];
      case 4:
        return const [
          _SeatLayoutOption('option1', [
            _SeatPosition(0.2, 0.3, 1),
            _SeatPosition(0.2, 0.7, 1),
            _SeatPosition(0.8, 0.3, 3),
            _SeatPosition(0.8, 0.7, 3),
          ]),
          _SeatLayoutOption('option2', [
            _SeatPosition(0.5, 0.18, 2),
            _SeatPosition(0.22, 0.5, 1),
            _SeatPosition(0.78, 0.5, 3),
            _SeatPosition(0.5, 0.82, 0),
          ]),
        ];
      case 5:
        return const [
          _SeatLayoutOption('option1', [
            _SeatPosition(0.2, 0.2, 1),
            _SeatPosition(0.2, 0.5, 1),
            _SeatPosition(0.2, 0.8, 1),
            _SeatPosition(0.8, 0.35, 3),
            _SeatPosition(0.8, 0.65, 3),
          ]),
          _SeatLayoutOption('option2', [
            _SeatPosition(0.2, 0.25, 1),
            _SeatPosition(0.2, 0.55, 1),
            _SeatPosition(0.8, 0.25, 3),
            _SeatPosition(0.8, 0.55, 3),
            _SeatPosition(0.5, 0.82, 0),
          ]),
        ];
      case 6:
        return const [
          _SeatLayoutOption('option1', [
            _SeatPosition(0.2, 0.2, 1),
            _SeatPosition(0.2, 0.5, 1),
            _SeatPosition(0.2, 0.8, 1),
            _SeatPosition(0.8, 0.2, 3),
            _SeatPosition(0.8, 0.5, 3),
            _SeatPosition(0.8, 0.8, 3),
          ]),
        ];
      default:
        return const [];
    }
  }

  static const List<int> _commonStarts = [20, 25, 30, 40, 50, 60];
  static const double _buttonWidth = 64.0;
  static const double _buttonSpacing = 4.0;

  @override
  void initState() {
    super.initState();
    _selectedStart = widget.initialStartLife ?? 20;
    _players = widget.initialPlayers ?? 2;

    if (_selectedStart == 40 && _players == 4) {
      _selectedFormat = 'Commander';
    }
  }

  void _startGame({int? startLife, int? players}) async {
    startLife ??= _selectedStart;
    players ??= _players;
    final game = LifecounterGame(
      startLife: startLife,
      playerCount: players,
      currentLives: List<int>.filled(players, startLife),
      commanderTax: List<int>.filled(players, 0),
      seatLayout: _selectedSeatLayout,
      active: true,
    );
    await widget.controller.saveGame(game);
    if (!mounted) return;
    context.go('/lifecounter/game');
  }

  @override
  Widget build(BuildContext context) {
    final loc = appLocalizations;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('lifecounter.title')),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/lifecounter'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(loc.translate('lifecounter.format')),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _selectedFormat,
                    items: _presets.keys.map((k) {
                      final key = k == 'Standard'
                          ? 'lifecounter.presetStandard'
                          : 'lifecounter.presetCommander';
                      return DropdownMenuItem(
                        value: k,
                        child: Text(loc.translate(key)),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      final preset = _presets[v]!;
                      setState(() {
                        _selectedFormat = v;
                        _selectedStart = preset['start']!;
                        _players = preset['players']!;
                        _selectedSeatLayout = 'option1';
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(child: Text(loc.translate('lifecounter.startLife'))),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                // If width is unbounded (can happen in some layouts), fallback to fixed width
                final totalSpacing =
                    _buttonSpacing * (_commonStarts.length - 1);
                double chipWidth;
                if (!constraints.hasBoundedWidth ||
                    constraints.maxWidth.isInfinite) {
                  chipWidth = _buttonWidth;
                } else {
                  final available = (constraints.maxWidth - totalSpacing).clamp(
                    0.0,
                    double.infinity,
                  );
                  chipWidth = (available / _commonStarts.length).clamp(
                    40.0,
                    _buttonWidth,
                  );
                }

                return Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: _buttonSpacing,
                    children: _commonStarts.map((s) {
                      final selected = _selectedStart == s;
                      return SizedBox(
                        width: chipWidth,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => setState(() => _selectedStart = s),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).chipTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                '$s',
                                style: TextStyle(
                                  color: selected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Center(child: Text(loc.translate('lifecounter.players'))),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final totalSpacing = _buttonSpacing * (6 - 1);
                double chipWidth;
                if (!constraints.hasBoundedWidth ||
                    constraints.maxWidth.isInfinite) {
                  chipWidth = _buttonWidth;
                } else {
                  final available = (constraints.maxWidth - totalSpacing).clamp(
                    0.0,
                    double.infinity,
                  );
                  chipWidth = (available / 6).clamp(36.0, _buttonWidth);
                }

                return Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: _buttonSpacing,
                    children: List.generate(6, (i) {
                      final v = i + 1;
                      final selected = _players == v;
                      return SizedBox(
                        width: chipWidth,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => setState(() {
                            _players = v;
                            _selectedSeatLayout = 'option1';
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).chipTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                '$v',
                                style: TextStyle(
                                  color: selected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Center(child: Text(loc.translate('lifecounter.seatArrangement'))),
            const SizedBox(height: 8),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: _seatLayoutsForPlayers(_players)
                    .asMap()
                    .entries
                    .map(
                      (entry) => _buildSeatLayoutOption(
                        context,
                        entry.value,
                        entry.key + 1,
                        loc,
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(140, 44)),
              onPressed: () => _startGame(),
              child: Text(loc.translate('lifecounter.startGame')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatLayoutOption(
    BuildContext context,
    _SeatLayoutOption option,
    int number,
    dynamic loc,
  ) {
    final selected = _selectedSeatLayout == option.key;
    return Semantics(
      label: loc
          .translate('lifecounter.seatOption')
          .replaceAll('{index}', '$number'),
      selected: selected,
      button: true,
      child: SizedBox(
        width: 100,
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => setState(() => _selectedSeatLayout = option.key),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                  width: selected ? 2 : 1,
                ),
              ),
              child: _SeatLayoutPreview(positions: option.positions),
            ),
          ),
        ),
      ),
    );
  }
}

class _SeatLayoutPreview extends StatelessWidget {
  final List<_SeatPosition> positions;

  const _SeatLayoutPreview({required this.positions});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const iconSize = 24.0;
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Stack(
            children: positions
                .map(
                  (position) => Positioned(
                    left: position.x * constraints.maxWidth - iconSize / 2,
                    top: position.y * constraints.maxHeight - iconSize / 2,
                    child: RotatedBox(
                      quarterTurns: position.quarterTurns,
                      child: Icon(
                        Icons.person,
                        size: iconSize,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
