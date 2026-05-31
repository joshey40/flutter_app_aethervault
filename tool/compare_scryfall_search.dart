import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as http_io;

/// Diagnostic tool for comparing the app's local Scryfall-style search subset
/// against the real Scryfall API.
///
/// Examples:
///   dart run tool/compare_scryfall_search.dart --query "arcane signet"
///   dart run tool/compare_scryfall_search.dart --query "t:dragon" --limit 0
///   dart run tool/compare_scryfall_search.dart --query "lang:de name:sol ring" --bulk all_cards --unique prints --limit 0
///
/// By default, this script stores downloaded bulk JSON files in
/// `.dart_tool/scryfall_compare/` and reuses them across runs.
Future<void> main(List<String> args) async {
  late final _Options options;
  try {
    options = _Options.parse(args);
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    stderr.writeln(_usage);
    exitCode = 64;
    return;
  }

  if (options.showHelp) {
    stdout.writeln(_usage);
    return;
  }

  if (options.queries.isEmpty) {
    stderr.writeln('No queries provided. Use --query or --queries.');
    stderr.writeln(_usage);
    exitCode = 64;
    return;
  }

  final apiClient = http.Client();
  final downloadClient = http_io.IOClient(HttpClient()..autoUncompress = false);
  try {
    final bulkFile = options.localFile ??
        await _ensureBulkFile(
          client: apiClient,
          downloadClient: downloadClient,
          type: options.bulkType,
          forceRefresh: options.refreshBulk,
        );

    stdout.writeln('Local bulk: ${bulkFile.path}');
    stdout.writeln('Bulk type: ${options.bulkType.apiType}');
    stdout.writeln('Scryfall unique: ${options.unique}');
    stdout.writeln('Include extras: false');
    stdout.writeln('Limit: ${options.limit == 0 ? 'all' : options.limit}');
    stdout.writeln('');

    for (final query in options.queries) {
      await _compareQuery(
        client: apiClient,
        localFile: bulkFile,
        query: query,
        unique: options.unique,
        limit: options.limit,
        show: options.show,
      );
    }
  } finally {
    apiClient.close();
    downloadClient.close();
  }
}

Future<void> _compareQuery({
  required http.Client client,
  required File localFile,
  required String query,
  required String unique,
  required int limit,
  required int show,
}) async {
  stdout.writeln('='.padRight(80, '='));
  stdout.writeln('Query: $query');

  final local = await _searchLocalBulk(file: localFile, rawQuery: query, limit: limit);
  final remote = await _searchScryfall(
    client: client,
    rawQuery: query,
    unique: unique,
    limit: limit,
  );

  final localIds = local.map((card) => card.compareKey(unique)).toSet();
  final remoteIds = remote.map((card) => card.compareKey(unique)).toSet();
  final missingIds = remoteIds.difference(localIds);
  final extraIds = localIds.difference(remoteIds);
  final remoteById = {for (final card in remote) card.compareKey(unique): card};
  final localById = {for (final card in local) card.compareKey(unique): card};

  stdout.writeln('Local:  ${local.length}');
  stdout.writeln('Remote: ${remote.length}');
  stdout.writeln('Missing locally: ${missingIds.length}');
  stdout.writeln('Extra locally:   ${extraIds.length}');

  if (missingIds.isNotEmpty) {
    stdout.writeln('');
    stdout.writeln('Missing locally:');
    for (final id in missingIds.take(show)) {
      stdout.writeln('  - ${remoteById[id]}');
    }
    if (missingIds.length > show) stdout.writeln('  ... ${missingIds.length - show} more');
  }

  if (extraIds.isNotEmpty) {
    stdout.writeln('');
    stdout.writeln('Extra locally:');
    for (final id in extraIds.take(show)) {
      stdout.writeln('  + ${localById[id]}');
    }
    if (extraIds.length > show) stdout.writeln('  ... ${extraIds.length - show} more');
  }

  stdout.writeln('');
}

