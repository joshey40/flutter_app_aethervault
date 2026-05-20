import 'package:flutter/material.dart';

import '../../../../services/localization_service.dart';
import '../data/lifecounter_model.dart';
import '../data/lifecounter_storage.dart';
import 'lifecounter_start_screen.dart';
import 'lifecounter_play_screen.dart';

class LifecounterEntryScreen extends StatefulWidget {
  const LifecounterEntryScreen({super.key});

  @override
  State<LifecounterEntryScreen> createState() => _LifecounterEntryScreenState();
}

class _LifecounterEntryScreenState extends State<LifecounterEntryScreen> {
  final _storage = LifecounterStorage();
  LifecounterGame? _game;
  bool _loading = true;
  bool _showStart = false;
  bool _showPlay = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final g = await _storage.loadGame();
    if (!mounted) return;
    setState(() {
      _game = g;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = appLocalizations;
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    // Inline navigation: keep BottomNavigationBar visible by swapping content here
    if (_showPlay && _game != null) {
      return LifecounterPlayScreen(game: _game!, onBack: () {
        setState(() {
          _showPlay = false;
        });
      });
    }

    if (_game == null || _showStart) {
      return LifecounterStartScreen(
        onGameStarted: (game) {
          setState(() {
            _game = game;
            _showPlay = true;
            _showStart = false;
          });
        },
        onCancel: () {
          setState(() {
            _showStart = false;
          });
        },
      );
    }

    // Show resume/new choice when a saved game exists
    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('lifecounter.title'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(loc.translate('lifecounter.title'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(loc.translate('lifecounter.startGame')),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: Text(loc.translate('lifecounter.startGame')),
              onPressed: () => setState(() => _showStart = true),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondary),
              icon: const Icon(Icons.restore),
              label: Text(loc.translate('lifecounter.resumeGame')),
              onPressed: () => setState(() => _showPlay = true),
            ),
          ],
        ),
      ),
    );
  }
}
