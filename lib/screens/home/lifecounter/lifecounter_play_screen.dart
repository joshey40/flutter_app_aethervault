// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../services/localization_service.dart';
import 'package:multi_split_view/multi_split_view.dart';
import '../../../services/life_counter/lifecounter_model.dart';
import '../../../services/life_counter/lifecounter_storage.dart';
import 'widgets/lifecounter_random.dart';
import 'widgets/player_panel.dart';

class LifecounterPlayScreen extends StatefulWidget {
  const LifecounterPlayScreen({super.key});
  @override
  State<LifecounterPlayScreen> createState() => _LifecounterPlayScreenState();
}

class _LifecounterPlayScreenState extends State<LifecounterPlayScreen> {
  LifecounterGame? _game;
  bool _loading = true;
  final _storage = LifecounterStorage();
  int? _commanderDamageTargetIndex;
  bool _showManaBar = false;
  final List<int> _manaCounts = List<int>.filled(6, 0);
  // commanderDamage persisted on `_currentGame.commanderDamage` as [source][target] -> [slot0, slot1?]

  @override
  void initState() {
    super.initState();
    _loadGame();
  }

  Future<void> _loadGame() async {
    final game = await LifecounterStorage().loadGame();
    if (!mounted) return;

    if (game == null) {
      context.go('/lifecounter');
      return;
    }

    setState(() {
      _game = game;
      _loading = false;
    });
  }

  LifecounterGame get _currentGame => _game!;

  Future<void> _save() async {
    if (_game == null) return;
    _game!.normalizeCommanderDamageSlots();
    await _storage.saveGame(_game!);
  }

  void _changeLife(int index, int delta) {
    setState(() {
      _currentGame.currentLives[index] = (_currentGame.currentLives[index] + delta).clamp(-999, 9999);
    });
    _save();
  }

  void _changeTax(int index, int delta) {
    setState(() {
      _currentGame.commanderTax[index] = (_currentGame.commanderTax[index] + delta).clamp(0, 9999);
    });
    _save();
  }

  void _changePartnerTax(int index, int delta) {
    setState(() {
      _currentGame.partnerTax[index] = (_currentGame.partnerTax[index] + delta).clamp(0, 9999);
    });
    _save();
  }

  void _resetPlayer(int index) {
    setState(() {
      _currentGame.currentLives[index] = _currentGame.startLife;
    });
    _save();
  }

  // Helper to build a configured PlayerPanel for index `i`.
  Widget _buildPlayer(int i, int quarterTurns) {
    return Padding(
      padding: const EdgeInsets.all(3.0 / 2),
      child: AspectRatio(
        aspectRatio: 3 / 2,
        child: PlayerPanel(
          index: i,
          life: _currentGame.currentLives[i],
          quarterTurns: quarterTurns,
          onIncrement: (d) => _changeLife(i, d),
          onReset: () => _resetPlayer(i),
          commanderTax: _currentGame.commanderTax[i],
          onTaxChange: (d) => _changeTax(i, d),
          partnerEnabled: _currentGame.partnerEnabled[i],
          onPartnerChanged: (v) {
            setState(() {
              _currentGame.partnerEnabled[i] = v;
              _currentGame.normalizeCommanderDamageSlots();
            });
            _save();
          },
          partnerTax: _currentGame.partnerTax[i],
          onPartnerTaxChange: (d) => _changePartnerTax(i, d),
          onCommanderPressed: () => _toggleCommanderDamage(i),
          showCommanderOverlay: _commanderDamageTargetIndex != null,
          onCommanderOverlayTap: () => _clearCommanderDamage(),
          commanderDamageFromSource: _commanderDamageTargetIndex != null ? _getCommanderDamageValues(i, _commanderDamageTargetIndex!, _currentGame.partnerEnabled[_commanderDamageTargetIndex!]) : null,
          isCommanderTarget: _commanderDamageTargetIndex != null && _commanderDamageTargetIndex == i,
          onCommanderOverlayAdjust: (d, slot) {
            if (_commanderDamageTargetIndex == null) return;
            _applyCommanderDamage(i, _commanderDamageTargetIndex!, d, slot);
          },
          lost: _isPlayerLost(i),
        ),
      ),
    );
  }

