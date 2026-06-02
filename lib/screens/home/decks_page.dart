import 'package:flutter/material.dart';

import '../../models/vault_deck.dart';
import '../../services/deck_storage.dart';
import '../../services/localization_service.dart';
import 'deck_builder_page.dart';

class DecksPage extends StatefulWidget {
  const DecksPage({super.key});

  @override
  State<DecksPage> createState() => _DecksPageState();
}

class _DecksPageState extends State<DecksPage> {
  final DeckStorage _storage = DeckStorage();
  List<VaultDeck> _decks = const <VaultDeck>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  Future<void> _loadDecks() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final decks = await _storage.loadDecks();
      if (!mounted) return;
      setState(() {
        _decks = decks;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _createDeck() async {
    final result = await showDialog<_NewDeckResult>(
      context: context,
      builder: (context) => const _CreateDeckDialog(),
    );
    if (result == null) return;

    try {
      final deck = await _storage.createDeck(name: result.name, format: result.format);
      if (!mounted) return;
      setState(() => _decks = [deck, ..._decks]);
      _openDeck(deck);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _deleteDeck(VaultDeck deck) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appLocalizations.translate('decks.deleteDeck')),
        content: Text(appLocalizations.translate('decks.deleteDeckConfirm').replaceAll('{name}', deck.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(appLocalizations.translate('cancel')),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(appLocalizations.translate('confirm')),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await _storage.deleteDeck(deck.id);
    if (!mounted) return;
    setState(() => _decks = _decks.where((candidate) => candidate.id != deck.id).toList(growable: false));
  }

  Future<void> _openDeck(VaultDeck deck) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => DeckBuilderPage(
          initialDeck: deck,
          storage: _storage,
          onDeckChanged: (updatedDeck) {
            setState(() {
              _decks = _decks
                  .map((candidate) => candidate.id == updatedDeck.id ? updatedDeck : candidate)
                  .toList(growable: false)
                ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
            });
          },
        ),
      ),
    );
    await _loadDecks();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDecks,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(appLocalizations.translate('decks.title'), style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(appLocalizations.translate('decks.subtitle')),
              const SizedBox(height: 20),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                _DecksErrorState(error: _error!, onRetry: _loadDecks)
              else if (_decks.isEmpty)
                const _EmptyDeckListState()
              else
                ..._decks.map(
                  (deck) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.16),
                          child: Icon(Icons.layers, color: theme.colorScheme.primary),
                        ),
                        title: Text(deck.name),
                        subtitle: Text(
                          '${deck.format} · ${deck.totalCards} ${appLocalizations.translate('decks.cards')}',
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'delete') _deleteDeck(deck);
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(appLocalizations.translate('decks.deleteDeck')),
                            ),
                          ],
                        ),
                        onTap: () => _openDeck(deck),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              FilledButton.tonalIcon(
                onPressed: _createDeck,
                icon: const Icon(Icons.add),
                label: Text(appLocalizations.translate('decks.createDeck')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateDeckDialog extends StatefulWidget {
  const _CreateDeckDialog();

  @override
  State<_CreateDeckDialog> createState() => _CreateDeckDialogState();
}

class _CreateDeckDialogState extends State<_CreateDeckDialog> {
  final TextEditingController _nameController = TextEditingController();
  String _format = 'Commander';

  static const List<String> _formats = [
    'Commander',
    'Standard',
    'Pioneer',
    'Modern',
    'Legacy',
    'Vintage',
    'Pauper',
    'Casual',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(_NewDeckResult(name: name, format: _format));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(appLocalizations.translate('decks.createDeck')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: InputDecoration(labelText: appLocalizations.translate('decks.deckName')),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _format,
            decoration: InputDecoration(labelText: appLocalizations.translate('decks.format')),
            items: _formats.map((format) => DropdownMenuItem(value: format, child: Text(format))).toList(growable: false),
            onChanged: (value) {
              if (value != null) setState(() => _format = value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(appLocalizations.translate('cancel')),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(appLocalizations.translate('decks.createDeck')),
        ),
      ],
    );
  }
}

class _NewDeckResult {
  const _NewDeckResult({required this.name, required this.format});

  final String name;
  final String format;
}

class _EmptyDeckListState extends StatelessWidget {
  const _EmptyDeckListState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          Icon(Icons.space_dashboard_outlined, size: 56, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            appLocalizations.translate('decks.emptyListTitle'),
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            appLocalizations.translate('decks.emptyListBody'),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DecksErrorState extends StatelessWidget {
  const _DecksErrorState({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appLocalizations.translate('decks.loadFailed'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(error),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(appLocalizations.translate('search.retryDownload')),
            ),
          ],
        ),
      ),
    );
  }
}
