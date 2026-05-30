import 'dart:async';
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
  }) : _downloadService = downloadService ?? DownloadService.instance;

  final DownloadService _downloadService;
  final int maxResults;

  @override
  Future<List<ScryfallCardPrint>> searchCards({
    required String rawQuery,
    required ScryfallBulkDataType type,
  }) async {
    final file = await _downloadService.getLocalFile(type: type);
    if (file == null) {
      throw StateError('Scryfall ${type.apiType} file is not available.');
    }

    return Isolate.run(
      () => _searchCardsInFile(
        path: file.path,
        rawQuery: rawQuery,
        maxResults: maxResults,
      ),
    );
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

      final card = ScryfallCardPrint.fromJson(decoded);
      if (query.matches(card)) {
        results.add(card);
        if (results.length >= maxResults) break;
      }
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

  final List<bool Function(ScryfallCardPrint card)> predicates;

  bool matches(ScryfallCardPrint card) => predicates.every((predicate) => predicate(card));

  static _LocalScryfallQuery parse(String rawQuery) {
    final tokens = _tokenize(rawQuery);
    final predicates = <bool Function(ScryfallCardPrint card)>[];

    for (final token in tokens) {
      final negated = token.startsWith('-');
      final cleanToken = negated ? token.substring(1) : token;
      final predicate = _parseToken(cleanToken);
      predicates.add(negated ? (card) => !predicate(card) : predicate);
    }

    if (predicates.isEmpty) {
      return const _LocalScryfallQuery(<bool Function(ScryfallCardPrint)>[]);
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

  static bool Function(ScryfallCardPrint card) _parseToken(String token) {
    final comparison = RegExp(r'^([a-zA-Z][a-zA-Z0-9_]*)(<=|>=|!=|=|<|>|:)(.+)$').firstMatch(token);
    if (comparison == null) {
      final value = _normalize(token);
      return (card) => _normalize(card.name).contains(value);
    }

    final keyword = comparison.group(1)!.toLowerCase();
    final operator = comparison.group(2)!;
    final value = comparison.group(3)!.trim();
    final normalizedValue = _normalize(value);

    switch (keyword) {
      case 'name':
      case 'n':
        return (card) => _compareText(card.name, normalizedValue, operator);
      case 'type':
      case 't':
        return (card) => _compareText(card.typeLine, normalizedValue, operator);
      case 'oracle':
      case 'o':
        return (card) => _compareText(card.oracleText, normalizedValue, operator);
      case 'artist':
      case 'a':
        return (card) => _compareText(card.artist ?? '', normalizedValue, operator);
      case 'set':
      case 's':
      case 'e':
      case 'edition':
        return (card) => _compareText(card.setCode, normalizedValue, operator);
      case 'rarity':
      case 'r':
        return (card) => _compareText(card.rarity, normalizedValue, operator);
      case 'lang':
      case 'language':
        return (card) => _compareText(card.lang, normalizedValue, operator);
      case 'game':
        return (card) => card.games.map(_normalize).contains(normalizedValue);
      case 'c':
      case 'color':
      case 'colors':
        return (card) => _compareColorSet(card.colors, normalizedValue, operator);
      case 'ci':
      case 'id':
      case 'identity':
      case 'commander':
      case 'edh':
        return (card) => _compareColorSet(card.colorIdentity, normalizedValue, operator);
      case 'mv':
      case 'cmc':
        return (card) => _compareNumber(card.manaValue, value, operator);
      case 'usd':
        return (card) => _compareNumber(card.usd, value, operator);
      case 'eur':
        return (card) => _compareNumber(card.eur, value, operator);
      case 'year':
        return (card) => _compareNumber(card.releasedAt?.year.toDouble(), value, operator);
      case 'is':
        return _parseIsPredicate(normalizedValue);
      case 'in':
        return _parseInPredicate(normalizedValue);
      default:
        throw UnsupportedError('Local search does not support "$keyword" yet.');
    }
  }

  static bool Function(ScryfallCardPrint card) _parseIsPredicate(String value) {
    switch (value) {
      case 'multicolored':
      case 'multicolor':
        return (card) => card.colors.length > 1;
      case 'monocolored':
      case 'monocolor':
        return (card) => card.colors.length == 1;
      case 'colorless':
        return (card) => card.colors.isEmpty;
      case 'paper':
        return (card) => card.games.contains('paper');
      case 'digital':
        return (card) => !card.games.contains('paper');
      case 'foil':
        return (card) => card.finishes.contains('foil');
      case 'nonfoil':
        return (card) => card.finishes.contains('nonfoil');
      default:
        throw UnsupportedError('Local search does not support is:$value yet.');
    }
  }

  static bool Function(ScryfallCardPrint card) _parseInPredicate(String value) {
    switch (value) {
      case 'paper':
        return (card) => card.games.contains('paper');
      case 'arena':
        return (card) => card.games.contains('arena');
      case 'mtgo':
        return (card) => card.games.contains('mtgo');
      default:
        throw UnsupportedError('Local search does not support in:$value yet.');
    }
  }

  static bool _compareText(String actual, String expected, String operator) {
    final normalizedActual = _normalize(actual);
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
