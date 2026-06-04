import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../models/collection_entry.dart';
import '../../../models/vault_deck.dart';
import '../../../services/collection_storage.dart';
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
import '../../../services/scryfall/scryfall_symbology_service.dart';
import '../collection_page.dart';
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
  late final ScryfallSymbologyService _symbologyService;
  final DeckStorage _deckStorage = DeckStorage();
  final CollectionStorage _collectionStorage = CollectionStorage();

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
    _symbologyService = ScryfallSymbologyService();
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
    _symbologyService.dispose();
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

  Future<void> _addCardToCollection(ScryfallCardPrint card) async {
    try {
      final entry = await showModalBottomSheet<CollectionEntry>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) => CollectionEntryFormSheet(card: card),
      );
      if (entry == null) return;

      final savedEntry = await _collectionStorage.addEntry(entry);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appLocalizations
                .translate('collection.cardAdded')
                .replaceAll('{card}', savedEntry.cardName)
                .replaceAll('{quantity}', savedEntry.quantity.toString()),
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
      builder: (context) => _CardDetailSheet(
        initialCard: card,
        loadPrintings: _remoteDataSource.searchPrintings,
        loadSymbols: _symbologyService.loadSymbols,
        onAddToDeck: _addCardToDeck,
        onAddToCollection: _addCardToCollection,
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
    required this.loadSymbols,
    required this.onAddToDeck,
    required this.onAddToCollection,
  });

  final ScryfallCardPrint initialCard;
  final Future<List<ScryfallCardPrint>> Function(ScryfallCardPrint card) loadPrintings;
  final Future<Map<String, ScryfallSymbol>> Function() loadSymbols;
  final ValueChanged<ScryfallCardPrint> onAddToDeck;
  final ValueChanged<ScryfallCardPrint> onAddToCollection;

  @override
  State<_CardDetailSheet> createState() => _CardDetailSheetState();
}

