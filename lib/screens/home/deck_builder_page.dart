import 'package:flutter/material.dart';

import '../../models/vault_deck.dart';
import '../../services/deck_storage.dart';
import '../../services/localization_service.dart';

class DeckBuilderPage extends StatefulWidget {
  const DeckBuilderPage({
    super.key,
    required this.initialDeck,
    required this.storage,
    required this.onDeckChanged,
  });

  final VaultDeck initialDeck;
  final DeckStorage storage;
  final ValueChanged<VaultDeck> onDeckChanged;

  @override
  State<DeckBuilderPage> createState() => _DeckBuilderPageState();
}

class _DeckBuilderPageState extends State<DeckBuilderPage> {
  late VaultDeck _deck;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _deck = widget.initialDeck;
  }

  Future<void> _persist(VaultDeck deck) async {
    setState(() {
      _deck = deck;
      _saving = true;
    });

    try {
      await widget.storage.upsertDeck(deck);
      widget.onDeckChanged(deck);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changeQuantity(DeckEntry entry, int delta) async {
    await _persist(_deck.updateEntryQuantity(entry.id, entry.quantity + delta));
  }

  Future<void> _removeEntry(DeckEntry entry) async {
    await _persist(_deck.removeEntry(entry.id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupedEntries = _groupEntriesByZone(_deck.entries);

    return Scaffold(
      appBar: AppBar(
        title: Text(_deck.name),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.style, size: 18),
                        label: Text('${_deck.totalCards} ${appLocalizations.translate('decks.cards')}'),
                      ),
                      Chip(
                        avatar: const Icon(Icons.category_outlined, size: 18),
                        label: Text(_deck.format),
                      ),
                      Chip(
                        avatar: const Icon(Icons.layers_outlined, size: 18),
                        label: Text('${_deck.countCardsInZone(DeckZone.mainboard)} ${DeckZone.mainboard.userFacingName}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: theme.colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              appLocalizations.translate('decks.builderHint'),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_deck.entries.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyDeckState(deckName: _deck.name),
            )
          else
            ...groupedEntries.entries.expand(
              (group) => [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                    child: Text(
                      '${group.key.userFacingName} · ${group.value.fold<int>(0, (sum, entry) => sum + entry.quantity)}',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                SliverList.builder(
                  itemCount: group.value.length,
                  itemBuilder: (context, index) {
                    final entry = group.value[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      child: _DeckEntryTile(
                        entry: entry,
                        onDecrease: () => _changeQuantity(entry, -1),
                        onIncrease: () => _changeQuantity(entry, 1),
                        onRemove: () => _removeEntry(entry),
                      ),
                    );
                  },
                ),
              ],
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Map<DeckZone, List<DeckEntry>> _groupEntriesByZone(List<DeckEntry> entries) {
    final grouped = <DeckZone, List<DeckEntry>>{};
    for (final zone in DeckZone.values) {
      final zoneEntries = entries.where((entry) => entry.zone == zone).toList(growable: false)
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      if (zoneEntries.isNotEmpty) grouped[zone] = zoneEntries;
    }
    return grouped;
  }
}

class _DeckEntryTile extends StatelessWidget {
  const _DeckEntryTile({
    required this.entry,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
  });

  final DeckEntry entry;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 44,
            height: 62,
            child: entry.imageUrl == null
                ? ColoredBox(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.style_outlined),
                  )
                : Image.network(
                    entry.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => ColoredBox(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.style_outlined),
                    ),
                  ),
          ),
        ),
        title: Text(entry.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          [entry.manaCost, entry.typeLine].whereType<String>().where((value) => value.isNotEmpty).join(' · '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: appLocalizations.translate('decks.decreaseQuantity'),
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: onDecrease,
            ),
            SizedBox(
              width: 28,
              child: Text(
                '${entry.quantity}',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            IconButton(
              tooltip: appLocalizations.translate('decks.increaseQuantity'),
              icon: const Icon(Icons.add_circle_outline),
              onPressed: onIncrease,
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'remove') onRemove();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'remove',
                  child: Text(appLocalizations.translate('decks.removeCard')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDeckState extends StatelessWidget {
  const _EmptyDeckState({required this.deckName});

  final String deckName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.layers_clear_outlined, size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              appLocalizations.translate('decks.emptyDeckTitle'),
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              appLocalizations.translate('decks.emptyDeckBody').replaceAll('{name}', deckName),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
