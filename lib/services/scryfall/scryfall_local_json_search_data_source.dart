import 'dart:collection';
import 'dart:convert';
import 'dart:isolate';

import 'bulk_data_type.dart';
import 'download_service.dart';
import 'scryfall_card_print.dart';
import 'scryfall_search_evaluator.dart';
import 'scryfall_search_filter.dart';
import 'scryfall_search_json_utils.dart';
import 'scryfall_search_repository.dart';

class ScryfallLocalJsonSearchDataSource implements LocalScryfallSearchDataSource {
  ScryfallLocalJsonSearchDataSource({
    DownloadService? downloadService,
    this.maxResults,
    this.cacheSize = 20,
  }) : _downloadService = downloadService ?? DownloadService.instance;

  final DownloadService _downloadService;
  final int? maxResults;
  final int cacheSize;
  final LinkedHashMap<String, List<ScryfallCardPrint>> _cache = LinkedHashMap();

  @override
  Future<List<ScryfallCardPrint>> searchCards({
    required String rawQuery,
    required ScryfallBulkDataType type,
    ScryfallSearchSortMode sortMode = ScryfallSearchSortMode.nameAsc,
  }) async {
    final normalizedQuery = rawQuery.trim();
    final cacheKey = '${type.apiType}|$normalizedQuery|${maxResults ?? 'all'}|extras:auto|sort:${sortMode.name}';
    final cached = _cache.remove(cacheKey);
    if (cached != null) {
      _cache[cacheKey] = cached;
      return cached;
    }

    final file = await _downloadService.getLocalFile(type: type);
    if (file == null) {
      throw StateError('Scryfall ${type.apiType} file is not available.');
    }

    final result = await Isolate.run(
      () => _searchCardsInFile(
        path: file.path,
        rawQuery: normalizedQuery,
        maxResults: maxResults,
        sortMode: sortMode,
      ),
    );

    _remember(cacheKey, result);
    return result;
  }

  void _remember(String cacheKey, List<ScryfallCardPrint> result) {
    if (cacheSize <= 0) return;
    _cache[cacheKey] = List<ScryfallCardPrint>.unmodifiable(result);
    while (_cache.length > cacheSize) {
      _cache.remove(_cache.keys.first);
    }
  }

  static Future<List<ScryfallCardPrint>> _searchCardsInFile({
    required String path,
    required String rawQuery,
    required int? maxResults,
    required ScryfallSearchSortMode sortMode,
  }) async {
    final query = ParsedScryfallSearch.parse(rawQuery);
    final includeExtras = ScryfallSearchEvaluator.shouldIncludeExtras(query);
    final results = <ScryfallCardPrint>[];

    await for (final cardJson in ScryfallJsonSearchUtils.readTopLevelJsonObjects(path)) {
      final decoded = jsonDecode(cardJson);
      if (decoded is! Map<String, dynamic>) continue;
      if (!includeExtras && ScryfallJsonSearchUtils.isExtra(decoded)) continue;
      if (!ScryfallSearchEvaluator.matchesQuery(decoded, query)) continue;

      results.add(ScryfallCardPrint.fromJson(decoded));
    }

    _sortCards(results, sortMode);
    if (maxResults != null && results.length > maxResults) {
      return results.take(maxResults).toList(growable: false);
    }
    return results;
  }

  static void _sortCards(List<ScryfallCardPrint> cards, ScryfallSearchSortMode sortMode) {
    cards.sort((a, b) {
      switch (sortMode) {
        case ScryfallSearchSortMode.nameAsc:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case ScryfallSearchSortMode.nameDesc:
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        case ScryfallSearchSortMode.manaValueAsc:
          return (a.manaValue ?? 999).compareTo(b.manaValue ?? 999);
        case ScryfallSearchSortMode.newestFirst:
          return (b.releasedAt ?? DateTime(0)).compareTo(a.releasedAt ?? DateTime(0));
        case ScryfallSearchSortMode.oldestFirst:
          return (a.releasedAt ?? DateTime(9999)).compareTo(b.releasedAt ?? DateTime(9999));
        case ScryfallSearchSortMode.setAsc:
          final setCompare = a.setCode.compareTo(b.setCode);
          if (setCompare != 0) return setCompare;
          return a.collectorNumber.compareTo(b.collectorNumber);
      }
    });
  }
}
