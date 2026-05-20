import 'package:flutter/material.dart';
import '../../../../services/localization_service.dart';
import '../data/lifecounter_model.dart';
import '../data/lifecounter_storage.dart';
import 'lifecounter_play_screen.dart';

class LifecounterStartScreen extends StatefulWidget {
  final void Function(LifecounterGame)? onGameStarted;
  final VoidCallback? onCancel;

  const LifecounterStartScreen({super.key, this.onGameStarted, this.onCancel});

  @override
  State<LifecounterStartScreen> createState() => _LifecounterStartScreenState();
}

class _LifecounterStartScreenState extends State<LifecounterStartScreen> {
  final _storage = LifecounterStorage();
  int _selectedStart = 20;
  int _players = 2;
  String _selectedFormat = 'Standard';

  static const Map<String, Map<String, int>> _presets = {
    'Standard': {'start': 20, 'players': 2},
    'Commander': {'start': 40, 'players': 4},
  };

  static const List<int> _commonStarts = [20, 25, 30, 40, 50, 60];
  static const double _buttonWidth = 64.0;
  static const double _buttonSpacing = 4.0;

  void _startGame() async {
    final game = LifecounterGame(
      startLife: _selectedStart,
      playerCount: _players,
      currentLives: List<int>.filled(_players, _selectedStart),
      commanderTax: List<int>.filled(_players, 0),
      active: true,
    );
    await _storage.saveGame(game);
    if (!mounted) return;
    if (widget.onGameStarted != null) {
      widget.onGameStarted!(game);
    } else {
      final navigator = Navigator.of(context);
      navigator.push(MaterialPageRoute(builder: (_) => LifecounterPlayScreen(game: game)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = appLocalizations;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('lifecounter.title')),
        leading: widget.onCancel != null ? IconButton(icon: const Icon(Icons.close), onPressed: widget.onCancel) : null,
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
                      final key = k == 'Standard' ? 'lifecounter.presetStandard' : 'lifecounter.presetCommander';
                      return DropdownMenuItem(value: k, child: Text(loc.translate(key)));
                    }).toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      final preset = _presets[v]!;
                      setState(() {
                        _selectedFormat = v;
                        _selectedStart = preset['start']!;
                        _players = preset['players']!;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(child: Text(loc.translate('lifecounter.startLife'))),
            const SizedBox(height: 8),
            LayoutBuilder(builder: (context, constraints) {
              // If width is unbounded (can happen in some layouts), fallback to fixed width
              final totalSpacing = _buttonSpacing * (_commonStarts.length - 1);
              double chipWidth;
              if (!constraints.hasBoundedWidth || constraints.maxWidth.isInfinite) {
                chipWidth = _buttonWidth;
              } else {
                final available = (constraints.maxWidth - totalSpacing).clamp(0.0, double.infinity);
                chipWidth = (available / _commonStarts.length).clamp(40.0, _buttonWidth);
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
                            color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).chipTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              '$s',
                              style: TextStyle(color: selected ? Theme.of(context).colorScheme.onPrimary : null),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }),
            const SizedBox(height: 16),
            Center(child: Text(loc.translate('lifecounter.players'))),
            const SizedBox(height: 8),
            LayoutBuilder(builder: (context, constraints) {
              final totalSpacing = _buttonSpacing * (6 - 1);
              double chipWidth;
              if (!constraints.hasBoundedWidth || constraints.maxWidth.isInfinite) {
                chipWidth = _buttonWidth;
              } else {
                final available = (constraints.maxWidth - totalSpacing).clamp(0.0, double.infinity);
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
                        onTap: () => setState(() => _players = v),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).chipTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              '$v',
                              style: TextStyle(color: selected ? Theme.of(context).colorScheme.onPrimary : null),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
            const SizedBox(height: 16),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(140, 44)),
              onPressed: _startGame,
              child: Text(loc.translate('lifecounter.startGame')),
            ),
          ],
        ),
      ),
    );
  }
}
