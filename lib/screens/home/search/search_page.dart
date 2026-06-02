import 'package:flutter/material.dart';

import '../../../models/vault_deck.dart';
import '../../../services/deck_storage.dart';
import '../../../services/localization_service.dart';
import '../../../services/scryfall/bulk_data_type.dart';
import '../../../services/scryfall/download_service.dart';
import '../../../services/scryfall/scryfall_card_print.dart';
import '../../../services/scryfall/scryfall_indexed_search_data_source.dart';
import '../../../services/scryfall/scryfall_remote_search_data_source.dart';
import '../../../services/scryfall/scryfall_search_query.dart';
import '../../../services/scryfall/scryfall_search_repository.dart';
import '../../../services/scryfall/scryfall_sqlite_search_index.dart';
import 'search_sort_mode.dart';
import 'widgets/compact_search_bar.dart';
import 'widgets/search_card_image_tile.dart';
import 'widgets/search_empty_state.dart';
import 'widgets/search_error_banner.dart';
import 'widgets/search_index_status_icons.dart';
import 'widgets/search_results_header.dart';
import 'widgets/search_source_icon.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final HybridScryfallSearchRepository _searchRepository;
  late final ScryfallRemoteSearchDataSource _remoteDataSource;
  final DeckStorage _deckStorage = DeckStorage();

  final TextEditingController _searchController = TextEditingController();
  bool _checkingIndexStatus = true;
  bool _isSearching = false;
  int _searchGeneration = 0;
  String? _searchError;
  ScryfallSearchResultSource? _lastResultSource;
  SearchSortMode _sortMode = SearchSortMode.nameAsc;
  Map<ScryfallBulkDataType, SearchIndexStatus> _indexStatuses = const <ScryfallBulkDataType, SearchIndexStatus>{};
  List<ScryfallCardPrint> _results = const <ScryfallCardPrint>[];

  @override
  void initState() {
    super.initState();
    _remoteDataSource = ScryfallRemoteSearchDataSource();
    _searchRepository = HybridScryfallSearchRepository(
      localDataSource: ScryfallIndexedSearchDataSource(),
      remoteDataSource: _remoteDataSource,
      planner: ScryfallSearchPlanner(),
    );
    _refreshIndexStatuses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _remoteDataSource.dispose();
    super.dispose();
  }

  Future<void> _refreshIndexStatuses() async {
    if (mounted) setState(() => _checkingIndexStatus = true);
    final service = DownloadService.instance;
    final statuses = <ScryfallBulkDataType, SearchIndexStatus>{};

    for (final type in ScryfallBulkDataType.values) {
      try {
        final file = await service.getLocalFile(type: type);
        if (file == null) {
          statuses[type] = SearchIndexStatus.missing;
          continue;
        }

        final ready = await ScryfallSqliteSearchIndex.instance.isIndexReady(
          type: type,
          sourceFile: file,
        );
        statuses[type] = ready ? SearchIndexStatus.ready : SearchIndexStatus.preparing;
      } catch (_) {
        statuses[type] = SearchIndexStatus.missing;
      }
    }

    if (!mounted) return;
    setState(() {
      _indexStatuses = statuses;
      _checkingIndexStatus = false;
    });
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    final generation = ++_searchGeneration;

    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _results = const <ScryfallCardPrint>[];
        _searchError = null;
        _lastResultSource = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
      _lastResultSource = null;
    });

    try {
      final result = await _searchRepository.search(
        query,
        sortMode: _sortMode.repositorySortMode,
      );
      if (!mounted || generation != _searchGeneration) return;
      setState(() {
        _results = result.cards;
        _lastResultSource = result.source;
      });
      await _refreshIndexStatuses();
    } catch (error) {
      if (!mounted || generation != _searchGeneration) return;
      setState(() {
        _results = const <ScryfallCardPrint>[];
        _searchError = 'Suche fehlgeschlagen: $error';
        _lastResultSource = null;
      });
    } finally {
      if (mounted && generation == _searchGeneration) {
        setState(() => _isSearching = false);
      }
    }
  }

  Future<void> _setSortMode(SearchSortMode sortMode) async {
    setState(() => _sortMode = sortMode);
    if (_results.isNotEmpty || _searchController.text.trim().isNotEmpty) {
      await _performSearch();
    }
  }

  Future<void> _addCardToDeck(ScryfallCardPrint card) async {
    try {
      final decks = await _deckStorage.loadDecks();
      if (!mounted) return;

      if (decks.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appLocalizations.translate('decks.createDeckFirst'))),
        );
        return;
      }

      final selectedDeck = await showModalBottomSheet<VaultDeck>(
        context: context,
        showDragHandle: true,
        builder: (context) => _SelectDeckSheet(decks: decks, card: card),
      );
      if (selectedDeck == null) return;

      final updatedDeck = selectedDeck.addOrIncrementCard(DeckEntry.fromScryfallCard(card));
      await _deckStorage.upsertDeck(updatedDeck);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appLocalizations
                .translate('decks.cardAdded')
                .replaceAll('{card}', card.name)
                .replaceAll('{deck}', updatedDeck.name),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  void _showCardPreview(ScryfallCardPrint card) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _CardPreviewSheet(
        card: card,
        onAddToDeck: () {
          Navigator.of(context).pop();
          _addCardToDeck(card);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = appLocalizations;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('nav.search')),
        actions: [
          if (_lastResultSource != null) SearchSourceIcon(source: _lastResultSource!),
          SearchIndexStatusIcons(
            checking: _checkingIndexStatus,
            statuses: _indexStatuses,
            onRefresh: _refreshIndexStatuses,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CompactSearchBar(
                    controller: _searchController,
                    isSearching: _isSearching,
                    onSearch: _performSearch,
                  ),
                  if (_searchError != null) ...[
                    const SizedBox(height: 10),
                    SearchErrorBanner(message: _searchError!),
                  ],
                  if (_results.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    SearchResultsHeader(
                      count: _results.length,
                      sortMode: _sortMode,
                      onSortModeChanged: _setSortMode,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_isSearching && _results.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_results.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: SearchEmptyState(onExampleTap: _runExampleSearch),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverGrid.builder(
                itemCount: _results.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 190,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.714,
                ),
                itemBuilder: (context, index) {
                  final card = _results[index];
                  return SearchCardImageTile(
                    card: card,
                    onTap: () => _showCardPreview(card),
                    onAddToDeck: () => _addCardToDeck(card),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _runExampleSearch(String query) async {
    _searchController.text = query;
    await _performSearch();
  }
}

class _SelectDeckSheet extends StatelessWidget {
  const _SelectDeckSheet({required this.decks, required this.card});

  final List<VaultDeck> decks;
  final ScryfallCardPrint card;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          Text(
            appLocalizations.translate('decks.addToDeck'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(card.name),
          const SizedBox(height: 16),
          ...decks.map(
            (deck) => Card(
              child: ListTile(
                leading: const Icon(Icons.layers),
                title: Text(deck.name),
                subtitle: Text('${deck.format} · ${deck.totalCards} ${appLocalizations.translate('decks.cards')}'),
                onTap: () => Navigator.of(context).pop(deck),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardPreviewSheet extends StatelessWidget {
  const _CardPreviewSheet({required this.card, required this.onAddToDeck});

  final ScryfallCardPrint card;
  final VoidCallback onAddToDeck;

  @override
  Widget build(BuildContext context) {
    final imageUrl = card.displayImageNormals.isNotEmpty
        ? card.displayImageNormals.first
        : card.displayImageSmalls.isNotEmpty
            ? card.displayImageSmalls.first
            : null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 88,
                    height: 122,
                    child: imageUrl == null
                        ? ColoredBox(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.style_outlined),
                          )
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => ColoredBox(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.style_outlined),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(card.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      if (card.manaCost != null) Text(card.manaCost!),
                      if (card.typeLine.isNotEmpty) Text(card.typeLine),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: onAddToDeck,
                        icon: const Icon(Icons.playlist_add),
                        label: Text(appLocalizations.translate('decks.addToDeck')),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
