// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import '../../../../services/localization_service.dart';
import 'package:multi_split_view/multi_split_view.dart';
import '../data/lifecounter_model.dart';
import '../data/lifecounter_storage.dart';
import '../widgets/lifecounter_random.dart';
import '../widgets/player_panel.dart';

class LifecounterPlayScreen extends StatefulWidget {
  final LifecounterGame game;
  final VoidCallback? onBack;
  const LifecounterPlayScreen({super.key, required this.game, this.onBack});
  @override
  State<LifecounterPlayScreen> createState() => _LifecounterPlayScreenState();
}
class _LifecounterPlayScreenState extends State<LifecounterPlayScreen> {
  late LifecounterGame _game;
  final _storage = LifecounterStorage();
  int? _commanderDamageTargetIndex;
  bool _showManaBar = false;
  final List<int> _manaCounts = List<int>.filled(6, 0);
  // commanderDamage persisted on `_game.commanderDamage` as [source][target] -> [slot0, slot1?]

  @override
  void initState() {
    super.initState();
    _game = widget.game;
  }

  Future<void> _save() async {
    _game.normalizeCommanderDamageSlots();
    await _storage.saveGame(_game);
  }

  

  void _changeLife(int index, int delta) {
    setState(() {
      _game.currentLives[index] = (_game.currentLives[index] + delta).clamp(-999, 9999);
    });
    _save();
  }

  void _changeTax(int index, int delta) {
    setState(() {
      _game.commanderTax[index] = (_game.commanderTax[index] + delta).clamp(0, 9999);
    });
    _save();
  }

  void _changePartnerTax(int index, int delta) {
    setState(() {
      _game.partnerTax[index] = (_game.partnerTax[index] + delta).clamp(0, 9999);
    });
    _save();
  }

  void _resetPlayer(int index) {
    setState(() {
      _game.currentLives[index] = _game.startLife;
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
          life: _game.currentLives[i],
          quarterTurns: quarterTurns,
          onIncrement: (d) => _changeLife(i, d),
          onReset: () => _resetPlayer(i),
          commanderTax: _game.commanderTax[i],
          onTaxChange: (d) => _changeTax(i, d),
          partnerEnabled: _game.partnerEnabled[i],
          onPartnerChanged: (v) {
            setState(() {
              _game.partnerEnabled[i] = v;
              _game.normalizeCommanderDamageSlots();
            });
            _save();
          },
          partnerTax: _game.partnerTax[i],
          onPartnerTaxChange: (d) => _changePartnerTax(i, d),
          onCommanderPressed: () => _toggleCommanderDamage(i),
          showCommanderOverlay: _commanderDamageTargetIndex != null,
          onCommanderOverlayTap: () => _clearCommanderDamage(),
          commanderDamageFromSource: _commanderDamageTargetIndex != null ? _getCommanderDamageValues(i, _commanderDamageTargetIndex!, _game.partnerEnabled[_commanderDamageTargetIndex!]) : null,
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
    if (target < 0 || target >= _game.playerCount) return false;
    if (_game.currentLives[target] <= 0) return true;
    for (var source = 0; source < _game.playerCount; source++) {
      final slots = _game.commanderDamage[source][target];
      for (final v in slots) {
        if (v >= 21) return true;
      }
    }
    return false;
  }

  List<int> _getCommanderDamageValues(int source, int target, bool targetHasPartner) {
    if (source < 0 || source >= _game.playerCount) return targetHasPartner ? [0, 0] : [0];
    if (target < 0 || target >= _game.playerCount) return targetHasPartner ? [0, 0] : [0];
    final values = _game.commanderDamage[source][target];
    if (values.isEmpty) return targetHasPartner ? [0, 0] : [0];
    if (targetHasPartner && values.length == 1) return [values[0], 0];
    return values;
  }

  void _applyCommanderDamage(int source, int target, int delta, int slot) {
    setState(() {
      // Ensure structure and slots are normalized via model
      _game.normalizeCommanderDamageSlots();
      final list = _game.commanderDamage[source][target];
      while (list.length <= slot) {
        list.add(0);
      }
      _game.commanderDamage[source][target][slot] = (_game.commanderDamage[source][target][slot] + delta).clamp(0, 9999);
      // Apply life change to the target: damage reduces life by delta (negative delta restores life)
      _game.currentLives[target] = (_game.currentLives[target] - delta).clamp(0, 9999);
    });
    _save();
  }

  // Positioning-by-alignment removed in favor of grid layout.

  @override
  Widget build(BuildContext context) {
    final loc = appLocalizations;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('lifecounter.title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: appLocalizations.translate('back'),
          onPressed: () {
            if (widget.onBack != null) return widget.onBack!();
            Navigator.of(context).maybePop();
          },
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: loc.translate('lifecounter.resetGame'),
              onPressed: () => _confirmReset(),
            ),
          // Mana toggle button
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
            onPressed: () => showRandomPicker(context, maxPlayers: _game.playerCount),
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
        final count = _game.playerCount;
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
                // top row: two equal panels
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
                // bottom centered panel
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

  void _resetGame() {
    setState(() {
      for (var i = 0; i < _game.playerCount; i++) {
        _game.currentLives[i] = _game.startLife;
        _game.commanderTax[i] = 0;
        _game.partnerTax[i] = 0;
        for (var s = 0; s < _game.playerCount; s++) {
          _game.commanderDamage[s][i] = List<int>.filled(_game.partnerEnabled[i] ? 2 : 1, 0);
        }
      }
    });
    _save();
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(content: Text(appLocalizations.translate('lifecounter.gameReset') != 'lifecounter.gameReset' ? appLocalizations.translate('lifecounter.gameReset') : 'Game reset')));
  }

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
