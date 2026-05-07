import 'dart:async';

import 'package:flutter/material.dart';

import '../../../services/scryfall_search_engine.dart';
import '../../../services/scryfall_card_repository.dart';
import '../../../services/scryfall_service.dart';
import '../../../services/localization_service.dart';
import 'search_syntax_page.dart';
import 'advanced_filter_modal.dart';
import 'widgets/search_bar.dart';
import 'widgets/result_list.dart';
import 'widgets/card_detail_sheet.dart';

// ---------------------------------------------------------------------------
// Search Page – helpers
// ---------------------------------------------------------------------------

class _SearchUiResult {
  const _SearchUiResult({
    required this.card,
    required this.group,
  });

  final Map<String, dynamic> card;
  final ScryfallCardGroup? group;
}

// ---------------------------------------------------------------------------
// Search Page
// ---------------------------------------------------------------------------

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final ScryfallService _scry = ScryfallService();
  final ScryfallSearchEngine _searchEngine = ScryfallSearchEngine();
  late final ScryfallCardRepository _repo = ScryfallCardRepository(
    service: _scry,
  );
  bool _allPrintingsMode = false;
  bool _baseDataReady = false;
  bool _allCardsReady = false;
  List<_SearchUiResult> _allMatches = [];
  List<_SearchUiResult>? _results;
  int _displayedCount = 0;
  static const int _pageSize = 50;
  int _searchGeneration = 0;

  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _loadingData = false;
  bool _searching = false;
  double? _downloadProgress;
  bool _downloadError = false;
  Timer? _debounce;

  // Download step tracking (for downloadingStep l10n key)
  int _downloadStep  = 0;
  int _downloadTotal = 3;

  // View mode toggle
  bool _isGridView = true;

  // Unsupported keyword warnings
  List<String> _unsupportedWarnings = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    setState(() => _loadingData = true);
    await _repo.loadBaseData();
    if (!mounted) return;
    setState(() {
      _baseDataReady = true;
      _allCardsReady = _repo.allCardsLoaded;
      _results = null;
      _allMatches = [];
      _displayedCount = 0;
      _loadingData = false;
    });
  }

  Future<void> _checkAndLoad({bool forceDownload = false}) async {
    setState(() {
      _loadingData = true;
      _downloadProgress = null;
      _downloadError = false;
      _downloadStep = 0;
    });
    final types = [
      ScryfallBulkType.oracleCards,
      ScryfallBulkType.defaultCards,
    ];
    if (_repo.allCardsLoaded) {
      types.add(ScryfallBulkType.allCards);
    }
    _downloadTotal = types.length;
    var step = 0;
    for (final type in types) {
      step++;
      final hasLocalCache = await _scry.hasLocalCache(bulkType: type);
      final stale = await _scry.isCacheStale(bulkType: type);
      if (forceDownload || !hasLocalCache || stale) {
        final uri = await _scry.fetchBulkIndexAndChooseUri(bulkType: type);
        if (uri != null) {
          try {
            if (mounted) setState(() { _downloadProgress = 0; _downloadStep = step; });
            await _scry.downloadBulk(
              uri,
              bulkType: type,
              onProgress: (p) {
                if (mounted) setState(() => _downloadProgress = p);
              },
            );
            if (mounted) setState(() => _downloadProgress = null);
          } catch (_) {
            if (!mounted) return;
            setState(() {
              _loadingData = false;
              _downloadProgress = null;
              _downloadError = true;
            });
            return;
          }
        }
      }
    }

    await _repo.loadBaseData();
    if (_repo.allCardsLoaded) {
      await _repo.ensureAllCardsLoaded();
    }
    if (!mounted) return;
    setState(() {
      _baseDataReady = true;
      _allCardsReady = _repo.allCardsLoaded;
      _results = null;
      _allMatches = [];
      _displayedCount = 0;
      _loadingData = false;
      _downloadProgress = null;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (_displayedCount >= _allMatches.length) return;
    setState(() {
      _displayedCount = (_displayedCount + _pageSize).clamp(0, _allMatches.length);
      _results = _allMatches.sublist(0, _displayedCount);
    });
  }

  Future<void> _ensureAllCardsReady() async {
    final hasLocalCache =
        await _scry.hasLocalCache(bulkType: ScryfallBulkType.allCards);
    final stale = await _scry.isCacheStale(bulkType: ScryfallBulkType.allCards);
    if (!hasLocalCache || stale) {
      final uri =
          await _scry.fetchBulkIndexAndChooseUri(bulkType: ScryfallBulkType.allCards);
      if (uri != null) {
        await _scry.downloadBulk(
          uri,
          bulkType: ScryfallBulkType.allCards,
          onProgress: (p) {
            if (mounted) setState(() => _downloadProgress = p);
          },
        );
      }
    }
    await _repo.ensureAllCardsLoaded();
    if (mounted) {
      setState(() => _downloadProgress = null);
    }
  }

  Future<void> _executeSearch() async {
    final q = _controller.text.trim();
    if (!_baseDataReady || q.isEmpty) {
      setState(() {
        _allMatches = [];
        _displayedCount = 0;
        _results = null;
        _searching = false;
        _unsupportedWarnings = [];
      });
      return;
    }

    final generation = ++_searchGeneration;
    setState(() {
      _searching = true;
      _results = null;
    });

    final plan = planScryfallQuery(
      query: q,
      forceAllPrintingsMode: _allPrintingsMode,
    );

    if (plan.requiresAllCards && !_repo.allCardsLoaded) {
      await _ensureAllCardsReady();
    }

    final dataset = plan.requiresAllCards
        ? _repo.allSearchCards()
        : _repo.defaultSearchCards();
    final matches = await Future(() => _searchEngine.filterCards(dataset, q));
    final uiMatches = matches
        .map(
          (card) => _SearchUiResult(
            card: card,
            group: _repo.groupForCard(card),
          ),
        )
        .toList();

    if (!mounted || generation != _searchGeneration) return;

    setState(() {
      _allCardsReady = _repo.allCardsLoaded;
      _allMatches = uiMatches;
      _displayedCount = uiMatches.length.clamp(0, _pageSize);
      _results = _allMatches.sublist(0, _displayedCount);
      _searching = false;
      _unsupportedWarnings = _searchEngine.analyzeQuery(q);
    });
  }

  // Bug 1 fix: setState after text assignment so clear button appears.
  // Bug 2 fix: append mode – new filter clauses are added to existing query.
  Future<void> _openFilterMenu() async {
    String? built;
    try {
      built = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const AdvancedFilterModal(),
      );
    } catch (e, st) {
      debugPrint('Error opening filter modal: $e\n$st');
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to open filter: $e'),
          actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))],
        ),
      );
      return;
    }

    if (built != null && built.isNotEmpty) {
      final existing = _controller.text.trim();
      _controller.text = existing.isEmpty ? built : '$existing $built';
      setState(() {}); // refresh clear-button visibility (Bug 1)
      _debounce?.cancel();
      _executeSearch();
    }
  }

  void _showStatusInfo() {
    final loc = appLocalizations;
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.translate('search.metaTitle'),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(loc.translate('search.syntaxHint'), style: theme.textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(loc.translate('search.defaultCardsSource'), style: theme.textTheme.bodySmall),
              if (_baseDataReady) ...[
                const SizedBox(height: 4),
                Text(
                  loc
                      .translate('search.metaCardsLoaded')
                      .replaceAll('{count}', _repo.defaultCardsCount.toString()),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  _allPrintingsMode
                      ? _allCardsReady
                          ? loc.translate('search.modeAllCardsReady')
                          : loc.translate('search.modeAllCardsOnDemand')
                      : loc.translate('search.modeDefaultCards'),
                  style: theme.textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // Card detail bottom sheet
  void _showCardDetail(BuildContext context, _SearchUiResult result) {
    final variants = result.group?.variants ?? [result.card];
    showCardDetailSheet(
      context,
      result.card,
      variants: variants,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Card image helpers
  // ---------------------------------------------------------------------------

  String? _getCardImageUrl(Map<String, dynamic> card) {
    final imageUris = card['image_uris'];
    if (imageUris is Map) {
      return (imageUris['normal'] ?? imageUris['small'] ?? imageUris['large'])
          ?.toString();
    }
    // Double-faced / adventure cards store images per face
    final faces = card['card_faces'];
    if (faces is List && faces.isNotEmpty) {
      final face0 = faces[0] as Map<String, dynamic>?;
      final faceUris = face0?['image_uris'];
      if (faceUris is Map) {
        return (faceUris['normal'] ?? faceUris['small'] ?? faceUris['large'])
            ?.toString();
      }
    }
    return null;
  }

  Widget _buildCardImageItem(BuildContext context, _SearchUiResult result) {
    final card = result.card;
    final imageUrl = _getCardImageUrl(card);
    final name = card['name']?.toString() ?? '';
    final theme = Theme.of(context);

    Widget imageWidget;
    if (imageUrl != null) {
      imageWidget = Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return Container(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Center(
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (ctx, _, _) => _cardPlaceholder(theme, name),
      );
    } else {
      imageWidget = _cardPlaceholder(theme, name);
    }

    return GestureDetector(
      onTap: () => _showCardDetail(context, result),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageWidget,
      ),
    );
  }

  Widget _buildCardListItem(BuildContext context, _SearchUiResult result) {
    final card = result.card;
    final loc = appLocalizations;
    final name    = card['name']?.toString()    ?? '';
    final typeLine = card['type_line']?.toString() ?? '';
    final setCode = card['set']?.toString().toUpperCase() ?? '';
    final variants = (card['_av_variant_count'] as int?) ?? 1;
    final languages = (card['_av_languages'] as List?)?.length ?? 0;
    final variantSummary = loc
        .translate('search.variantSummary')
        .replaceAll('{variants}', variants.toString())
        .replaceAll('{languages}', languages.toString());
    final cmcRaw  = card['cmc'];
    final cmcStr  = cmcRaw != null
        ? cmcRaw.toString().replaceAll(RegExp(r'\.0$'), '')
        : '';
    final theme = Theme.of(context);

    return ListTile(
      dense: true,
      title: Text(
        name,
        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        typeLine,
        style: theme.textTheme.bodySmall,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (cmcStr.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                cmcStr,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.primary),
              ),
            ),
          const SizedBox(width: 6),
          Text(
            setCode,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.secondary),
          ),
          if (variants > 1) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                variantSummary,
                style: theme.textTheme.labelSmall,
              ),
            ),
          ],
        ],
      ),
      onTap: () => _showCardDetail(context, result),
    );
  }

  Widget _cardPlaceholder(ThemeData theme, String name) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: Text(
        name,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = appLocalizations;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('nav.search')),
        actions: [
          // Grid / list view toggle
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            tooltip: _isGridView ? 'List view' : 'Grid view',
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: loc.translate('search.metaTitle'),
            onPressed: _baseDataReady ? _showStatusInfo : null,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: loc.translate('search.downloadAction'),
            onPressed: _loadingData ? null : () => _checkAndLoad(forceDownload: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // Download progress bar
          if (_downloadProgress != null) ...[
            LinearProgressIndicator(value: _downloadProgress),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _downloadStep > 0
                      ? loc
                          .translate('search.downloadingStep')
                          .replaceAll('{current}', _downloadStep.toString())
                          .replaceAll('{total}', _downloadTotal.toString())
                          .replaceAll('{progress}', '${(_downloadProgress! * 100).toInt()}')
                      : loc
                          .translate('search.statusDownloading')
                          .replaceAll('{progress}', '${(_downloadProgress! * 100).toInt()}'),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
          ],

          // Bug 4 fix: error banner with a Retry button alongside the dismiss
          if (_downloadError)
            Container(
              width: double.infinity,
              color: theme.colorScheme.errorContainer,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      size: 16, color: theme.colorScheme.onErrorContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      loc.translate('search.statusError'),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onErrorContainer),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.onErrorContainer,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      setState(() => _downloadError = false);
                      _checkAndLoad(forceDownload: true);
                    },
                    child: Text(loc.translate('search.retryDownload'),
                        style: const TextStyle(fontSize: 12)),
                  ),
                  IconButton(
                    icon: Icon(Icons.close,
                        color: theme.colorScheme.onErrorContainer),
                    iconSize: 16,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => setState(() => _downloadError = false),
                  ),
                ],
              ),
            ),

          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Search bar
                  AppSearchBar(
                    controller: _controller,
                    enabled: _baseDataReady,
                    onClear: () {
                      _controller.clear();
                      _debounce?.cancel();
                      setState(() {
                        _allMatches = [];
                        _displayedCount = 0;
                        _results = null;
                        _unsupportedWarnings = [];
                      });
                    },
                    onSubmitted: (_) {
                      _debounce?.cancel();
                      _executeSearch();
                    },
                    onChanged: (_) {
                      setState(() {});
                      _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 400), _executeSearch);
                    },
                    onOpenFilter: _baseDataReady ? _openFilterMenu : null,
                    onOpenSyntax: () async {
                      final example = await Navigator.of(context).push<String>(
                        MaterialPageRoute(builder: (_) => SearchSyntaxPage()),
                      );
                      if (example != null && example.isNotEmpty && mounted) {
                        _controller.text = example;
                        setState(() {});
                        _debounce?.cancel();
                        _executeSearch();
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ChoiceChip(
                        label: Text(loc.translate('search.oracleOnlyMode')),
                        selected: !_allPrintingsMode,
                        onSelected: (selected) {
                          if (!selected) return;
                          setState(() => _allPrintingsMode = false);
                          _executeSearch();
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text(loc.translate('search.allPrintingsMode')),
                        selected: _allPrintingsMode,
                        onSelected: (selected) {
                          if (!selected) return;
                          setState(() => _allPrintingsMode = true);
                          _executeSearch();
                        },
                      ),
                    ],
                  ),

                  // Result count header + unsupported keyword warnings
                  if (_results != null && !_searching) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _allMatches.isEmpty
                            ? loc.translate('search.noResults')
                            : _displayedCount >= _allMatches.length
                                ? loc
                                    .translate('search.resultsAll')
                                    .replaceAll('{total}', _allMatches.length.toString())
                                : loc
                                    .translate('search.resultsShowing')
                                    .replaceAll('{shown}', _displayedCount.toString())
                                    .replaceAll('{total}', _allMatches.length.toString()),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                    ),
                    if (_unsupportedWarnings.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          for (final kw in _unsupportedWarnings)
                            Chip(
                              label: Text(
                                loc
                                    .translate('search.unsupportedKeyword')
                                    .replaceAll('{keyword}', kw),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                              ),
                              backgroundColor: theme.colorScheme.errorContainer,
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                        ],
                      ),
                    ],
                  ],

                  const SizedBox(height: 8),

                  // Results / placeholder (extracted)
                  Expanded(
                    child: ResultList(
                      loadingData: _loadingData,
                      searching: _searching,
                      results: _results,
                      isGridView: _isGridView,
                      scrollController: _scrollController,
                      gridItemBuilder: (ctx, index) {
                        final item = _results![index];
                        return _buildCardImageItem(ctx, item);
                      },
                      listItemBuilder: (ctx, index) {
                        final item = _results![index];
                        return _buildCardListItem(ctx, item);
                      },
                      tryExamplesBuilder: (ctx) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.manage_search, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                          const SizedBox(height: 12),
                          Text(loc.translate('search.hint'), textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                          const SizedBox(height: 16),
                          Text(loc.translate('search.tryExample'), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            alignment: WrapAlignment.center,
                            children: [
                              for (final key in const ['example1', 'example2', 'example3', 'example4'])
                                ActionChip(
                                  label: Text(loc.translate('search.$key'), style: theme.textTheme.labelSmall),
                                  onPressed: !_baseDataReady
                                      ? null
                                      : () {
                                          _controller.text = loc.translate('search.$key');
                                          setState(() {});
                                          _debounce?.cancel();
                                          _executeSearch();
                                        },
                                ),
                            ],
                          ),
                        ],
                      ),
                      noResultsBuilder: (ctx) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                          const SizedBox(height: 12),
                          Text(loc.translate('search.noResults'), style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
