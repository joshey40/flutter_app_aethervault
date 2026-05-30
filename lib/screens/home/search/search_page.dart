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
  bool _allCardsAvailable = false;
  bool _checkingAvailability = true;
  bool _isSearching = false;
  String? _searchError;
  ScryfallSearchResultSource? _lastResultSource;
  String? _lastFallbackReason;
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
      final service = DownloadService.instance;
      final defaultAvailable = await service.isDefaultCardsAvailable();
      final allAvailable = await service.isAllCardsAvailable();
      if (!mounted) return;
      setState(() {
        _defaultCardsAvailable = defaultAvailable;
        _allCardsAvailable = allAvailable;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _defaultCardsAvailable = false;
        _allCardsAvailable = false;
      });
    } finally {
      if (mounted) setState(() => _checkingAvailability = false);
    }
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _results = const <ScryfallCardPrint>[];
        _searchError = null;
        _lastResultSource = null;
        _lastFallbackReason = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
      _lastResultSource = null;
      _lastFallbackReason = null;
    });

    try {
      final result = await _searchRepository.search(query);
      if (!mounted) return;
      setState(() {
        _results = result.cards;
        _lastResultSource = result.source;
        _lastFallbackReason = result.fallbackReason;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _results = const <ScryfallCardPrint>[];
        _searchError = 'Suche fehlgeschlagen: $error';
      });
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = appLocalizations;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('nav.search')),
        actions: [
          IconButton(
            tooltip: 'Datenstatus aktualisieren',
            onPressed: _checkingAvailability ? null : _checkScryfallAvailability,
            icon: const Icon(Icons.sync_rounded),
          ),
        ],
      ),
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SearchHero(
                    controller: _searchController,
                    isSearching: _isSearching,
                    onSearch: _performSearch,
                  ),
                  const SizedBox(height: 12),
                  _buildStatusRow(),
                  if (_lastResultSource != null || _lastFallbackReason != null) ...[
                    const SizedBox(height: 10),
                    _buildResultSourceInfo(),
                  ],
                  if (_searchError != null) ...[
                    const SizedBox(height: 10),
                    _buildErrorCard(_searchError!),
                  ],
                  if (_results.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    _buildResultsHeader(),
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
              sliver: SliverList.separated(
                itemCount: _results.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) => _CardResultTile(card: _results[index]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StatusPill(
          icon: _checkingAvailability
              ? Icons.hourglass_top_rounded
              : _defaultCardsAvailable
                  ? Icons.offline_bolt_rounded
                  : Icons.cloud_off_rounded,
          label: _checkingAvailability
              ? 'Prüfe Daten'
              : _defaultCardsAvailable
                  ? 'Offline-Suche bereit'
                  : 'Offline-Suche fehlt',
          tone: _defaultCardsAvailable ? _StatusTone.success : _StatusTone.warning,
        ),
        _StatusPill(
          icon: _allCardsAvailable ? Icons.inventory_2_rounded : Icons.inventory_2_outlined,
          label: _allCardsAvailable ? 'Collection-Daten bereit' : 'Collection-Daten fehlen',
          tone: _allCardsAvailable ? _StatusTone.neutral : _StatusTone.warning,
        ),
      ],
    );
  }

  Widget _buildResultSourceInfo() {
    final sourceText = switch (_lastResultSource) {
      ScryfallSearchResultSource.localDefaultCards => 'Lokale Suche',
      ScryfallSearchResultSource.remoteScryfallApi => 'Online-Fallback',
      null => null,
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (sourceText != null)
          _StatusPill(
            icon: _lastResultSource == ScryfallSearchResultSource.localDefaultCards
                ? Icons.offline_bolt_rounded
                : Icons.cloud_sync_rounded,
            label: sourceText,
            tone: _lastResultSource == ScryfallSearchResultSource.localDefaultCards
                ? _StatusTone.success
                : _StatusTone.info,
          ),
        if (_lastFallbackReason != null && _lastFallbackReason!.isNotEmpty)
          _StatusPill(
            icon: Icons.info_outline_rounded,
            label: _lastFallbackReason!,
            tone: _StatusTone.info,
          ),
      ],
    );
  }

  Widget _buildResultsHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            '${_results.length} Treffer',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        Text(
          'max. 120 lokal',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.58),
              ),
        ),
      ],
    );
  }

  Widget _buildErrorCard(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.78),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
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

  Future<void> _runExampleSearch(String query) async {
    _searchController.text = query;
    await _performSearch();
  }
}

