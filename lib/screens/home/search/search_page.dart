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
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (checking) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return IconButton(
      tooltip: ready ? 'Offline-Suche bereit' : 'Offline-Daten fehlen',
      onPressed: onRefresh,
      icon: Icon(
        ready ? Icons.offline_bolt_rounded : Icons.cloud_off_rounded,
        color: ready ? AppTheme.vaultAmber : Theme.of(context).colorScheme.error,
      ),
    );
  }
}

class _CompactSearchBar extends StatefulWidget {
  const _CompactSearchBar({
    required this.controller,
    required this.isSearching,
    required this.onSearch,
  });

  final TextEditingController controller;
  final bool isSearching;
  final Future<void> Function() onSearch;

  @override
  State<_CompactSearchBar> createState() => _CompactSearchBarState();
}

class _CompactSearchBarState extends State<_CompactSearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant _CompactSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppTheme.vaultSurfaceLight : AppTheme.vaultFog;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor.withOpacity(0.65)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded),
                  hintText: 'Kartensuche: t:dragon, o:draw, arcane signet...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  suffixIcon: widget.controller.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Eingabe löschen',
                          onPressed: () => widget.controller.clear(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => widget.onSearch(),
              ),
            ),
            const SizedBox(width: 6),
            FilledButton(
              onPressed: widget.isSearching ? null : widget.onSearch,
              style: FilledButton.styleFrom(
                minimumSize: const Size(48, 48),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: widget.isSearching
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_forward_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({
    required this.count,
    required this.sortMode,
    required this.onSortModeChanged,
  });

  final int count;
  final _SearchSortMode sortMode;
  final ValueChanged<_SearchSortMode> onSortModeChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$count Treffer',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        PopupMenuButton<_SearchSortMode>(
          tooltip: 'Sortierung ändern',
          initialValue: sortMode,
          onSelected: onSortModeChanged,
          itemBuilder: (context) => [
            for (final mode in _SearchSortMode.values)
              PopupMenuItem(
                value: mode,
                child: Row(
                  children: [
                    if (mode == sortMode) const Icon(Icons.check_rounded, size: 18) else const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Text(mode.label),
                  ],
                ),
              ),
          ],
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                sortMode.label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.sort_rounded, size: 18),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.78),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline_rounded, color: colorScheme.onErrorContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState({required this.onExampleTap});

  final Future<void> Function(String query) onExampleTap;

  @override
  Widget build(BuildContext context) {
    final examples = const [
      'arcane signet',
      't:dragon',
      'o:draw mv<=3',
      'ci:uw t:legendary',
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: AppTheme.vaultAmber.withOpacity(0.14),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.auto_awesome_rounded, size: 34, color: AppTheme.vaultAmber),
          ),
          const SizedBox(height: 16),
          Text(
            'Was suchst du?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Name eingeben oder Scryfall-Filter nutzen.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.64),
                ),
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final example in examples)
                ActionChip(
                  avatar: const Icon(Icons.search_rounded, size: 16),
                  label: Text(example),
                  onPressed: () => onExampleTap(example),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardImageTile extends StatefulWidget {
  const _CardImageTile({required this.card});

  final ScryfallCardPrint card;

  @override
  State<_CardImageTile> createState() => _CardImageTileState();
}

class _CardImageTileState extends State<_CardImageTile> {
  int _faceIndex = 0;

  @override
  void didUpdateWidget(covariant _CardImageTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.card.id != widget.card.id) {
      _faceIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final imageUrls = card.displayImageNormals.isNotEmpty
        ? card.displayImageNormals
        : card.displayImageSmalls;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placeholderColor = isDark ? AppTheme.vaultSurfaceLight : AppTheme.vaultFog;
    final selectedUrl = imageUrls.isEmpty ? null : imageUrls[_faceIndex.clamp(0, imageUrls.length - 1)];

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: placeholderColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.25 : 0.10),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: selectedUrl == null
                  ? _MissingImageCard(card: card)
                  : _NetworkCardImage(url: selectedUrl, card: card),
            ),
          ),
          if (imageUrls.length > 1)
            Positioned(
              top: 34,
              right: 7,
              child: Material(
                color: Colors.black.withOpacity(0.58),
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => setState(() => _faceIndex = (_faceIndex + 1) % imageUrls.length),
                  child: const Padding(
                    padding: EdgeInsets.all(7),
                    child: Icon(Icons.flip_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NetworkCardImage extends StatelessWidget {
  const _NetworkCardImage({required this.url, required this.card});

  final String url;
  final ScryfallCardPrint card;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _MissingImageCard(card: card),
    );
  }
}

class _MissingImageCard extends StatelessWidget {
  const _MissingImageCard({required this.card});

  final ScryfallCardPrint card;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.style_outlined, size: 32),
          const SizedBox(height: 10),
          Text(
            card.name,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
