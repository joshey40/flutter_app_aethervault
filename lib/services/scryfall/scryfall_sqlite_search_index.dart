import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import 'bulk_data_type.dart';
import 'scryfall_card_print.dart';
import 'scryfall_search_filter.dart';
import 'scryfall_search_json_utils.dart';
import 'scryfall_search_repository.dart';

class ScryfallSqliteSearchIndex {
  ScryfallSqliteSearchIndex._();
  static final ScryfallSqliteSearchIndex instance = ScryfallSqliteSearchIndex._();

  static const int schemaVersion = 2;
  static const int indexVersion = 2;
  static const int busyTimeoutMs = 5000;

  File? _testDatabaseFile;

  void setTestDatabaseFile(File file) {
    _testDatabaseFile = file;
  }

  Future<bool> isIndexReady({
    required ScryfallBulkDataType type,
    required File sourceFile,
  }) async {
    final databaseFile = await _databaseFile();
    if (!await databaseFile.exists()) return false;

    final stat = await sourceFile.stat();
    final db = sqlite3.open(databaseFile.path, mode: OpenMode.readOnly);
    try {
      _setBusyTimeout(db);
      final row = db.select(
        'SELECT source_size, source_modified_ms, index_version FROM index_metadata WHERE bulk_type = ?',
        <Object?>[type.apiType],
      );
      if (row.isEmpty) return false;

      return row.first['source_size'] == stat.size &&
          row.first['source_modified_ms'] == stat.modified.millisecondsSinceEpoch &&
          row.first['index_version'] == indexVersion;
    } on SqliteException {
      return false;
    } finally {
      db.dispose();
    }
  }

  Future<void> ensureIndex({
    required ScryfallBulkDataType type,
    required File sourceFile,
  }) async {
    if (await isIndexReady(type: type, sourceFile: sourceFile)) return;

    final databaseFile = await _databaseFile();
    if (!await databaseFile.parent.exists()) {
      await databaseFile.parent.create(recursive: true);
    }

    await Isolate.run(
      () => _buildIndex(
        databasePath: databaseFile.path,
        sourcePath: sourceFile.path,
        bulkType: type.apiType,
      ),
    );
  }

  Future<List<ScryfallCardPrint>> search({
    required ScryfallBulkDataType type,
    required File sourceFile,
    required String rawQuery,
    int? maxResults,
    ScryfallSearchSortMode sortMode = ScryfallSearchSortMode.nameAsc,
  }) async {
    await ensureIndex(type: type, sourceFile: sourceFile);

    final databaseFile = await _databaseFile();
    final db = sqlite3.open(databaseFile.path, mode: OpenMode.readOnly);
    try {
      _setBusyTimeout(db);
      final query = _SqliteScryfallQuery.parse(rawQuery);
      final result = query.select(
        db: db,
        bulkType: type.apiType,
        maxResults: maxResults,
        sortMode: sortMode,
      );

      return result
          .map((row) => ScryfallCardPrint.fromJson(jsonDecode(row['json'] as String) as Map<String, dynamic>))
          .toList(growable: false);
    } finally {
      db.dispose();
    }
  }

  Future<File> _databaseFile() async {
    if (_testDatabaseFile != null) return _testDatabaseFile!;
    final supportDir = await getApplicationSupportDirectory();
    return File(p.join(supportDir.path, 'scryfall', 'scryfall_search_index.sqlite'));
  }

  static void _setBusyTimeout(Database db) {
    db.execute('PRAGMA busy_timeout = $busyTimeoutMs');
  }