class _SearchHero extends StatelessWidget {
  const _SearchHero({
    required this.controller,
    required this.isSearching,
    required this.onSearch,
  });

  final TextEditingController controller;
  final bool isSearching;
  final Future<void> Function() onSearch;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? AppTheme.vaultSurface : Colors.white;
    final borderColor = isDark ? AppTheme.vaultSurfaceLight : AppTheme.vaultFog;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor.withOpacity(0.65)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.vaultAmber.withOpacity(isDark ? 0.20 : 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.travel_explore_rounded, color: AppTheme.vaultAmber),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Karten durchsuchen',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Scryfall-Syntax lokal nutzen, Fallback online.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.62),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded),
                      hintText: 'z. B. ci:uw mv<=3 o:draw',
                      suffixIcon: controller.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Eingabe löschen',
                              onPressed: () => controller.clear(),
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => onSearch(),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: isSearching ? null : onSearch,
                  icon: isSearching
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Suchen'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _StatusTone { neutral, success, warning, info }

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final _StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _colorsForTone(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.$2.withOpacity(0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.$2),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.$3,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, Color) _colorsForTone(bool isDark) {
    switch (tone) {
      case _StatusTone.success:
        return isDark
            ? (const Color(0xFF17392B), const Color(0xFF6DD6A1), AppTheme.vaultOnDark)
            : (const Color(0xFFE7F7EF), const Color(0xFF23875B), AppTheme.vaultInk);
      case _StatusTone.warning:
        return isDark
            ? (const Color(0xFF3A2815), AppTheme.vaultAmber, AppTheme.vaultOnDark)
            : (const Color(0xFFFFF2DD), const Color(0xFFC77A12), AppTheme.vaultInk);
      case _StatusTone.info:
        return isDark
            ? (const Color(0xFF183246), const Color(0xFF76BCEB), AppTheme.vaultOnDark)
            : (const Color(0xFFE8F2FA), const Color(0xFF2B79A8), AppTheme.vaultInk);
      case _StatusTone.neutral:
        return isDark
            ? (AppTheme.vaultSurfaceLight, AppTheme.vaultInkMuted, AppTheme.vaultOnDark)
            : (Colors.white, AppTheme.vaultInkMuted, AppTheme.vaultInk);
    }
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState({required this.onExampleTap});

  final Future<void> Function(String query) onExampleTap;

  @override
  Widget build(BuildContext context) {
    final examples = const [
      't:dragon',
      'o:draw mv<=3',
      'ci:uw t:legendary',
      'set:otj rarity:mythic',
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppTheme.vaultAmber.withOpacity(0.14),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(Icons.auto_awesome_rounded, size: 38, color: AppTheme.vaultAmber),
          ),
          const SizedBox(height: 18),
          Text(
            'Bereit für die Suche',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Nutze einfache Namen oder Scryfall-Filter. Häufige Suchfelder laufen lokal, spezielle Tags wechseln automatisch online.',
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

class _CardResultTile extends StatelessWidget {
  const _CardResultTile({required this.card});

  final ScryfallCardPrint card;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppTheme.vaultSurfaceLight : AppTheme.vaultFog;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor.withOpacity(0.7)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardThumbnail(card: card),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            card.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        if (card.manaCost != null && card.manaCost!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            card.manaCost!,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: AppTheme.vaultAmber,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    if (card.typeLine.isNotEmpty)
                      Text(
                        card.typeLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.68),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    if (card.oracleText.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        card.oracleText,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.25),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (card.setCode.isNotEmpty || card.collectorNumber.isNotEmpty)
                          _MiniTag('${card.setCode.toUpperCase()} #${card.collectorNumber}'),
                        if (card.rarity.isNotEmpty) _MiniTag(card.rarity),
                        if (card.lang.isNotEmpty && card.lang != 'en') _MiniTag(card.lang.toUpperCase()),
                        if (card.eur != null) _MiniTag('${card.eur!.toStringAsFixed(2)} €'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardThumbnail extends StatelessWidget {
  const _CardThumbnail({required this.card});

  final ScryfallCardPrint card;

  @override
  Widget build(BuildContext context) {
    final imageUrl = card.imageSmall ?? card.imageNormal;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placeholderColor = isDark ? AppTheme.vaultSurfaceLight : AppTheme.vaultMist;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 64,
        height: 90,
        color: placeholderColor,
        child: imageUrl == null
            ? const Icon(Icons.style_outlined)
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.style_outlined),
              ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.vaultSurfaceLight : AppTheme.vaultMist,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.72),
            ),
      ),
    );
  }
}
