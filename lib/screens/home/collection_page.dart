import 'package:flutter/material.dart';

import '../../models/collection_entry.dart';
import '../../services/collection_storage.dart';
import '../../services/localization_service.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final CollectionStorage _storage = CollectionStorage();
  bool _loading = true;
  String? _error;
  List<CollectionEntry> _entries = const <CollectionEntry>[];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final entries = await _storage.loadEntries();
      if (!mounted) return;
      setState(() {
        _entries = entries;
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

  Future<void> _editEntry(CollectionEntry entry) async {
    final updated = await showModalBottomSheet<CollectionEntry>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => CollectionEntryFormSheet(existingEntry: entry),
    );

    if (updated == null) return;
    await _storage.upsertEntry(updated);
    await _loadEntries();
  }

  Future<void> _deleteEntry(CollectionEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appLocalizations.translate('collection.deleteEntry')),
        content: Text(appLocalizations.translate('collection.deleteEntryConfirm').replaceAll('{name}', entry.cardName)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(appLocalizations.translate('cancel'))),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(appLocalizations.translate('confirm'))),
        ],
      ),
    );

    if (confirmed != true) return;
    await _storage.deleteEntry(entry.id);
    await _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalCards = _entries.fold<int>(0, (sum, entry) => sum + entry.quantity);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadEntries,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(appLocalizations.translate('collection.title'), style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(appLocalizations.translate('collection.subtitle')),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('${_entries.length} ${appLocalizations.translate('collection.entries')}')),
                Chip(label: Text('$totalCards ${appLocalizations.translate('collection.totalCards')}')),
              ],
            ),
            const SizedBox(height: 18),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appLocalizations.translate('collection.loadFailed'), style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(_error!),
                      const SizedBox(height: 12),
                      FilledButton(onPressed: _loadEntries, child: Text(appLocalizations.translate('search.retryDownload'))),
                    ],
                  ),
                ),
              )
            else if (_entries.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 40, color: theme.colorScheme.primary),
                      const SizedBox(height: 12),
                      Text(appLocalizations.translate('collection.emptyTitle'), style: theme.textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(appLocalizations.translate('collection.emptyBody')),
                    ],
                  ),
                ),
              )
            else
              ..._entries.map(
                (entry) => _CollectionEntryCard(
                  entry: entry,
                  onTap: () => _editEntry(entry),
                  onDelete: () => _deleteEntry(entry),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CollectionEntryCard extends StatelessWidget {
  const _CollectionEntryCard({
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  final CollectionEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final flags = <String>[
      if (entry.isSigned) appLocalizations.translate('collection.signed'),
      if (entry.isAltered) appLocalizations.translate('collection.altered'),
      if (entry.isProxy) appLocalizations.translate('collection.proxy'),
    ];

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 58,
                  height: 82,
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.cardName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(_subtitle(entry), style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Chip(label: Text('×${entry.quantity}')),
                        Chip(label: Text(entry.condition.userFacingName)),
                        Chip(label: Text(entry.finish.userFacingName)),
                        ...flags.map((flag) => Chip(label: Text(flag))),
                      ],
                    ),
                    if (entry.note != null && entry.note!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(entry.note!, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'delete', child: Text(appLocalizations.translate('collection.deleteEntry'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle(CollectionEntry entry) {
    final set = entry.setCode.isEmpty ? '?' : entry.setCode.toUpperCase();
    final number = entry.collectorNumber.isEmpty ? '?' : entry.collectorNumber;
    return '$set · #$number · ${entry.language.toUpperCase()}';
  }
}

class CollectionEntryFormSheet extends StatefulWidget {
  const CollectionEntryFormSheet({
    super.key,
    this.card,
    this.existingEntry,
  }) : assert(card != null || existingEntry != null);

  final dynamic card;
  final CollectionEntry? existingEntry;

  @override
  State<CollectionEntryFormSheet> createState() => _CollectionEntryFormSheetState();
}

class _CollectionEntryFormSheetState extends State<CollectionEntryFormSheet> {
  late final TextEditingController _quantityController;
  late final TextEditingController _noteController;
  late CardCondition _condition;
  late CardFinish _finish;
  late bool _isSigned;
  late bool _isAltered;
  late bool _isProxy;

  @override
  void initState() {
    super.initState();
    final entry = widget.existingEntry;
    _quantityController = TextEditingController(text: (entry?.quantity ?? 1).toString());
    _noteController = TextEditingController(text: entry?.note ?? '');
    _condition = entry?.condition ?? CardCondition.nearMint;
    _finish = entry?.finish ?? CardFinish.nonfoil;
    _isSigned = entry?.isSigned ?? false;
    _isAltered = entry?.isAltered ?? false;
    _isProxy = entry?.isProxy ?? false;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final quantity = int.tryParse(_quantityController.text.trim())?.clamp(1, 999).toInt() ?? 1;
    final note = _noteController.text.trim();
    final existing = widget.existingEntry;

    if (existing != null) {
      Navigator.of(context).pop(
        existing.copyWith(
          quantity: quantity,
          condition: _condition,
          finish: _finish,
          isSigned: _isSigned,
          isAltered: _isAltered,
          isProxy: _isProxy,
          note: note.isEmpty ? null : note,
          updatedAt: DateTime.now(),
        ),
      );
      return;
    }

    final card = widget.card;
    Navigator.of(context).pop(
      CollectionEntry.fromScryfallCard(
        card,
        quantity: quantity,
        condition: _condition,
        finish: _finish,
        isSigned: _isSigned,
        isAltered: _isAltered,
        isProxy: _isProxy,
        note: note,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entry = widget.existingEntry;
    final cardName = entry?.cardName ?? widget.card.name as String;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.viewInsetsOf(context).bottom + 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              appLocalizations.translate(entry == null ? 'collection.addToCollection' : 'collection.editEntry'),
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(cardName),
            const SizedBox(height: 18),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: appLocalizations.translate('collection.quantity'),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<CardCondition>(
              value: _condition,
              decoration: InputDecoration(
                labelText: appLocalizations.translate('collection.condition'),
                border: const OutlineInputBorder(),
              ),
              items: CardCondition.values
                  .map((condition) => DropdownMenuItem(value: condition, child: Text(condition.userFacingName)))
                  .toList(growable: false),
              onChanged: (value) {
                if (value != null) setState(() => _condition = value);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<CardFinish>(
              value: _finish,
              decoration: InputDecoration(
                labelText: appLocalizations.translate('collection.finish'),
                border: const OutlineInputBorder(),
              ),
              items: CardFinish.values
                  .map((finish) => DropdownMenuItem(value: finish, child: Text(finish.userFacingName)))
                  .toList(growable: false),
              onChanged: (value) {
                if (value != null) setState(() => _finish = value);
              },
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _isSigned,
              onChanged: (value) => setState(() => _isSigned = value),
              title: Text(appLocalizations.translate('collection.signed')),
            ),
            SwitchListTile(
              value: _isAltered,
              onChanged: (value) => setState(() => _isAltered = value),
              title: Text(appLocalizations.translate('collection.altered')),
            ),
            SwitchListTile(
              value: _isProxy,
              onChanged: (value) => setState(() => _isProxy = value),
              title: Text(appLocalizations.translate('collection.proxy')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: appLocalizations.translate('collection.note'),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.save_outlined),
              label: Text(appLocalizations.translate('confirm')),
            ),
          ],
        ),
      ),
    );
  }
}