  static Future<void> _buildIndex({
    required String databasePath,
    required String sourcePath,
    required String bulkType,
  }) async {
    final sourceFile = File(sourcePath);
    final stat = await sourceFile.stat();
    final db = sqlite3.open(databasePath);

    try {
      _setBusyTimeout(db);
      _createSchema(db);
      db.execute('PRAGMA journal_mode = WAL');
      db.execute('PRAGMA synchronous = NORMAL');
      db.execute('PRAGMA temp_store = MEMORY');
      db.execute('PRAGMA cache_size = -64000');

      db.execute('BEGIN IMMEDIATE');
      try {
        db.execute(
          'DELETE FROM cards_fts WHERE rowid IN (SELECT rowid FROM cards WHERE bulk_type = ?)',
          <Object?>[bulkType],
        );
        db.execute('DELETE FROM cards WHERE bulk_type = ?', <Object?>[bulkType]);
        db.execute('DELETE FROM index_metadata WHERE bulk_type = ?', <Object?>[bulkType]);

        final insertCard = db.prepare('''
INSERT INTO cards (
  bulk_type, card_id, oracle_id, json,
  name_norm, type_line_norm, oracle_text_norm, artist_norm, set_code_norm, rarity_norm, lang_norm,
  games_blob, finishes_blob, colors_mask, color_identity_mask, cmc, usd, eur, released_year,
  layout, set_type, is_extra
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
''');
        final insertFts = db.prepare('''
INSERT INTO cards_fts (rowid, name_norm, type_line_norm, oracle_text_norm, artist_norm)
VALUES (?, ?, ?, ?, ?)
''');

        var inserted = 0;
        try {
          await for (final cardJson in ScryfallJsonSearchUtils.readTopLevelJsonObjects(sourcePath)) {
            final decoded = jsonDecode(cardJson);
            if (decoded is! Map<String, dynamic>) continue;

            final prices = decoded['prices'] is Map<String, dynamic>
                ? decoded['prices'] as Map<String, dynamic>
                : const <String, dynamic>{};
            final releasedAt = DateTime.tryParse(decoded['released_at'] as String? ?? '');
            final games = ScryfallJsonSearchUtils.stringList(decoded['games']);
            final finishes = ScryfallJsonSearchUtils.stringList(decoded['finishes']);
            final colors = ScryfallJsonSearchUtils.stringList(decoded['colors']);
            final colorIdentity = ScryfallJsonSearchUtils.stringList(decoded['color_identity']);
            final nameNorm = ScryfallJsonSearchUtils.normalize(decoded['name'] as String? ?? '');
            final typeLineNorm = ScryfallJsonSearchUtils.normalize(ScryfallJsonSearchUtils.coalesceFaces(decoded, 'type_line'));
            final oracleTextNorm = ScryfallJsonSearchUtils.normalize(ScryfallJsonSearchUtils.coalesceFaces(decoded, 'oracle_text'));
            final artistNorm = ScryfallJsonSearchUtils.normalize(decoded['artist'] as String? ?? '');

            insertCard.execute(<Object?>[
              bulkType,
              decoded['id'] as String? ?? '',
              decoded['oracle_id'] as String?,
              cardJson,
              nameNorm,
              typeLineNorm,
              oracleTextNorm,
              artistNorm,
              ScryfallJsonSearchUtils.normalize(decoded['set'] as String? ?? ''),
              ScryfallJsonSearchUtils.normalize(decoded['rarity'] as String? ?? ''),
              ScryfallJsonSearchUtils.normalize(decoded['lang'] as String? ?? ''),
              _stringListBlob(games),
              _stringListBlob(finishes),
              _colorMask(colors),
              _colorMask(colorIdentity),
              ScryfallJsonSearchUtils.toDouble(decoded['cmc']),
              ScryfallJsonSearchUtils.toDouble(prices['usd']),
              ScryfallJsonSearchUtils.toDouble(prices['eur']),
              releasedAt?.year,
              decoded['layout'] as String? ?? '',
              decoded['set_type'] as String? ?? '',
              ScryfallJsonSearchUtils.isExtra(decoded) ? 1 : 0,
            ]);

            insertFts.execute(<Object?>[
              db.lastInsertRowId,
              nameNorm,
              typeLineNorm,
              oracleTextNorm,
              artistNorm,
            ]);
            inserted++;
          }
        } finally {
          insertCard.dispose();
          insertFts.dispose();
        }

        db.execute(
          'INSERT INTO index_metadata (bulk_type, source_size, source_modified_ms, indexed_at_ms, schema_version, index_version, card_count) VALUES (?, ?, ?, ?, ?, ?, ?)',
          <Object?>[
            bulkType,
            stat.size,
            stat.modified.millisecondsSinceEpoch,
            DateTime.now().toUtc().millisecondsSinceEpoch,
            schemaVersion,
            indexVersion,
            inserted,
          ],
        );
        db.execute('COMMIT');
      } catch (_) {
        db.execute('ROLLBACK');
        rethrow;
      }
    } finally {
      db.dispose();
    }
  }