class _CardDetailSheetState extends State<_CardDetailSheet> {
  late ScryfallCardPrint _selectedCard;
  List<ScryfallCardPrint> _printings = const <ScryfallCardPrint>[];
  Map<String, ScryfallSymbol> _symbols = const <String, ScryfallSymbol>{};
  bool _loadingPrintings = true;
  bool _loadingSymbols = true;
  String? _printingError;
  int _faceIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedCard = widget.initialCard;
    _loadPrintings();
    _loadSymbols();
  }

  Future<void> _loadSymbols() async {
    try {
      final symbols = await widget.loadSymbols();
      if (!mounted) return;
      setState(() {
        _symbols = symbols;
        _loadingSymbols = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingSymbols = false);
    }
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
        _faceIndex = 0;
        _loadingPrintings = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _printings = <ScryfallCardPrint>[widget.initialCard];
        _selectedCard = widget.initialCard;
        _printingError = error.toString();
        _faceIndex = 0;
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
    final faces = _selectedCard.displayFaces;
    final imageFaces = _imageFaces(_selectedCard);
    final canFlipImage = imageFaces.length > 1;
    final selectedImageFace = imageFaces.isEmpty ? null : imageFaces[_faceIndex.clamp(0, imageFaces.length - 1)];
    final imageUrl = _bestImageUrl(_selectedCard, selectedImageFace);

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
                  constraints: const BoxConstraints(maxWidth: 310),
                  child: Stack(
                    children: [
                      AspectRatio(
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
                      if (canFlipImage)
                        Positioned(
                          right: 10,
                          top: 10,
                          child: FilledButton.tonalIcon(
                            onPressed: () => setState(() => _faceIndex = (_faceIndex + 1) % imageFaces.length),
                            icon: const Icon(Icons.flip_rounded),
                            label: Text('${_faceIndex + 1}/${imageFaces.length}'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SelectableText(
                _selectedCard.name,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
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
                    setState(() {
                      _selectedCard = next;
                      _faceIndex = 0;
                    });
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
              ...faces.asMap().entries.map((entry) {
                final imageFaceIndex = imageFaces.indexOf(entry.value);
                return _FaceDetailsCard(
                  face: entry.value,
                  symbols: _symbols,
                  loadingSymbols: _loadingSymbols,
                  isSelectedImageFace: canFlipImage && imageFaceIndex == _faceIndex,
                  onShowFace: canFlipImage && imageFaceIndex != -1 ? () => setState(() => _faceIndex = imageFaceIndex) : null,
                );
              }),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => widget.onAddToCollection(_selectedCard),
                icon: const Icon(Icons.inventory_2_outlined),
                label: Text(appLocalizations.translate('collection.addToCollection')),
              ),
              const SizedBox(height: 8),
              FilledButton.tonalIcon(
                onPressed: () => widget.onAddToDeck(_selectedCard),
                icon: const Icon(Icons.playlist_add),
                label: Text(appLocalizations.translate('decks.addToDeck')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<ScryfallCardFace> _imageFaces(ScryfallCardPrint card) {
    return card.faces
        .where((face) => face.imageNormal != null || face.imageSmall != null)
        .toList(growable: false);
  }

  String? _bestImageUrl(ScryfallCardPrint card, ScryfallCardFace? face) {
    if (face?.imageNormal != null) return face!.imageNormal;
    if (face?.imageSmall != null) return face!.imageSmall;
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
          SelectableText(card.name),
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

class _FaceDetailsCard extends StatelessWidget {
  const _FaceDetailsCard({
    required this.face,
    required this.symbols,
    required this.loadingSymbols,
    required this.isSelectedImageFace,
    this.onShowFace,
  });

  final ScryfallCardFace face;
  final Map<String, ScryfallSymbol> symbols;
  final bool loadingSymbols;
  final bool isSelectedImageFace;
  final VoidCallback? onShowFace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        face.name,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      if (face.typeLine.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        SelectableText(face.typeLine, style: theme.textTheme.bodyMedium),
                      ],
                    ],
                  ),
                ),
                if (onShowFace != null)
                  IconButton(
                    tooltip: appLocalizations.translate('search.showFaceImage'),
                    onPressed: onShowFace,
                    icon: Icon(isSelectedImageFace ? Icons.visibility : Icons.visibility_outlined),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            _ManaCostRow(manaCost: face.manaCost, symbols: symbols, loadingSymbols: loadingSymbols),
            if (face.oracleText.isNotEmpty) ...[
              const SizedBox(height: 12),
              _ManaText(text: face.oracleText, symbols: symbols, loadingSymbols: loadingSymbols),
            ],
          ],
        ),
      ),
    );
  }
}

class _ManaCostRow extends StatelessWidget {
  const _ManaCostRow({
    required this.manaCost,
    required this.symbols,
    required this.loadingSymbols,
  });

  final String? manaCost;
  final Map<String, ScryfallSymbol> symbols;
  final bool loadingSymbols;

  @override
  Widget build(BuildContext context) {
    final parsedSymbols = _parseManaSymbols(manaCost ?? '');
    if (parsedSymbols.isEmpty) return const SizedBox.shrink();

    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 4,
      runSpacing: 4,
      children: parsedSymbols
          .map((symbol) => _ScryfallSymbolIcon(symbol: symbol, symbols: symbols, loadingSymbols: loadingSymbols))
          .toList(growable: false),
    );
  }
}

class _ManaText extends StatelessWidget {
  const _ManaText({
    required this.text,
    required this.symbols,
    required this.loadingSymbols,
  });

  final String text;
  final Map<String, ScryfallSymbol> symbols;
  final bool loadingSymbols;

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'\{([^}]+)\}');
    var cursor = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      final fullSymbol = match.group(0) ?? '';
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5, vertical: 1),
            child: _ScryfallSymbolIcon(symbol: fullSymbol, symbols: symbols, loadingSymbols: loadingSymbols, size: 18),
          ),
        ),
      );
      cursor = match.end;
    }

    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }

    return SelectableText.rich(
      TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: spans,
      ),
    );
  }
}

class _ScryfallSymbolIcon extends StatelessWidget {
  const _ScryfallSymbolIcon({
    required this.symbol,
    required this.symbols,
    required this.loadingSymbols,
    this.size = 24,
  });

  final String symbol;
  final Map<String, ScryfallSymbol> symbols;
  final bool loadingSymbols;
  final double size;

  @override
  Widget build(BuildContext context) {
    final normalizedSymbol = symbol.startsWith('{') ? symbol : '{$symbol}';
    final scryfallSymbol = symbols[normalizedSymbol];
    final svgUri = scryfallSymbol?.svgUri;

    if (!loadingSymbols && svgUri != null) {
      return Tooltip(
        message: scryfallSymbol?.english ?? normalizedSymbol,
        child: SvgPicture.network(
          svgUri.toString(),
          width: size,
          height: size,
          placeholderBuilder: (_) => _FallbackManaSymbol(symbol: normalizedSymbol, size: size),
        ),
      );
    }

    return _FallbackManaSymbol(symbol: normalizedSymbol, size: size);
  }
}

class _FallbackManaSymbol extends StatelessWidget {
  const _FallbackManaSymbol({required this.symbol, required this.size});

  final String symbol;
  final double size;

  @override
  Widget build(BuildContext context) {
    final label = symbol.replaceAll('{', '').replaceAll('}', '').replaceAll('/', '');
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border.all(color: Colors.black.withOpacity(0.22)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: size <= 18 ? 8 : 10, fontWeight: FontWeight.w900),
      ),
    );
  }
}

List<String> _parseManaSymbols(String manaCost) {
  final regex = RegExp(r'\{[^}]+\}');
  return regex.allMatches(manaCost).map((match) => match.group(0) ?? '').where((symbol) => symbol.isNotEmpty).toList(growable: false);
}
