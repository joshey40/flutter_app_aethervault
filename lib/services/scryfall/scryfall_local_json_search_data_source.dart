import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'bulk_data_type.dart';
import 'download_service.dart';
import 'scryfall_card_print.dart';
import 'scryfall_search_repository.dart';

class ScryfallLocalJsonSearchDataSource implements LocalScryfallSearchDataSource {
  ScryfallLocalJsonSearchDataSource({
    DownloadService? downloadService,
    this.maxResults = 120,
    this.cacheSize = 20,
  }) : _downloadService = downloadService ?? DownloadService.instance;

  final DownloadService _downloadService;
  final int maxResults;
  final int cacheSize;
  final LinkedHashMap<String, List<ScryfallCardPrint>> _cache = LinkedHashMap();

  @override
  Future<List<ScryfallCardPrint>> searchCards({
    required String rawQuery,
    required ScryfallBulkDataType type,
  }) async {
    final normalizedQuery = rawQuery.trim();
    final cacheKey = '${type.apiType}|$normalizedQuery|$maxResults';
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
    required int maxResults,
  }) async {
    final query = _LocalScryfallQuery.parse(rawQuery);
    final results = <ScryfallCardPrint>[];

    await for (final cardJson in _readTopLevelJsonObjects(path)) {
      final decoded = jsonDecode(cardJson);
      if (decoded is! Map<String, dynamic>) continue;

      if (!query.matchesJson(decoded)) continue;

      results.add(ScryfallCardPrint.fromJson(decoded));
      if (results.length >= maxResults) break;
    }

    return results;
  }

  static Stream<String> _readTopLevelJsonObjects(String path) async* {
    final file = File(path);
    final header = await file.openRead(0, 2).fold<List<int>>(
      <int>[],
      (previous, chunk) => previous..addAll(chunk),
    );

    Stream<List<int>> bytes = file.openRead();
    if (_looksLikeGzip(header)) {
      bytes = bytes.transform(gzip.decoder);
    }

    final chars = bytes.transform(utf8.decoder);
    final buffer = StringBuffer();
    var depth = 0;
    var inString = false;
    var escaping = false;
    var capturing = false;

    await for (final chunk in chars) {
      for (var i = 0; i < chunk.length; i++) {
        final char = chunk[i];

        if (capturing) buffer.write(char);

        if (inString) {
          if (escaping) {
            escaping = false;
          } else if (char == r'\') {
            escaping = true;
          } else if (char == '"') {
            inString = false;
          }
          continue;
        }

        if (char == '"') {
          inString = true;
          continue;
        }

        if (char == '{') {
          if (!capturing) {
            capturing = true;
            buffer.clear();
            buffer.write(char);
          }
          depth++;
          continue;
        }

        if (char == '}') {
          depth--;
          if (capturing && depth == 0) {
            yield buffer.toString();
            buffer.clear();
            capturing = false;
          }
        }
      }
    }
  }

  static bool _looksLikeGzip(List<int> bytes) =>
      bytes.length >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b;
}

class _LocalScryfallQuery {
  const _LocalScryfallQuery(this.predicates);

  final List<bool Function(Map<String, dynamic> cardJson)> predicates;

  bool matchesJson(Map<String, dynamic> cardJson) => predicates.every((predicate) => predicate(cardJson));

  static _LocalScryfallQuery parse(String rawQuery) {
    final tokens = _tokenize(rawQuery);
    final predicates = <bool Function(Map<String, dynamic> cardJson)>[];

    for (final token in tokens) {
      final negated = token.startsWith('-');
      final cleanToken = negated ? token.substring(1) : token;
      final predicate = _parseToken(cleanToken);
      predicates.add(negated ? (json) => !predicate(json) : predicate);
    }

    if (predicates.isEmpty) {
      return const _LocalScryfallQuery(<bool Function(Map<String, dynamic>)>[]);
    }

    return _LocalScryfallQuery(predicates);
  }