  static void _createSchema(Database db) {
    db.execute('PRAGMA user_version = $schemaVersion');
    db.execute('''
CREATE TABLE IF NOT EXISTS index_metadata (
  bulk_type TEXT PRIMARY KEY NOT NULL,
  source_size INTEGER NOT NULL,
  source_modified_ms INTEGER NOT NULL,
  indexed_at_ms INTEGER NOT NULL,
  schema_version INTEGER NOT NULL,
  index_version INTEGER NOT NULL,
  card_count INTEGER NOT NULL
)
''');

    db.execute('''
CREATE TABLE IF NOT EXISTS cards (
  rowid INTEGER PRIMARY KEY,
  bulk_type TEXT NOT NULL,
  card_id TEXT NOT NULL,
  oracle_id TEXT,
  json TEXT NOT NULL,
  name_norm TEXT NOT NULL,
  type_line_norm TEXT NOT NULL,
  oracle_text_norm TEXT NOT NULL,
  artist_norm TEXT NOT NULL,
  set_code_norm TEXT NOT NULL,
  rarity_norm TEXT NOT NULL,
  lang_norm TEXT NOT NULL,
  games_blob TEXT NOT NULL,
  finishes_blob TEXT NOT NULL,
  colors_mask INTEGER NOT NULL,
  color_identity_mask INTEGER NOT NULL,
  cmc REAL,
  usd REAL,
  eur REAL,
  released_year INTEGER,
  layout TEXT NOT NULL,
  set_type TEXT NOT NULL,
  is_extra INTEGER NOT NULL DEFAULT 0
)
''');

    db.execute('''
CREATE VIRTUAL TABLE IF NOT EXISTS cards_fts USING fts5(
  name_norm,
  type_line_norm,
  oracle_text_norm,
  artist_norm,
  tokenize = 'unicode61 remove_diacritics 2'
)
''');

    db.execute('CREATE INDEX IF NOT EXISTS idx_cards_bulk_extra_name ON cards (bulk_type, is_extra, name_norm)');
    db.execute('CREATE INDEX IF NOT EXISTS idx_cards_bulk_extra_set ON cards (bulk_type, is_extra, set_code_norm)');
    db.execute('CREATE INDEX IF NOT EXISTS idx_cards_bulk_extra_lang ON cards (bulk_type, is_extra, lang_norm)');
    db.execute('CREATE INDEX IF NOT EXISTS idx_cards_bulk_extra_cmc ON cards (bulk_type, is_extra, cmc)');
    db.execute('CREATE INDEX IF NOT EXISTS idx_cards_bulk_extra_year ON cards (bulk_type, is_extra, released_year)');
  }

  static String _stringListBlob(List<String> values) => '|${values.map(ScryfallJsonSearchUtils.normalize).join('|')}|';

  static int _colorMask(List<String> colors) {
    var mask = 0;
    for (final color in colors.map(ScryfallJsonSearchUtils.normalize)) {
      switch (color) {
        case 'w':
          mask |= 1;
          break;
        case 'u':
          mask |= 2;
          break;
        case 'b':
          mask |= 4;
          break;
        case 'r':
          mask |= 8;
          break;
        case 'g':
          mask |= 16;
          break;
      }
    }
    return mask;
  }
}

class _SqliteScryfallQuery {
  const _SqliteScryfallQuery(this.filters);

  final List<ScryfallSearchFilter> filters;

  static _SqliteScryfallQuery parse(String rawQuery) =>
      _SqliteScryfallQuery(ParsedScryfallSearch.parse(rawQuery).filters);

  ResultSet select({
    required Database db,
    required String bulkType,
    required int? maxResults,
    required ScryfallSearchSortMode sortMode,
  }) {
    final whereParts = <String>['cards.bulk_type = ?', 'cards.is_extra = 0'];
    final args = <Object?>[bulkType];

    for (final filter in filters) {
      final predicate = _parseFilter(filter);
      whereParts.add(predicate.sql);
      args.addAll(predicate.args);
    }

    final limitSql = maxResults == null ? '' : ' LIMIT ?';
    if (maxResults != null) args.add(maxResults);

    return db.select(
      'SELECT cards.json FROM cards WHERE ${whereParts.join(' AND ')} ${_orderBy(sortMode)}$limitSql',
      args,
    );
  }