Future<List<_CompareCard>> _searchScryfall({
  required http.Client client,
  required String rawQuery,
  required String unique,
  required int limit,
}) async {
  final cards = <_CompareCard>[];
  Uri? nextPage = Uri.https('api.scryfall.com', '/cards/search', <String, String>{
    'q': rawQuery,
    'unique': unique,
    'include_extras': 'false',
  });

  while (nextPage != null && _underLimit(cards.length, limit)) {
    final response = await client.get(
      nextPage,
      headers: const <String, String>{
        'User-Agent': 'AetherVaultSearchCompare/0.1 (https://github.com/joshey40)',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 404) return const <_CompareCard>[];
    if (response.statusCode != 200) {
      throw HttpException(
        'Scryfall search failed with HTTP ${response.statusCode}: ${response.body}',
        uri: nextPage,
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'];
    if (data is List) {
      for (final item in data.whereType<Map<String, dynamic>>()) {
        cards.add(_CompareCard.fromJson(item));
        if (!_underLimit(cards.length, limit)) break;
      }
    }

    final hasMore = body['has_more'] == true;
    final nextPageValue = body['next_page'] as String?;
    nextPage = hasMore && nextPageValue != null ? Uri.parse(nextPageValue) : null;
  }

  return cards;
}

Future<List<_CompareCard>> _searchLocalBulk({
  required File file,
  required String rawQuery,
  required int limit,
}) async {
  final query = _LocalQuery.parse(rawQuery);
  final cards = <_CompareCard>[];

  await for (final cardJson in _readTopLevelJsonObjects(file)) {
    final decoded = jsonDecode(cardJson);
    if (decoded is! Map<String, dynamic>) continue;
    if (_isExtra(decoded)) continue;
    if (!query.matchesJson(decoded)) continue;

    cards.add(_CompareCard.fromJson(decoded));
    if (!_underLimit(cards.length, limit)) break;
  }

  return cards;
}

bool _isExtra(Map<String, dynamic> json) {
  if (json['digital'] == true) return true;

  final layout = json['layout'] as String? ?? '';
  if (_extraLayouts.contains(layout)) return true;

  final typeLine = _coalesceFaces(json, 'type_line');
  if (typeLine.contains('token') || typeLine.contains('emblem')) return true;

  final setType = json['set_type'] as String? ?? '';
  return _extraSetTypes.contains(setType);
}

const Set<String> _extraLayouts = <String>{
  'token',
  'emblem',
  'art_series',
  'planar',
  'scheme',
  'vanguard',
};

const Set<String> _extraSetTypes = <String>{
  'token',
  'funny',
  'memorabilia',
  'minigame',
};

bool _underLimit(int count, int limit) => limit == 0 || count < limit;

Future<File> _ensureBulkFile({
  required http.Client client,
  required http.Client downloadClient,
  required _BulkType type,
  required bool forceRefresh,
}) async {
  final dir = Directory('.dart_tool/scryfall_compare');
  if (!await dir.exists()) await dir.create(recursive: true);
  final file = File('${dir.path}/${type.fileName}');
  if (await file.exists() && !forceRefresh) return file;

  stdout.writeln('Downloading ${type.apiType} metadata...');
  final metadataResponse = await client.get(
    Uri.parse('https://api.scryfall.com/bulk-data'),
    headers: const <String, String>{
      'User-Agent': 'AetherVaultSearchCompare/0.1 (https://github.com/joshey40)',
      'Accept': 'application/json',
    },
  );
  if (metadataResponse.statusCode != 200) {
    throw HttpException('Failed to fetch bulk metadata: ${metadataResponse.statusCode}');
  }

  final metadata = jsonDecode(metadataResponse.body) as Map<String, dynamic>;
  final data = metadata['data'];
  if (data is! List) throw const FormatException('Bulk metadata data field is not a list.');
  final entry = data.whereType<Map<String, dynamic>>().firstWhere((item) => item['type'] == type.apiType);
  final downloadUri = Uri.parse(entry['download_uri'] as String);
  final contentEncoding = (entry['content_encoding'] as String?)?.toLowerCase();

  stdout.writeln('Downloading ${type.apiType} bulk file...');
  final request = http.Request('GET', downloadUri)
    ..headers.addAll(const <String, String>{
      'User-Agent': 'AetherVaultSearchCompare/0.1 (https://github.com/joshey40)',
      'Accept': 'application/json',
    });
  final streamed = await downloadClient.send(request);
  if (streamed.statusCode != 200) {
    throw HttpException('Failed to download bulk file: ${streamed.statusCode}', uri: downloadUri);
  }

  Stream<List<int>> stream = streamed.stream;
  final responseEncoding = streamed.headers['content-encoding']?.toLowerCase();
  if (responseEncoding == 'gzip' || contentEncoding == 'gzip') {
    stream = stream.transform(gzip.decoder);
  }

  final temp = File('${file.path}.tmp');
  final sink = temp.openWrite();
  var received = 0;
  await for (final chunk in stream) {
    sink.add(chunk);
    received += chunk.length;
    if (received % (10 * 1024 * 1024) < chunk.length) {
      stdout.writeln('  ${(received / (1024 * 1024)).toStringAsFixed(1)} MiB');
    }
  }
  await sink.close();

  if (await file.exists()) await file.delete();
  return temp.rename(file.path);
}

Stream<String> _readTopLevelJsonObjects(File file) async* {
  final header = await file.openRead(0, 2).fold<List<int>>(
    <int>[],
    (previous, chunk) => previous..addAll(chunk),
  );

  Stream<List<int>> bytes = file.openRead();
  if (_looksLikeGzip(header)) bytes = bytes.transform(gzip.decoder);

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

bool _looksLikeGzip(List<int> bytes) => bytes.length >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b;

class _LocalQuery {
  const _LocalQuery(this.predicates);
  final List<bool Function(Map<String, dynamic> cardJson)> predicates;
  bool matchesJson(Map<String, dynamic> cardJson) => predicates.every((predicate) => predicate(cardJson));

  static _LocalQuery parse(String rawQuery) {
    final predicates = <bool Function(Map<String, dynamic> cardJson)>[];
    for (final token in _tokenize(rawQuery)) {
      final negated = token.startsWith('-');
      final cleanToken = negated ? token.substring(1) : token;
      final predicate = _parseToken(cleanToken);
      predicates.add(negated ? (json) => !predicate(json) : predicate);
    }
    return _LocalQuery(predicates);
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
}

String _jsonText(Map<String, dynamic> json, String key) => _normalize(json[key] as String? ?? '');

String _coalesceFaces(Map<String, dynamic> json, String key) {
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

List<String> _jsonStringList(Object? value) {
  if (value is! List) return const <String>[];
  return value.whereType<String>().toList(growable: false);
}

double? _price(Map<String, dynamic> json, String key) {
  final prices = json['prices'];
  if (prices is! Map<String, dynamic>) return null;
  return _toDouble(prices[key]);
}

double? _releasedYear(Map<String, dynamic> json) {
  final releasedAt = DateTime.tryParse(json['released_at'] as String? ?? '');
  return releasedAt?.year.toDouble();
}

double? _toDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String && value.isNotEmpty) return double.tryParse(value);
  return null;
}

bool _compareText(String normalizedActual, String expected, String operator) {
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

bool _compareNumber(double? actual, String expected, String operator) {
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

bool _compareColorSet(List<String> actualColors, String expected, String operator) {
  final actual = actualColors.map(_normalize).toSet();
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

String _normalize(String value) => value.toLowerCase().trim();

class _CompareCard {
  const _CompareCard({
    required this.id,
    required this.oracleId,
    required this.name,
    required this.set,
    required this.collectorNumber,
  });

  final String id;
  final String? oracleId;
  final String name;
  final String set;
  final String collectorNumber;

  String compareKey(String unique) => unique == 'prints' ? id : (oracleId ?? id);

  factory _CompareCard.fromJson(Map<String, dynamic> json) {
    return _CompareCard(
      id: json['id'] as String? ?? '',
      oracleId: json['oracle_id'] as String?,
      name: json['name'] as String? ?? '',
      set: json['set'] as String? ?? '',
      collectorNumber: json['collector_number'] as String? ?? '',
    );
  }

  @override
  String toString() => '$name [$set #$collectorNumber] (${oracleId ?? id})';
}

enum _BulkType {
  oracleCards('oracle_cards', 'scryfall_oracle_cards.json'),
  defaultCards('default_cards', 'scryfall_default_cards.json'),
  allCards('all_cards', 'scryfall_all_cards.json');

  const _BulkType(this.apiType, this.fileName);
  final String apiType;
  final String fileName;

  static _BulkType parse(String value) {
    switch (value) {
      case 'oracle_cards':
      case 'oracle':
        return oracleCards;
      case 'default_cards':
      case 'default':
        return defaultCards;
      case 'all_cards':
      case 'all':
        return allCards;
      default:
        throw FormatException('Unknown bulk type "$value".');
    }
  }
}

class _Options {
  const _Options({
    required this.queries,
    required this.bulkType,
    required this.unique,
    required this.limit,
    required this.show,
    required this.refreshBulk,
    required this.showHelp,
    this.localFile,
  });

  final List<String> queries;
  final _BulkType bulkType;
  final String unique;
  final int limit;
  final int show;
  final bool refreshBulk;
  final bool showHelp;
  final File? localFile;

  static _Options parse(List<String> args) {
    final queries = <String>[];
    var bulkType = _BulkType.oracleCards;
    var unique = 'cards';
    var limit = 175;
    var show = 10;
    var refreshBulk = false;
    var showHelp = false;
    File? localFile;

    for (var i = 0; i < args.length; i++) {
      final arg = args[i];
      String readValue() {
        if (i + 1 >= args.length) throw FormatException('Missing value for $arg');
        return args[++i];
      }

      switch (arg) {
        case '-h':
        case '--help':
          showHelp = true;
          break;
        case '-q':
        case '--query':
          queries.add(readValue());
          break;
        case '--queries':
          final file = File(readValue());
          queries.addAll(
            file
                .readAsLinesSync()
                .map((line) => line.trim())
                .where((line) => line.isNotEmpty && !line.startsWith('#')),
          );
          break;
        case '--bulk':
          bulkType = _BulkType.parse(readValue());
          break;
        case '--local-file':
          localFile = File(readValue());
          break;
        case '--unique':
          unique = readValue();
          if (unique != 'cards' && unique != 'prints') {
            throw const FormatException('--unique must be cards or prints.');
          }
          break;
        case '--limit':
          limit = int.parse(readValue());
          if (limit < 0) throw const FormatException('--limit must be >= 0. Use 0 for all results.');
          break;
        case '--show':
          show = int.parse(readValue());
          break;
        case '--refresh-bulk':
          refreshBulk = true;
          break;
        default:
          throw FormatException('Unknown argument $arg');
      }
    }

    return _Options(
      queries: queries,
      bulkType: bulkType,
      unique: unique,
      limit: limit,
      show: show,
      refreshBulk: refreshBulk,
      showHelp: showHelp,
      localFile: localFile,
    );
  }
}

const _usage = '''
Compare local AetherVault-style Scryfall search against the Scryfall API.

Usage:
  dart run tool/compare_scryfall_search.dart --query "arcane signet"
  dart run tool/compare_scryfall_search.dart --query "t:dragon" --limit 0
  dart run tool/compare_scryfall_search.dart --query "lang:de name:sol ring" --bulk all_cards --unique prints --limit 0
  dart run tool/compare_scryfall_search.dart --queries tool/search_queries.txt --show 20

Options:
  -q, --query <query>       Add one query to compare. Can be repeated.
      --queries <file>      Read one query per line. Lines starting with # are ignored.
      --bulk <type>         oracle_cards, default_cards, or all_cards. Default: oracle_cards.
      --local-file <path>   Use an existing local bulk JSON file instead of .dart_tool cache.
      --unique <mode>       Scryfall API unique mode: cards or prints. Default: cards.
      --limit <n>           Max local/API results to compare. Use 0 for all results. Default: 175.
      --show <n>            Max missing/extra rows to print. Default: 10.
      --refresh-bulk        Redownload the selected bulk file.
  -h, --help                Show this help.
''';
