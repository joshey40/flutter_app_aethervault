import 'package:flutter/material.dart';

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
                itemBuilder: (context, index) => SearchCardImageTile(card: _results[index]),
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