  static List<String> _tokenize(String rawQuery) {
    final tokens = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < rawQuery.length; i++) {
      final char = rawQuery[i];
      if (char == '"') {
        inQuotes = !inQuotes;
        continue;
      }
      if (!inQuotes && char.trim().isEmpty) {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }
        continue;
      }
      buffer.write(char);
    }

    if (buffer.isNotEmpty) tokens.add(buffer.toString());
    return tokens;
  }

  static bool Function(Map<String, dynamic> cardJson) _parseToken(String token) {
    final comparison = RegExp(r'^([a-zA-Z][a-zA-Z0-9_]*)(<=|>=|!=|=|<|>|:)(.+)$').firstMatch(token);
    if (comparison == null) {
      final value = _normalize(token);
      return (json) => _jsonText(json, 'name').contains(value);
    }

    final keyword = comparison.group(1)!.toLowerCase();
    final operator = comparison.group(2)!;
    final value = comparison.group(3)!.trim();
    final normalizedValue = _normalize(value);

    switch (keyword) {
      case 'name':
      case 'n':
        return (json) => _compareText(_jsonText(json, 'name'), normalizedValue, operator);
      case 'type':
      case 't':
        return (json) => _compareText(_coalesceFaces(json, 'type_line'), normalizedValue, operator);
      case 'oracle':
      case 'o':
        return (json) => _compareText(_coalesceFaces(json, 'oracle_text'), normalizedValue, operator);
      case 'artist':
      case 'a':
        return (json) => _compareText(_jsonText(json, 'artist'), normalizedValue, operator);
      case 'set':
      case 's':
      case 'e':
      case 'edition':
        return (json) => _compareText(_jsonText(json, 'set'), normalizedValue, operator);
      case 'rarity':
      case 'r':
        return (json) => _compareText(_jsonText(json, 'rarity'), normalizedValue, operator);
      case 'lang':
      case 'language':
        return (json) => _compareText(_jsonText(json, 'lang'), normalizedValue, operator);
      case 'game':
        return (json) => _jsonStringList(json['games']).map(_normalize).contains(normalizedValue);
      case 'c':
      case 'color':
      case 'colors':
        return (json) => _compareColorSet(_jsonStringList(json['colors']), normalizedValue, operator);
      case 'ci':
      case 'id':
      case 'identity':
      case 'commander':
      case 'edh':
        return (json) => _compareColorSet(_jsonStringList(json['color_identity']), normalizedValue, operator);
      case 'mv':
      case 'cmc':
        return (json) => _compareNumber(_toDouble(json['cmc']), value, operator);
      case 'usd':
        return (json) => _compareNumber(_price(json, 'usd'), value, operator);
      case 'eur':
        return (json) => _compareNumber(_price(json, 'eur'), value, operator);
      case 'year':
        return (json) => _compareNumber(_releasedYear(json), value, operator);
      case 'is':
        return _parseIsPredicate(normalizedValue);
      case 'in':
        return _parseInPredicate(normalizedValue);
      default:
        throw UnsupportedError('Local search does not support "$keyword" yet.');
    }
  }

  static bool Function(Map<String, dynamic> cardJson) _parseIsPredicate(String value) {
    switch (value) {
      case 'multicolored':
      case 'multicolor':
        return (json) => _jsonStringList(json['colors']).length > 1;
      case 'monocolored':
      case 'monocolor':
        return (json) => _jsonStringList(json['colors']).length == 1;
      case 'colorless':
        return (json) => _jsonStringList(json['colors']).isEmpty;
      case 'paper':
        return (json) => _jsonStringList(json['games']).contains('paper');
      case 'digital':
        return (json) => !_jsonStringList(json['games']).contains('paper');
      case 'foil':
        return (json) => _jsonStringList(json['finishes']).contains('foil');
      case 'nonfoil':
        return (json) => _jsonStringList(json['finishes']).contains('nonfoil');
      default:
        throw UnsupportedError('Local search does not support is:$value yet.');
    }
  }

  static bool Function(Map<String, dynamic> cardJson) _parseInPredicate(String value) {
    switch (value) {
      case 'paper':
        return (json) => _jsonStringList(json['games']).contains('paper');
      case 'arena':
        return (json) => _jsonStringList(json['games']).contains('arena');
      case 'mtgo':
        return (json) => _jsonStringList(json['games']).contains('mtgo');
      default:
        throw UnsupportedError('Local search does not support in:$value yet.');
    }
  }

  static String _jsonText(Map<String, dynamic> json, String key) => _normalize(json[key] as String? ?? '');

  static String _coalesceFaces(Map<String, dynamic> json, String key) {
    final direct = json[key] as String?;
    if (direct != null && direct.isNotEmpty) return _normalize(direct);

    final faces = json['card_faces'];
    if (faces is! List) return '';

    return faces
        .whereType<Map<String, dynamic>>()
        .map((face) => face[key] as String? ?? '')
        .where((value) => value.isNotEmpty)
        .map(_normalize)
        .join('\n---\n');
  }

  static List<String> _jsonStringList(Object? value) {
    if (value is! List) return const <String>[];
    return value.whereType<String>().toList(growable: false);
  }

  static double? _price(Map<String, dynamic> json, String key) {
    final prices = json['prices'];
    if (prices is! Map<String, dynamic>) return null;
    return _toDouble(prices[key]);
  }

  static double? _releasedYear(Map<String, dynamic> json) {
    final releasedAt = DateTime.tryParse(json['released_at'] as String? ?? '');
    return releasedAt?.year.toDouble();
  }

  static double? _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String && value.isNotEmpty) return double.tryParse(value);
    return null;
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
    final actual = actualColors.map(_normalize).toSet();
    final expectedSet = expected
        .split('')
        .where((char) => 'wubrg'.contains(char))
        .toSet();

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

  static String _normalize(String value) => value.toLowerCase().trim();
}
