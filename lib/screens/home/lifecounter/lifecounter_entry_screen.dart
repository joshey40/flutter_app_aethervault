import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../services/localization_service.dart';
import '../../../services/life_counter/lifecounter_storage.dart';

class LifecounterEntryScreen extends StatefulWidget {
  const LifecounterEntryScreen({super.key});

  @override
  State<LifecounterEntryScreen> createState() => _LifecounterEntryScreenState();
}

class _LifecounterEntryScreenState extends State<LifecounterEntryScreen> {
  final _storage = LifecounterStorage();
  bool _loading = true;
  bool _hasSavedGame = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final game = await _storage.loadGame();
    if (!mounted) return;

    setState(() {
      _hasSavedGame = game != null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = appLocalizations;

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('lifecounter.title')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              loc.translate('lifecounter.title'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(loc.translate('lifecounter.startGame')),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: Text(loc.translate('lifecounter.startGame')),
              onPressed: () => context.go('/lifecounter/newgame'),
            ),
            if (_hasSavedGame) ...[
              const SizedBox(height: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                icon: const Icon(Icons.restore),
                label: Text(loc.translate('lifecounter.resumeGame')),
                onPressed: () => context.go('/lifecounter/game'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
