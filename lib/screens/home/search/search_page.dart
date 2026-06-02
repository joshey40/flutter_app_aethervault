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

  void _showCardPreview(ScryfallCardPrint card) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _CardDetailSheet(
        initialCard: card,
        loadPrintings: _remoteDataSource.searchPrintings,
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

class _CardDetailSheet extends StatefulWidget {
  const _CardDetailSheet({
    required this.initialCard,
    required this.loadPrintings,
  });

  final ScryfallCardPrint initialCard;
  final Future<List<ScryfallCardPrint>> Function(ScryfallCardPrint card) loadPrintings;

  @override
  State<_CardDetailSheet> createState() => _CardDetailSheetState();
}

class _CardDetailSheetState extends State<_CardDetailSheet> {
  late ScryfallCardPrint _selectedCard;
  List<ScryfallCardPrint> _printings = const <ScryfallCardPrint>[];
  bool _loadingPrintings = true;
  String? _printingError;

  @override
  void initState() {
    super.initState();
    _selectedCard = widget.initialCard;
    _loadPrintings();
  }

  Future<void> _loadPrintings() async {
    setState(() {
      _loadingPrintings = true;
      _printingError = null;
    });

    try {
      final printings = await widget.loadPrintings(widget.initialCard);
      if (!mounted) return;
      setState(() {
        _printings = _deduplicatePrintings([widget.initialCard, ...printings]);
        _selectedCard = _printings.firstWhere(
          (card) => card.id == widget.initialCard.id,
          orElse: () => _printings.first,
        );
        _loadingPrintings = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _printings = <ScryfallCardPrint>[widget.initialCard];
        _selectedCard = widget.initialCard;
        _printingError = error.toString();
        _loadingPrintings = false;
      });
    }
  }

  List<ScryfallCardPrint> _deduplicatePrintings(List<ScryfallCardPrint> cards) {
    final seen = <String>{};
    final deduplicated = <ScryfallCardPrint>[];
    for (final card in cards) {
      if (seen.add(card.id)) deduplicated.add(card);
    }
    return deduplicated;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.92;
    final imageUrl = _bestImageUrl(_selectedCard);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: AspectRatio(
                    aspectRatio: 0.714,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: imageUrl == null
                          ? ColoredBox(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.style_outlined, size: 52),
                            )
                          : Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => ColoredBox(
                                color: theme.colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.style_outlined, size: 52),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _selectedCard.name,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Center(child: _ManaCostRow(manaCost: _selectedCard.manaCost)),
              if (_selectedCard.typeLine.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  _selectedCard.typeLine,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ],
              const SizedBox(height: 18),
              if (_loadingPrintings)
                const Center(child: CircularProgressIndicator())
              else
                DropdownButtonFormField<String>(
                  value: _selectedCard.id,
                  decoration: InputDecoration(
                    labelText: appLocalizations.translate('search.printing'),
                    border: const OutlineInputBorder(),
                  ),
                  items: _printings
                      .map(
                        (printing) => DropdownMenuItem(
                          value: printing.id,
                          child: Text(
                            _printingLabel(printing),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (id) {
                    if (id == null) return;
                    final next = _printings.firstWhere((printing) => printing.id == id);
                    setState(() => _selectedCard = next);
                  },
                ),
              if (_printingError != null) ...[
                const SizedBox(height: 8),
                Text(
                  appLocalizations.translate('search.printingsFailed'),
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                ),
              ],
              const SizedBox(height: 18),
              _InfoGrid(card: _selectedCard),
              if (_selectedCard.oracleText.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(
                  appLocalizations.translate('search.cardText'),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: _ManaText(text: _selectedCard.oracleText),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: null,
                icon: const Icon(Icons.inventory_2_outlined),
                label: Text(appLocalizations.translate('collection.addToCollection')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _bestImageUrl(ScryfallCardPrint card) {
    if (card.displayImageNormals.isNotEmpty) return card.displayImageNormals.first;
    if (card.displayImageSmalls.isNotEmpty) return card.displayImageSmalls.first;
    return null;
  }

  String _printingLabel(ScryfallCardPrint card) {
    final set = card.setCode.isEmpty ? '?' : card.setCode.toUpperCase();
    final number = card.collectorNumber.isEmpty ? '?' : card.collectorNumber;
    final lang = card.lang.toUpperCase();
    final date = card.releasedAt?.year.toString();
    return [set, '#$number', lang, if (date != null) date].join(' · ');
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.card});

  final ScryfallCardPrint card;

  @override
  Widget build(BuildContext context) {
    final values = <({String label, String value})>[
      if (card.setCode.isNotEmpty) (label: appLocalizations.translate('search.cardDetailSet'), value: card.setCode.toUpperCase()),
      if (card.collectorNumber.isNotEmpty) (label: appLocalizations.translate('search.collectorNumber'), value: card.collectorNumber),
      if (card.lang.isNotEmpty) (label: appLocalizations.translate('search.cardDetailLang'), value: card.lang.toUpperCase()),
      if (card.rarity.isNotEmpty) (label: appLocalizations.translate('search.rarity'), value: card.rarity),
      if (card.artist != null && card.artist!.isNotEmpty) (label: appLocalizations.translate('search.artist'), value: card.artist!),
      if (card.releasedAt != null) (label: appLocalizations.translate('search.released'), value: _formatDate(card.releasedAt!)),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: values
          .map(
            (item) => SizedBox(
              width: 150,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.label, style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(height: 4),
                      Text(item.value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  static String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _ManaCostRow extends StatelessWidget {
  const _ManaCostRow({required this.manaCost});

  final String? manaCost;

  @override
  Widget build(BuildContext context) {
    final symbols = _parseManaSymbols(manaCost ?? '');
    if (symbols.isEmpty) return const SizedBox.shrink();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: symbols.map((symbol) => _ManaSymbol(symbol: symbol)).toList(growable: false),
    );
  }
}

class _ManaText extends StatelessWidget {
  const _ManaText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'\{([^}]+)\}');
    var cursor = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5, vertical: 1),
            child: _ManaSymbol(symbol: match.group(1) ?? ''),
          ),
        ),
      );
      cursor = match.end;
    }

    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }

    return Text.rich(
      TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: spans,
      ),
    );
  }
}

class _ManaSymbol extends StatelessWidget {
  const _ManaSymbol({required this.symbol});

  final String symbol;

  @override
  Widget build(BuildContext context) {
    final normalized = symbol.toUpperCase();
    final colors = _colorsForSymbol(normalized);
    final background = colors.length == 1 ? colors.first : null;
    final foreground = _foregroundForSymbol(normalized);

    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: background,
        gradient: colors.length > 1
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              )
            : null,
        border: Border.all(color: Colors.black.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            color: Colors.black.withOpacity(0.12),
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        _symbolLabel(normalized),
        style: TextStyle(
          color: foreground,
          fontSize: normalized.length > 1 ? 9 : 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  static String _symbolLabel(String symbol) {
    return symbol.replaceAll('/', '');
  }

  static Color _foregroundForSymbol(String symbol) {
    if (symbol.contains('B') || symbol.contains('U') || symbol.contains('R')) return Colors.white;
    return Colors.black87;
  }

  static List<Color> _colorsForSymbol(String symbol) {
    final parts = symbol.split('/');
    final colors = parts.map(_singleSymbolColor).whereType<Color>().toList(growable: false);
    if (colors.isNotEmpty) return colors;
    return <Color>[_singleSymbolColor(symbol) ?? const Color(0xFFE0E0E0)];
  }

  static Color? _singleSymbolColor(String symbol) {
    switch (symbol) {
      case 'W':
        return const Color(0xFFF5E7B2);
      case 'U':
        return const Color(0xFF4A90C2);
      case 'B':
        return const Color(0xFF2E2A28);
      case 'R':
        return const Color(0xFFD4513C);
      case 'G':
        return const Color(0xFF4F8F54);
      case 'C':
        return const Color(0xFFC9C4B8);
      default:
        return const Color(0xFFD7D2C3);
    }
  }
}

List<String> _parseManaSymbols(String manaCost) {
  final regex = RegExp(r'\{([^}]+)\}');
  return regex.allMatches(manaCost).map((match) => match.group(1) ?? '').where((symbol) => symbol.isNotEmpty).toList(growable: false);
}
