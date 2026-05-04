import 'package:flutter/material.dart';

import '../../services/localization_service.dart';

class DecksPage extends StatelessWidget {
  const DecksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final decks = [
      ('Atraxa - Counters & Toolbox', 'Commander', theme.colorScheme.primary),
      ('Mono-Red Burn', 'Pioneer', theme.colorScheme.secondary),
      ('Dimir Control', 'Modern', theme.colorScheme.tertiary),
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(appLocalizations.translate('decks.title'), style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(appLocalizations.translate('decks.subtitle')),
          const SizedBox(height: 20),
          ...decks.map(
            (deck) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: deck.$3.withValues(alpha: 0.18), child: Icon(Icons.layers, color: deck.$3)),
                  title: Text(deck.$1),
                  subtitle: Text(deck.$2),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: Text(appLocalizations.translate('decks.createDeck')),
          ),
        ],
      ),
    );
  }
}