  static _SqlPredicate _parseFilter(ScryfallSearchFilter filter) {
    final predicate = _parsePositiveFilter(filter);
    return filter.negated ? predicate.negated() : predicate;
  }

  static _SqlPredicate _parsePositiveFilter(ScryfallSearchFilter filter) {
    switch (filter.canonicalKeyword) {
      case 'name':
        return _textPredicate('name_norm', filter.operator, filter.normalizedValue);
      case 'type':
        return _textPredicate('type_line_norm', filter.operator, filter.normalizedValue);
      case 'oracle':
        return _textPredicate('oracle_text_norm', filter.operator, filter.normalizedValue);
      case 'artist':
        return _textPredicate('artist_norm', filter.operator, filter.normalizedValue);
      case 'set':
        return _textPredicate('set_code_norm', filter.operator, filter.normalizedValue);
      case 'rarity':
        return _textPredicate('rarity_norm', filter.operator, filter.normalizedValue);
      case 'lang':
        return _textPredicate('lang_norm', filter.operator, filter.normalizedValue);
      case 'game':
        return _blobContainsPredicate('games_blob', filter.normalizedValue);
      case 'colors':
        return _colorPredicate('colors_mask', filter.normalizedValue, filter.operator);
      case 'identity':
        return _colorPredicate('color_identity_mask', filter.normalizedValue, filter.operator);
      case 'manaValue':
        return _numberPredicate('cmc', filter.value, filter.operator);
      case 'usd':
        return _numberPredicate('usd', filter.value, filter.operator);
      case 'eur':
        return _numberPredicate('eur', filter.value, filter.operator);
      case 'year':
        return _numberPredicate('released_year', filter.value, filter.operator);
      case 'is':
        return _isPredicate(filter.normalizedValue);
      case 'in':
        return _inPredicate(filter.normalizedValue);
      default:
        throw UnsupportedError('SQLite search does not support "${filter.keyword}" yet.');
    }
  }

  static String _orderBy(ScryfallSearchSortMode sortMode) {
    switch (sortMode) {
      case ScryfallSearchSortMode.nameAsc:
        return 'ORDER BY cards.name_norm COLLATE NOCASE ASC';
      case ScryfallSearchSortMode.nameDesc:
        return 'ORDER BY cards.name_norm COLLATE NOCASE DESC';
      case ScryfallSearchSortMode.manaValueAsc:
        return 'ORDER BY cards.cmc IS NULL ASC, cards.cmc ASC, cards.name_norm COLLATE NOCASE ASC';
      case ScryfallSearchSortMode.newestFirst:
        return 'ORDER BY cards.released_year IS NULL ASC, cards.released_year DESC, cards.name_norm COLLATE NOCASE ASC';
      case ScryfallSearchSortMode.oldestFirst:
        return 'ORDER BY cards.released_year IS NULL ASC, cards.released_year ASC, cards.name_norm COLLATE NOCASE ASC';
      case ScryfallSearchSortMode.setAsc:
        return 'ORDER BY cards.set_code_norm ASC, cards.card_id ASC';
    }
  }

  static _SqlPredicate _textPredicate(String column, String operator, String expected) {
    switch (operator) {
      case ':':
        if (_ftsColumns.contains(column)) {
          return _SqlPredicate(
            'cards.rowid IN (SELECT rowid FROM cards_fts WHERE $column MATCH ?)',
            <Object?>[_ftsPrefixQuery(expected)],
          );
        }
        return _SqlPredicate("cards.$column LIKE ? ESCAPE '\\'", <Object?>['%${_escapeLike(expected)}%']);
      case '=':
        return _SqlPredicate('cards.$column = ?', <Object?>[expected]);
      case '!=':
        return _SqlPredicate('cards.$column != ?', <Object?>[expected]);
      default:
        throw UnsupportedError('Text operator "$operator" is not supported by SQLite search yet.');
    }
  }

  static const Set<String> _ftsColumns = <String>{
    'name_norm',
    'type_line_norm',
    'oracle_text_norm',
    'artist_norm',
  };

