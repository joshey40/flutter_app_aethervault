import 'package:flutter/material.dart';

import '../../../services/localization_service.dart';
import '../../../services/scryfall/download_service.dart';
import '../../../services/scryfall/scryfall_card_print.dart';
import '../../../services/scryfall/scryfall_indexed_search_data_source.dart';
import '../../../services/scryfall/scryfall_remote_search_data_source.dart';
import '../../../services/scryfall/scryfall_search_query.dart';
import '../../../services/scryfall/scryfall_search_repository.dart';
import '../../../theme/app_theme.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final HybridScryfallSearchRepository _searchRepository;
  late final ScryfallRemoteSearchDataSource _remoteDataSource;

  final TextEditingController _searchController = TextEditingController();
  bool _oracleCardsAvailable = false;
  bool _checkingAvailability = true;
  bool _isSearching = false;
  int _searchGeneration = 0;
  String? _searchError;
  ScryfallSearchResultSource? _lastResultSource;
  _SearchSortMode _sortMode = _SearchSortMode.nameAsc;
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
    _checkScryfallAvailability();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _remoteDataSource.dispose();
    super.dispose();
  }

  Future<void> _checkScryfallAvailability() async {
    setState(() => _checkingAvailability = true);
    try {
      final available = await DownloadService.instance.isOracleCardsAvailable();
      if (!mounted) return;
      setState(() => _oracleCardsAvailable = available);
    } catch (_) {
      if (!mounted) return;
      setState(() => _oracleCardsAvailable = false);
    } finally {
      if (mounted) setState(() => _checkingAvailability = false);
    }
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
      final result = await _searchRepository.search(query);
      if (!mounted || generation != _searchGeneration) return;
      setState(() {
        _results = _sorted(result.cards);
        _lastResultSource = result.source;
      });
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

  List<ScryfallCardPrint> _sorted(List<ScryfallCardPrint> cards) {
    final sorted = [...cards];
    sorted.sort((a, b) {
      switch (_sortMode) {
        case _SearchSortMode.nameAsc:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case _SearchSortMode.nameDesc:
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        case _SearchSortMode.manaValueAsc:
          return (a.manaValue ?? 999).compareTo(b.manaValue ?? 999);
        case _SearchSortMode.newestFirst:
          return (b.releasedAt ?? DateTime(0)).compareTo(a.releasedAt ?? DateTime(0));
        case _SearchSortMode.oldestFirst:
          return (a.releasedAt ?? DateTime(9999)).compareTo(b.releasedAt ?? DateTime(9999));
        case _SearchSortMode.setAsc:
          final setCompare = a.setCode.compareTo(b.setCode);
          if (setCompare != 0) return setCompare;
          return a.collectorNumber.compareTo(b.collectorNumber);
      }
    });
    return sorted;
  }

  void _setSortMode(_SearchSortMode sortMode) {
    setState(() {
      _sortMode = sortMode;
      _results = _sorted(_results);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = appLocalizations;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('nav.search')),
        actions: [
          if (_lastResultSource != null) _SearchSourceIcon(source: _lastResultSource!),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _OfflineStatusIcon(
              checking: _checkingAvailability,
              ready: _oracleCardsAvailable,
              onRefresh: _checkScryfallAvailability,
            ),
          ),
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
                  _CompactSearchBar(
                    controller: _searchController,
                    isSearching: _isSearching,
                    onSearch: _performSearch,
                  ),
                  if (_searchError != null) ...[
                    const SizedBox(height: 10),
                    _ErrorBanner(message: _searchError!),
                  ],
                  if (_results.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _ResultsHeader(
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
              child: _EmptySearchState(onExampleTap: _runExampleSearch),
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
                itemBuilder: (context, index) => _CardImageTile(card: _results[index]),
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

enum _SearchSortMode {
  nameAsc('Name A–Z'),
  nameDesc('Name Z–A'),
  manaValueAsc('Mana Value'),
  newestFirst('Neueste zuerst'),
  oldestFirst('Älteste zuerst'),
  setAsc('Set / Nummer');

  const _SearchSortMode(this.label);
  final String label;
}

class _SearchSourceIcon extends StatelessWidget {
  const _SearchSourceIcon({required this.source});

  final ScryfallSearchResultSource source;

  @override
  Widget build(BuildContext context) {
    final (icon, tooltip) = switch (source) {
      ScryfallSearchResultSource.localOracleCards => (Icons.auto_stories_rounded, 'Letzte Suche: Oracle Cards'),
      ScryfallSearchResultSource.localDefaultCards => (Icons.storage_rounded, 'Letzte Suche: Default Cards'),
      ScryfallSearchResultSource.localAllCards => (Icons.inventory_2_rounded, 'Letzte Suche: All Cards'),
      ScryfallSearchResultSource.remoteScryfallApi => (Icons.cloud_sync_rounded, 'Letzte Suche: online'),
    };

    return Tooltip(
      message: tooltip,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Icon(icon, color: AppTheme.vaultAmber),
      ),
    );
  }
}

class _OfflineStatusIcon extends StatelessWidget {
  const _OfflineStatusIcon({
    required this.checking,
    required this.ready,
    required this.onRefresh,
  });

  final bool checking;
  final bool ready;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: checking
          ? 'Scryfall-Daten werden geprüft'
          : ready
              ? 'Offline-Suche bereit'
              : 'Offline-Suche nicht bereit',
      onPressed: checking ? null : onRefresh,
      icon: Icon(
        checking
            ? Icons.sync_rounded
            : ready
                ? Icons.cloud_done_rounded
                : Icons.cloud_off_rounded,
        color: checking
            ? Colors.grey
            : ready
                ? AppTheme.success
                : AppTheme.error,
      ),
    );
  }
}
