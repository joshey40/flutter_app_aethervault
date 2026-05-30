import 'package:flutter/material.dart';

import '../../../services/localization_service.dart';
import '../../../services/scryfall/download_service.dart';
import '../../../services/scryfall/scryfall_card_print.dart';
import '../../../services/scryfall/scryfall_local_json_search_data_source.dart';
import '../../../services/scryfall/scryfall_remote_search_data_source.dart';
import '../../../services/scryfall/scryfall_search_query.dart';
import '../../../services/scryfall/scryfall_search_repository.dart';

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: loc.translate('search.placeholder'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 112,
                  child: ElevatedButton(
                    onPressed: _isSearching ? null : _performSearch,
                    child: _isSearching
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Suchen'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAvailabilityCard(),
            if (_lastResultSource != null || _lastFallbackReason != null) ...[
              const SizedBox(height: 8),
              _buildResultSourceInfo(),
            ],
            if (_searchError != null) ...[
              const SizedBox(height: 8),
              _buildErrorCard(_searchError!),
            ],
            const SizedBox(height: 12),
            Expanded(child: _buildResultsArea()),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityCard() {
    final ready = _defaultCardsAvailable && _allCardsAvailable;
    return Card(
      child: ListTile(
        leading: _checkingAvailability
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                ready ? Icons.check_circle : Icons.error_outline,
                color: ready ? Colors.green : Colors.orange,
              ),
        title: Text(
          _checkingAvailability
              ? 'Prüfe Scryfall-Daten...'
              : ready
                  ? 'Scryfall-Daten vorhanden'
                  : 'Scryfall-Daten unvollständig',
        ),
        subtitle: Text(
          'Suche: ${_defaultCardsAvailable ? 'default_cards bereit' : 'default_cards fehlt'} · '
          'Collection: ${_allCardsAvailable ? 'all_cards bereit' : 'all_cards fehlt'}',
        ),
        trailing: TextButton.icon(
          onPressed: _checkingAvailability ? null : _checkScryfallAvailability,
          icon: const Icon(Icons.refresh),
          label: const Text('Aktualisieren'),
        ),
      ),
    );
  }

  Widget _buildResultSourceInfo() {
    final sourceText = switch (_lastResultSource) {
      ScryfallSearchResultSource.localDefaultCards => 'Lokale Suche über default_cards',
      ScryfallSearchResultSource.remoteScryfallApi => 'Online-Fallback über Scryfall API',
      null => null,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                [sourceText, _lastFallbackReason]
                    .whereType<String>()
                    .where((text) => text.isNotEmpty)
                    .join('\n'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsArea() {
    if (_isSearching && _results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_results.isEmpty) {
      return const Center(
        child: Text('Gib eine Scryfall-Suche ein, z. B. t:dragon, o:draw oder ci:uw mv<=3.'),
      );
    }

    return ListView.separated(
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _CardResultTile(card: _results[index]),
    );
  }
}

class _CardResultTile extends StatelessWidget {
  const _CardResultTile({required this.card});

  final ScryfallCardPrint card;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: _buildLeadingImage(),
        title: Text(card.name),
        subtitle: Text(
          [
            if (card.manaCost != null && card.manaCost!.isNotEmpty) card.manaCost!,
            if (card.typeLine.isNotEmpty) card.typeLine,
            if (card.setCode.isNotEmpty || card.collectorNumber.isNotEmpty)
              '${card.setCode.toUpperCase()} #${card.collectorNumber}',
          ].join('\n'),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildLeadingImage() {
    final imageUrl = card.imageSmall ?? card.imageNormal;
    if (imageUrl == null) {
      return const SizedBox(
        width: 48,
        height: 64,
        child: Icon(Icons.style_outlined),
      );
    }

    return SizedBox(
      width: 48,
      height: 64,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.style_outlined),
      ),
    );
  }
}