  static _SqlPredicate _blobContainsPredicate(String column, String expected) =>
      _SqlPredicate('cards.$column LIKE ?', <Object?>['%|$expected|%']);

  static _SqlPredicate _numberPredicate(String column, String expected, String operator) {
    final parsed = double.tryParse(expected);
    if (parsed == null) return const _SqlPredicate('0 = 1', <Object?>[]);

    switch (operator) {
      case ':':
      case '=':
        return _SqlPredicate('cards.$column = ?', <Object?>[parsed]);
      case '!=':
        return _SqlPredicate('(cards.$column IS NULL OR cards.$column != ?)', <Object?>[parsed]);
      case '<':
      case '<=':
      case '>':
      case '>=':
        return _SqlPredicate('cards.$column IS NOT NULL AND cards.$column $operator ?', <Object?>[parsed]);
      default:
        return const _SqlPredicate('0 = 1', <Object?>[]);
    }
  }

  static _SqlPredicate _colorPredicate(String column, String expected, String operator) {
    final expectedMask = _colorMaskFromString(expected);
    switch (operator) {
      case ':':
      case '<=':
        return _SqlPredicate('(cards.$column & ~?) = 0', <Object?>[expectedMask]);
      case '=':
        return _SqlPredicate('cards.$column = ?', <Object?>[expectedMask]);
      case '>=':
        return _SqlPredicate('(cards.$column & ?) = ?', <Object?>[expectedMask, expectedMask]);
      case '!=':
        return _SqlPredicate('cards.$column != ?', <Object?>[expectedMask]);
      default:
        throw UnsupportedError('Color operator "$operator" is not supported by SQLite search yet.');
    }
  }

  static _SqlPredicate _isPredicate(String value) {
    switch (value) {
      case 'multicolored':
      case 'multicolor':
        return const _SqlPredicate('cards.colors_mask NOT IN (0, 1, 2, 4, 8, 16)', <Object?>[]);
      case 'monocolored':
      case 'monocolor':
        return const _SqlPredicate('cards.colors_mask IN (1, 2, 4, 8, 16)', <Object?>[]);
      case 'colorless':
        return const _SqlPredicate('cards.colors_mask = 0', <Object?>[]);
      case 'paper':
        return _blobContainsPredicate('games_blob', 'paper');
      case 'digital':
        return const _SqlPredicate("cards.games_blob NOT LIKE '%|paper|%'", <Object?>[]);
      case 'foil':
        return _blobContainsPredicate('finishes_blob', 'foil');
      case 'nonfoil':
        return _blobContainsPredicate('finishes_blob', 'nonfoil');
      default:
        throw UnsupportedError('SQLite search does not support is:$value yet.');
    }
  }

  static _SqlPredicate _inPredicate(String value) {
    switch (value) {
      case 'paper':
      case 'arena':
      case 'mtgo':
        return _blobContainsPredicate('games_blob', value);
      default:
        throw UnsupportedError('SQLite search does not support in:$value yet.');
    }
  }

  static String _ftsPrefixQuery(String value) {
    final terms = RegExp(r'[\p{L}\p{N}_]+', unicode: true)
        .allMatches(value)
        .map((match) => match.group(0)!)
        .where((term) => term.isNotEmpty)
        .toList(growable: false);

    if (terms.isEmpty) return '"${_escapeFtsPhrase(value)}"';
    return terms.map((term) => '"${_escapeFtsPhrase(term)}"*').join(' AND ');
  }

  static String _escapeFtsPhrase(String value) => value.replaceAll('"', '""');

  static String _escapeLike(String value) => value.replaceAll('\\', '\\\\').replaceAll('%', '\\%').replaceAll('_', '\\_');

  static int _colorMaskFromString(String value) {
    var mask = 0;
    for (final char in value.split('')) {
      switch (char) {
        case 'w':
          mask |= 1;
          break;
        case 'u':
          mask |= 2;
          break;
        case 'b':
          mask |= 4;
          break;
        case 'r':
          mask |= 8;
          break;
        case 'g':
          mask |= 16;
          break;
      }
    }
    return mask;
  }
}

class _SqlPredicate {
  const _SqlPredicate(this.sql, this.args);

  final String sql;
  final List<Object?> args;

  _SqlPredicate negated() => _SqlPredicate('NOT ($sql)', args);
}