  void _toggleCommanderDamage(int targetIndex) {
    setState(() {
      if (_commanderDamageTargetIndex == targetIndex) {
        _commanderDamageTargetIndex = null;
      } else {
        _commanderDamageTargetIndex = targetIndex;
      }
    });
  }

  void _clearCommanderDamage() {
    setState(() {
      _commanderDamageTargetIndex = null;
    });
  }

  bool _isPlayerLost(int target) {
    if (target < 0 || target >= _currentGame.playerCount) return false;
    if (_currentGame.currentLives[target] <= 0) return true;
    for (var source = 0; source < _currentGame.playerCount; source++) {
      final slots = _currentGame.commanderDamage[source][target];
      for (final v in slots) {
        if (v >= 21) return true;
      }
    }
    return false;
  }

  /// Ensure all commanderDamage[source][target] slot lists match at least the expected number of slots for the target (1 or 2 depending on partnerEnabled).
  List<int> _getCommanderDamageValues(int source, int target, bool targetHasPartner) {
    if (source < 0 || source >= _currentGame.playerCount) return targetHasPartner ? [0, 0] : [0];
    if (target < 0 || target >= _currentGame.playerCount) return targetHasPartner ? [0, 0] : [0];
    final values = _currentGame.commanderDamage[source][target];
    if (values.isEmpty) return targetHasPartner ? [0, 0] : [0];
    if (targetHasPartner && values.length == 1) return [values[0], 0];
    return values;
  }

  /// Apply commander damage from [source] to [target] for the given [slot] (0 or 1), adjusting the target's life accordingly.
  void _applyCommanderDamage(int source, int target, int delta, int slot) {
    setState(() {
      // Ensure structure and slots are normalized via model
      _currentGame.normalizeCommanderDamageSlots();
      final list = _currentGame.commanderDamage[source][target];
      while (list.length <= slot) {
        list.add(0);
      }
      _currentGame.commanderDamage[source][target][slot] = (_currentGame.commanderDamage[source][target][slot] + delta).clamp(0, 9999);
      // Apply life change to the target: damage reduces life by delta (negative delta restores life)
      _currentGame.currentLives[target] = (_currentGame.currentLives[target] - delta).clamp(0, 9999);
    });
    _save();
  }

  // Positioning-by-alignment removed in favor of grid layout.

