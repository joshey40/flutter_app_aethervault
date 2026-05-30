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
  List<ScryfallCardPrint>? _cache;

  @override
  Future<List<ScryfallCardPrint>> searchDefaultCards(String rawQuery) async {
    final cards = await _loadCards();
    final query = _LocalScryfallQuery.parse(rawQuery);

    return cards
        .where(query.matches)
        .take(maxResults)
        .toList(growable: false);
  }

  Future<List<ScryfallCardPrint>> _loadCards() async {
    final cached = _cache;
    if (cached != null) return cached;

    final file = await _downloadService.getLocalFile(
      type: ScryfallBulkDataType.defaultCards,
    );
    if (file == null) {
      throw StateError('Scryfall default_cards file is not available.');
    }

    final cards = await Isolate.run(() => _readCardsFromFile(file.path));
    _cache = cards;
    return cards;
  }

  static List<ScryfallCardPrint> _readCardsFromFile(String path) {
    final bytes = File(path).readAsBytesSync();
    final content = _decodeJsonBytes(bytes);
    final decoded = jsonDecode(content);
    if (decoded is! List) {
      throw const FormatException('Scryfall default_cards JSON is expected to be a list.');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(ScryfallCardPrint.fromJson)
        .toList(growable: false);
  }

  static String _decodeJsonBytes(List<int> bytes) {
    try {
      return utf8.decode(bytes);
    } on FormatException {
      if (_looksLikeGzip(bytes)) {
        return utf8.decode(gzip.decode(bytes));
      }
      rethrow;
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
