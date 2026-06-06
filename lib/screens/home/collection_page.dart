import 'package:flutter/material.dart';

import '../../models/collection_entry.dart';
import '../../services/collection_storage.dart';
import '../../services/localization_service.dart';
import '../../services/scryfall/bulk_data_type.dart';
import '../../services/scryfall/scryfall_card_print.dart';
import '../../services/scryfall/scryfall_indexed_search_data_source.dart';
import '../../services/scryfall/scryfall_search_repository.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final CollectionStorage _storage = CollectionStorage();
  final ScryfallIndexedSearchDataSource _scryfallSearchDataSource = ScryfallIndexedSearchDataSource();
  final TextEditingController _searchController = TextEditingController();

  bool _loading = true;
  bool _searchingCollection = false;
  bool _usingTextFallback = false;
  int _searchGeneration = 0;
  String _activeSearchQuery = '';
  String? _error;
  String? _searchError;
  List<CollectionEntry> _entries = const <CollectionEntry>[];
  List<CollectionEntry> _filteredEntries = const <CollectionEntry>[];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _loadEntries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _submitCollectionSearch() async {
    final query = _searchController.text.trim();
    final generation = ++_searchGeneration;

    if (query.isEmpty) {
      _clearSearch();
      return;
    }

    if (!mounted) return;
    setState(() {
      _activeSearchQuery = query;
      _searchingCollection = true;
      _usingTextFallback = false;
      _searchError = null;
    });

    try {
      final matchingIds = await _searchScryfallIds(query);
      if (!mounted || generation != _searchGeneration) return;
      setState(() {
        _filteredEntries = _entries.where((entry) => matchingIds.contains(entry.scryfallId)).toList(growable: false);
        _searchingCollection = false;
      });
    } catch (error) {
      if (!mounted || generation != _searchGeneration) return;
      setState(() {
        _filteredEntries = _textFilteredEntries(query);
        _searchingCollection = false;
        _usingTextFallback = true;
        _searchError = error.toString();
      });
    }
  }

  void _clearSearch() {
    _searchGeneration++;
    _searchController.clear();
    setState(() {
      _activeSearchQuery = '';
      _filteredEntries = _entries;
      _searchingCollection = false;
      _usingTextFallback = false;
      _searchError = null;
    });
  }

  Future<Set<String>> _searchScryfallIds(String query) async {
    try {
      final cards = await _scryfallSearchDataSource.searchCards(
        rawQuery: query,
        type: ScryfallBulkDataType.allCards,
        sortMode: ScryfallSearchSortMode.nameAsc,
      );
      return cards.map((card) => card.id).toSet();
    } catch (_) {
      final cards = await _scryfallSearchDataSource.searchCards(
        rawQuery: query,
        type: ScryfallBulkDataType.defaultCards,
        sortMode: ScryfallSearchSortMode.nameAsc,
      );
      return cards.map((card) => card.id).toSet();
    }
  }

  List<CollectionEntry> _textFilteredEntries(String query) {
    final normalizedQuery = query.toLowerCase();
    return _entries.where((entry) {
      final haystack = [
        entry.cardName,
        entry.setCode,
        entry.collectorNumber,
        entry.language,
        entry.condition.userFacingName,
        entry.finish.userFacingName,
        if (entry.isSigned) appLocalizations.translate('collection.signed'),
        if (entry.isAltered) appLocalizations.translate('collection.altered'),
        if (entry.isProxy) appLocalizations.translate('collection.proxy'),
        entry.note ?? '',
      ].join(' ').toLowerCase();
      return haystack.contains(normalizedQuery);
    }).toList(growable: false);
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
        _filteredEntries = _activeSearchQuery.isEmpty ? entries : _filteredEntries;
        _loading = false;
      });
      if (_activeSearchQuery.isNotEmpty) {
        await _submitCollectionSearch();
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _showEntryDetails(CollectionEntry entry) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => CollectionEntryDetailSheet(entry: entry),
    );
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
    final filteredEntries = _filteredEntries;
    final totalCards = _entries.fold<int>(0, (sum, entry) => sum + entry.quantity);
    final filteredTotalCards = filteredEntries.fold<int>(0, (sum, entry) => sum + entry.quantity);
    final isFiltering = _activeSearchQuery.isNotEmpty;
    final hasSearchInput = _searchController.text.trim().isNotEmpty;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadEntries,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
          children: [
            _CollectionHeader(totalCards: totalCards),
            const SizedBox(height: 16),
            _CollectionSearchCard(
              controller: _searchController,
              searching: _searchingCollection,
              hasInput: hasSearchInput,
              onSearch: _submitCollectionSearch,
              onClear: _clearSearch,
            ),
            if (_usingTextFallback) ...[
              const SizedBox(height: 8),
              Text(
                appLocalizations.translate('collection.searchFallback'),
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary),
              ),
            ] else if (_searchError != null) ...[
              const SizedBox(height: 8),
              Text(
                _searchError!,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
              ),
            ],
            if (isFiltering) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  avatar: const Icon(Icons.filter_alt_outlined, size: 18),
                  label: Text(
                    appLocalizations
                        .translate('collection.searchResults')
                        .replaceAll('{entries}', filteredEntries.length.toString())
                        .replaceAll('{cards}', filteredTotalCards.toString()),
                  ),
                ),
              ),
            ],
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
            else if (filteredEntries.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.search_off, size: 40, color: theme.colorScheme.primary),
                      const SizedBox(height: 12),
                      Text(appLocalizations.translate('collection.noSearchResultsTitle'), style: theme.textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(appLocalizations.translate('collection.noSearchResultsBody').replaceAll('{query}', _activeSearchQuery)),
                    ],
                  ),
                ),
              )
            else
              ...filteredEntries.map(
                (entry) => _CollectionEntryCard(
                  entry: entry,
                  onTap: () => _showEntryDetails(entry),
                  onEdit: () => _editEntry(entry),
                  onDelete: () => _deleteEntry(entry),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CollectionHeader extends StatelessWidget {
  const _CollectionHeader({required this.totalCards});

  final int totalCards;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            appLocalizations.translate('collection.title'),
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            appLocalizations.translate('collection.totalCardsShort').replaceAll('{count}', totalCards.toString()),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _CollectionSearchCard extends StatelessWidget {
  const _CollectionSearchCard({
    required this.controller,
    required this.searching,
    required this.hasInput,
    required this.onSearch,
    required this.onClear,
  });

  final TextEditingController controller;
  final bool searching;
  final bool hasInput;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    onSubmitted: (_) => onSearch(),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      labelText: appLocalizations.translate('collection.searchLabel'),
                      hintText: appLocalizations.translate('collection.searchHint'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: hasInput
                          ? IconButton(
                              tooltip: appLocalizations.translate('collection.clearSearch'),
                              icon: const Icon(Icons.clear),
                              onPressed: onClear,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: searching ? null : onSearch,
                  icon: const Icon(Icons.manage_search),
                  label: Text(appLocalizations.translate('collection.searchAction')),
                ),
              ],
            ),
            if (searching) ...[
              const SizedBox(height: 10),
              const LinearProgressIndicator(),
            ],
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
    required this.onEdit,
    required this.onDelete,
  });

  final CollectionEntry entry;
  final VoidCallback onTap;
  final VoidCallback onEdit;
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
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CollectionCardImage(imageUrl: entry.imageUrl, width: 62, height: 88),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.cardName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(_subtitle(entry), style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _SmallPill(label: '×${entry.quantity}', icon: Icons.inventory_2_outlined),
                        _SmallPill(label: entry.condition.userFacingName),
                        _SmallPill(label: entry.finish.userFacingName),
                        ...flags.map((flag) => _SmallPill(label: flag)),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'edit', child: Text(appLocalizations.translate('collection.editEntry'))),
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

class CollectionEntryDetailSheet extends StatelessWidget {
  const CollectionEntryDetailSheet({super.key, required this.entry});

  final CollectionEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final flags = <String>[
      if (entry.isSigned) appLocalizations.translate('collection.signed'),
      if (entry.isAltered) appLocalizations.translate('collection.altered'),
      if (entry.isProxy) appLocalizations.translate('collection.proxy'),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.viewInsetsOf(context).bottom + 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: _CollectionCardImage(imageUrl: entry.imageUrl, width: 180, height: 252)),
            const SizedBox(height: 18),
            SelectableText(
              entry.cardName,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _SmallPill(label: '×${entry.quantity}', icon: Icons.inventory_2_outlined),
                _SmallPill(label: entry.condition.userFacingName),
                _SmallPill(label: entry.finish.userFacingName),
                ...flags.map((flag) => _SmallPill(label: flag)),
              ],
            ),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _DetailRow(label: appLocalizations.translate('collection.setCode'), value: entry.setCode.toUpperCase()),
                    _DetailRow(label: appLocalizations.translate('collection.collectorNumber'), value: entry.collectorNumber),
                    _DetailRow(label: appLocalizations.translate('collection.language'), value: entry.language.toUpperCase()),
                    _DetailRow(label: 'Scryfall ID', value: entry.scryfallId),
                  ],
                ),
              ),
            ),
            if (entry.note != null && entry.note!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appLocalizations.translate('collection.note'), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      SelectableText(entry.note!),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(child: SelectableText(value.isEmpty ? '—' : value)),
        ],
      ),
    );
  }
}

class _SmallPill extends StatelessWidget {
  const _SmallPill({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14),
            const SizedBox(width: 4),
          ],
          Text(label, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _CollectionCardImage extends StatelessWidget {
  const _CollectionCardImage({required this.imageUrl, required this.width, required this.height});

  final String? imageUrl;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: width,
        height: height,
        child: imageUrl == null
            ? ColoredBox(
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.style_outlined),
              )
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => ColoredBox(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.style_outlined),
                ),
              ),
      ),
    );
  }
}

class CollectionEntryFormSheet extends StatefulWidget {
  const CollectionEntryFormSheet({
    super.key,
    this.card,
    this.existingEntry,
  }) : assert(card != null || existingEntry != null);

  final ScryfallCardPrint? card;
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
    if (card == null) return;
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
    final cardName = entry?.cardName ?? widget.card?.name ?? '';

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