  @override
  Widget build(BuildContext context) {
    if (_loading || _game == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final loc = appLocalizations;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('lifecounter.title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: appLocalizations.translate('back'),
          onPressed: () {
            context.go('/lifecounter');
          },
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: loc.translate('lifecounter.resetGame'),
              onPressed: () => _confirmReset(),
            ),
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Mana',
            onPressed: () {
              setState(() {
                _showManaBar = !_showManaBar;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.casino),
            tooltip: 'Random',
            onPressed: () => showRandomPicker(context, maxPlayers: _currentGame.playerCount),
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Animated mana bar that slides down under the AppBar
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: _showManaBar ? 40.0 : 0.0,
            curve: Curves.easeInOut,
            child: ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: 1.0,
                child: Container(
                  color: Theme.of(context).colorScheme.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List<Widget>.generate(6, (i) {
                        final colors = [
                          Colors.grey.shade200,
                          Colors.blue,
                          Colors.black,
                          Colors.red,
                          Colors.green,
                          Colors.grey,
                        ];

                        
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                            child: SizedBox(
                              child: Material(
                                color: colors[i],
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                                  child: Builder(builder: (ctx) {
                                    final textColor = (i == 0 || i == 5) ? Colors.black87 : Colors.white;
                                    return SizedBox(
                                      width: 55,
                                      height: 32,
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        _manaCounts[i] = (_manaCounts[i] - 1).clamp(0, 9999);
                                                      });
                                                    },
                                                    onLongPress: () {
                                                      setState(() {
                                                        _manaCounts[i] = 0;
                                                      });
                                                    },
                                                    child: Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                                                        child: Icon(Icons.remove_circle_outline, size: 16, color: textColor),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        _manaCounts[i] = (_manaCounts[i] + 1).clamp(0, 9999);
                                                      });
                                                    },
                                                    child: Align(
                                                      alignment: Alignment.centerRight,
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                                                        child: Icon(Icons.add_circle_outline, size: 16, color: textColor),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Center(
                                            child: IgnorePointer(
                                              child: Text('${_manaCounts[i]}', style: TextStyle(fontSize: 13, color: textColor)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          );
                        }),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: Builder(builder: (ctx) {
        final count = _currentGame.playerCount;
        const double gap = 2.0;
        if (count == 1) {
          return Padding(
            padding: const EdgeInsets.all(gap),
            child: Center(child: _buildPlayer(0, 1)),
          );
        }

        // Special-case 3 players: top row two players, bottom centered player
        if (count == 3) {
          return Padding(
            padding: const EdgeInsets.all(gap),
            child: MultiSplitView(
              axis: Axis.vertical,
              initialAreas: [
                Area(
                  flex: 3,
                  builder: (c, a) => MultiSplitView(
                    axis: Axis.horizontal,
                    initialAreas: [
                      Area(builder: (ctx, ar) => _buildPlayer(0, 1)),
                      Area(builder: (ctx, ar) => _buildPlayer(1, 3)),
                    ],
                  ),
                ),
                Area(flex: 2, builder: (c, a) => _buildPlayer(2, 0)),
              ],
            ),
          );
        }

        // special-case 2 players: top and bottom
        if (count == 2) {
          return Padding(
            padding: const EdgeInsets.all(gap),
            child: MultiSplitView(
              axis: Axis.vertical,
              initialAreas: [
                Area(builder: (c, a) => _buildPlayer(0, 2)),
                Area(builder: (c, a) => _buildPlayer(1, 0)),
              ],
            ),
          );
        }

        final leftCount = (count / 2).ceil();
        final rightCount = count - leftCount;
        final leftIndices = List<int>.generate(leftCount, (i) => i);
        final rightIndices = List<int>.generate(rightCount, (i) => leftCount + i);
        final rightQuarter = 3;

        return Padding(
          padding: const EdgeInsets.all(gap),
          child: MultiSplitView(
            axis: Axis.horizontal,
            initialAreas: [
              Area(
                builder: (c, a) => MultiSplitView(
                  axis: Axis.vertical,
                  initialAreas: leftIndices.map((i) => Area(builder: (ctx, ar) => _buildPlayer(i, 1))).toList(),
                ),
              ),
              Area(
                builder: (c, a) => MultiSplitView(
                  axis: Axis.vertical,
                  initialAreas: rightIndices.map((i) => Area(builder: (ctx, ar) => _buildPlayer(i, rightQuarter))).toList(),
                ),
              ),
            ],
          ),
        );
          })),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Ensure latest state is persisted when leaving the screen.
    _save();
    super.dispose();
  }

  /// Reset the game state to initial values for all players.
  void _resetGame() {
    setState(() {
      for (var i = 0; i < _currentGame.playerCount; i++) {
        _currentGame.currentLives[i] = _currentGame.startLife;
        _currentGame.commanderTax[i] = 0;
        _currentGame.partnerTax[i] = 0;
        for (var s = 0; s < _currentGame.playerCount; s++) {
          _currentGame.commanderDamage[s][i] = List<int>.filled(_currentGame.partnerEnabled[i] ? 2 : 1, 0);
        }
      }
    });
    _save();
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(content: Text(appLocalizations.translate('lifecounter.gameReset') != 'lifecounter.gameReset' ? appLocalizations.translate('lifecounter.gameReset') : 'Game reset')));
  }

  /// Show a confirmation dialog before resetting the game state.
  Future<void> _confirmReset() async {
    final loc = appLocalizations;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.translate('lifecounter.resetGame') != 'lifecounter.resetGame' ? loc.translate('lifecounter.resetGame') : 'Reset game'),
        content: Text(loc.translate('lifecounter.resetConfirm') != 'lifecounter.resetConfirm' ? loc.translate('lifecounter.resetConfirm') : 'Are you sure you want to reset all players to start life?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(loc.translate('cancel') != 'cancel' ? loc.translate('cancel') : 'Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(loc.translate('confirm') != 'confirm' ? loc.translate('confirm') : 'Reset')),
        ],
      ),
    );

    if (!mounted) return;
    if (ok == true) {
      _resetGame();
    }
  }
}
