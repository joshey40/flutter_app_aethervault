import 'dart:collection';
import 'dart:convert';
import 'dart:isolate';

import 'bulk_data_type.dart';
import 'download_service.dart';
import 'scryfall_card_print.dart';
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
    final cacheKey = '${type.apiType}|$normalizedQuery|${maxResults ?? 'all'}|extras:false|sort:${sortMode.name}';
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
    final results = <ScryfallCardPrint>[];

    await for (final cardJson in ScryfallJsonSearchUtils.readTopLevelJsonObjects(path)) {
      final decoded = jsonDecode(cardJson);
      if (decoded is! Map<String, dynamic>) continue;
      if (ScryfallJsonSearchUtils.isExtra(decoded)) continue;
      if (!_matchesQuery(decoded, query)) continue;

      results.add(ScryfallCardPrint.fromJson(decoded));
    }

    _sortCards(results, sortMode);
    if (maxResults != null && results.length > maxResults) {
      return results.take(maxResults).toList(growable: false);
    }
    return results;
  }

  static bool _matchesQuery(Map<String, dynamic> json, ParsedScryfallSearch query) {
    for (final filter in query.filters) {
      final matches = _matchesFilter(json, filter);
      if (filter.negated ? matches : !matches) return false;
    }
    return true;
  }

  static bool _matchesFilter(Map<String, dynamic> json, ScryfallSearchFilter filter) {
    switch (filter.canonicalKeyword) {
      case 'name':
        return _compareText(_jsonText(json, 'name'), filter.normalizedValue, filter.operator);
      case 'type':
        return _compareText(_coalesceFaces(json, 'type_line'), filter.normalizedValue, filter.operator);
      case 'oracle':
        return _compareText(_coalesceFaces(json, 'oracle_text'), filter.normalizedValue, filter.operator);
      case 'artist':
        return _compareText(_jsonText(json, 'artist'), filter.normalizedValue, filter.operator);
      case 'set':
        return _compareText(_jsonText(json, 'set'), filter.normalizedValue, filter.operator);
      case 'rarity':
        return _compareText(_jsonText(json, 'rarity'), filter.normalizedValue, filter.operator);
      case 'lang':
        return _compareText(_jsonText(json, 'lang'), filter.normalizedValue, filter.operator);
      case 'game':
        return ScryfallJsonSearchUtils.stringList(json['games']).map(ScryfallJsonSearchUtils.normalize).contains(filter.normalizedValue);
      case 'colors':
        return _compareColorSet(ScryfallJsonSearchUtils.stringList(json['colors']), filter.normalizedValue, filter.operator);
      case 'identity':
        return _compareColorSet(ScryfallJsonSearchUtils.stringList(json['color_identity']), filter.normalizedValue, filter.operator);
      case 'manaValue':
        return _compareNumber(ScryfallJsonSearchUtils.toDouble(json['cmc']), filter.value, filter.operator);
      case 'usd':
        return _compareNumber(_price(json, 'usd'), filter.value, filter.operator);
      case 'eur':
        return _compareNumber(_price(json, 'eur'), filter.value, filter.operator);
      case 'year':
        return _compareNumber(_releasedYear(json), filter.value, filter.operator);
      case 'is':
        return _matchesIs(json, filter.normalizedValue);
      case 'in':
        return _matchesIn(json, filter.normalizedValue);
      default:
        throw UnsupportedError('Local search does not support "${filter.keyword}" yet.');
    }
  }

  static bool _matchesIs(Map<String, dynamic> json, String value) {
    switch (value) {
      case 'multicolored':
      case 'multicolor':
        return ScryfallJsonSearchUtils.stringList(json['colors']).length > 1;
      case 'monocolored':
      case 'monocolor':
        return ScryfallJsonSearchUtils.stringList(json['colors']).length == 1;
      case 'colorless':
        return ScryfallJsonSearchUtils.stringList(json['colors']).isEmpty;
      case 'paper':
        return ScryfallJsonSearchUtils.stringList(json['games']).contains('paper');
      case 'digital':
        return !ScryfallJsonSearchUtils.stringList(json['games']).contains('paper');
      case 'foil':
        return ScryfallJsonSearchUtils.stringList(json['finishes']).contains('foil');
      case 'nonfoil':
        return ScryfallJsonSearchUtils.stringList(json['finishes']).contains('nonfoil');
      default:
        throw UnsupportedError('Local search does not support is:$value yet.');
    }
  }

  static bool _matchesIn(Map<String, dynamic> json, String value) {
    switch (value) {
      case 'paper':
      case 'arena':
      case 'mtgo':
        return ScryfallJsonSearchUtils.stringList(json['games']).contains(value);
      default:
        throw UnsupportedError('Local search does not support in:$value yet.');
    }
  }

  static String _jsonText(Map<String, dynamic> json, String key) =>
      ScryfallJsonSearchUtils.normalize(json[key] as String? ?? '');

  static String _coalesceFaces(Map<String, dynamic> json, String key) =>
      ScryfallJsonSearchUtils.normalize(ScryfallJsonSearchUtils.coalesceFaces(json, key));

  static double? _price(Map<String, dynamic> json, String key) {
    final prices = json['prices'];
    if (prices is! Map<String, dynamic>) return null;
    return ScryfallJsonSearchUtils.toDouble(prices[key]);
  }

  static double? _releasedYear(Map<String, dynamic> json) {
    final releasedAt = DateTime.tryParse(json['released_at'] as String? ?? '');
    return releasedAt?.year.toDouble();
  }

  static bool _compareText(String normalizedActual, String expected, String operator) {
    switch (operator) {
      case ':':
        return normalizedActual.contains(expected);
      case '=':
        return normalizedActual == expected;
      case '!=':
        return normalizedActual != expected;
      default:
        throw UnsupportedError('Text operator "$operator" is not supported locally.');
    }
  }

  static bool _compareNumber(double? actual, String expected, String operator) {
    if (actual == null) return false;
    final parsed = double.tryParse(expected);
    if (parsed == null) return false;

    switch (operator) {
      case ':':
      case '=':
        return actual == parsed;
      case '!=':
        return actual != parsed;
      case '<':
        return actual < parsed;
      case '<=':
        return actual <= parsed;
      case '>':
        return actual > parsed;
      case '>=':
        return actual >= parsed;
      default:
        return false;
    }
  }

  static bool _compareColorSet(List<String> actualColors, String expected, String operator) {
    final actual = actualColors.map(ScryfallJsonSearchUtils.normalize).toSet();
    final expectedSet = expected.split('').where((char) => 'wubrg'.contains(char)).toSet();

    switch (operator) {
      case ':':
      case '<=':
        return actual.difference(expectedSet).isEmpty;
      case '=':
        return actual.length == expectedSet.length && actual.containsAll(expectedSet);
      case '>=':
        return expectedSet.difference(actual).isEmpty;
      case '!=':
        return !(actual.length == expectedSet.length && actual.containsAll(expectedSet));
      default:
        throw UnsupportedError('Color operator "$operator" is not supported locally.');
    }
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
