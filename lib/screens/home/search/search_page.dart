import 'package:flutter/material.dart';

import '../../../services/localization_service.dart';
import '../../../services/scryfall/download_service.dart';
import '../../../services/scryfall/scryfall_card_print.dart';
import '../../../services/scryfall/scryfall_local_json_search_data_source.dart';
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
  bool _defaultCardsAvailable = false;
  bool _checkingAvailability = true;
  bool _isSearching = false;
  int _searchGeneration = 0;
  String? _searchError;
  ScryfallSearchResultSource? _lastResultSource;
  List<ScryfallCardPrint> _results = const <ScryfallCardPrint>[];

  @override
  void initState() {
    super.initState();
    _remoteDataSource = ScryfallRemoteSearchDataSource();
    _searchRepository = HybridScryfallSearchRepository(
      localDataSource: ScryfallLocalJsonSearchDataSource(),
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
      final available = await DownloadService.instance.isDefaultCardsAvailable();
      if (!mounted) return;
      setState(() => _defaultCardsAvailable = available);
    } catch (_) {
      if (!mounted) return;
      setState(() => _defaultCardsAvailable = false);
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
        _results = result.cards;
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

  @override
  Widget build(BuildContext context) {
    final loc = appLocalizations;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('nav.search')),
        actions: [
          if (_lastResultSource != null)
            _SearchSourceIcon(source: _lastResultSource!),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _OfflineStatusIcon(
              checking: _checkingAvailability,
              ready: _defaultCardsAvailable,
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
                    _ResultsHeader(count: _results.length),
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

class _SearchSourceIcon extends StatelessWidget {
  const _SearchSourceIcon({required this.source});

  final ScryfallSearchResultSource source;

  @override
  Widget build(BuildContext context) {
    final isLocal = source == ScryfallSearchResultSource.localDefaultCards;
    return Tooltip(
      message: isLocal ? 'Letzte Suche: lokal' : 'Letzte Suche: online',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Icon(
          isLocal ? Icons.storage_rounded : Icons.cloud_sync_rounded,
          color: isLocal ? AppTheme.vaultAmber : Theme.of(context).colorScheme.primary,
        ),
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
  const _ResultsHeader({required this.count});

  final int count;

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
        Text(
          'Antippen für Details später',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
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

class _CardImageTile extends StatelessWidget {
  const _CardImageTile({required this.card});

  final ScryfallCardPrint card;

  @override
  Widget build(BuildContext context) {
    final imageUrls = card.displayImageNormals.isNotEmpty
        ? card.displayImageNormals
        : card.displayImageSmalls;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placeholderColor = isDark ? AppTheme.vaultSurfaceLight : AppTheme.vaultFog;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
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
        child: imageUrls.isEmpty
            ? _MissingImageCard(card: card)
            : imageUrls.length == 1
                ? _NetworkCardImage(url: imageUrls.first, card: card)
                : _DoubleFacedCardImages(urls: imageUrls.take(2).toList(growable: false), card: card),
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

class _DoubleFacedCardImages extends StatelessWidget {
  const _DoubleFacedCardImages({required this.urls, required this.card});

  final List<String> urls;
  final ScryfallCardPrint card;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final url in urls)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _NetworkCardImage(url: url, card: card),
              ),
            ),
          ),
      ],
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
