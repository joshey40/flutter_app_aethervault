import 'package:drift/drift.dart';
import 'dart:convert';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../collection/collection_enums.dart';
import 'scryfall_query.dart';

// The database.g.dart file is generated with the build_runner: dart run build_runner build or dart run build_runner watch
part 'database.g.dart';

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    return List<String>.from(json.decode(fromDb));
  }

  @override
  String toSql(List<String> value) {
    return json.encode(value);
  }
}

// ==============================================================================
// Scryfall Database Tables
// ==============================================================================

/// Stores the card data imported from Scryfall.
class ScryfallCards extends Table {
  TextColumn get scryfallId => text()();
  TextColumn get oracleId => text().nullable()();
  TextColumn get tcgplayerId => text().nullable()();
  TextColumn get cardmarketId => text().nullable()();
  TextColumn get multiverseIdsJson => text().nullable()();

  TextColumn get layout => text()();

  TextColumn get name => text()();
  TextColumn get printedName => text().nullable()();
  TextColumn get flavorName => text().nullable()();

  TextColumn get setId => text()();
  TextColumn get setCode => text()();
  TextColumn get setName => text()();
  TextColumn get setType => text()();
  TextColumn get setUri => text()();
  TextColumn get setSearchUri => text()();
  TextColumn get scryfallSetUri => text()();

  TextColumn get collectorNumber => text()();
  TextColumn get lang => text()();
  TextColumn get rarity => text()();
  IntColumn get rarityValue => integer().withDefault(const Constant(0))();
  TextColumn get releasedAt => text()();
  IntColumn get releasedAtYear => integer().withDefault(const Constant(0))();

  TextColumn get scryfallUri => text()();
  TextColumn get uri => text()();
  TextColumn get rulingsUri => text()();
  TextColumn get printsSearchUri => text()();

  TextColumn get manaCost => text().nullable()();
  TextColumn get typeLine => text()();
  TextColumn get printedTypeLine => text().nullable()();
  TextColumn get oracleText => text().nullable()();
  TextColumn get printedText => text().nullable()();
  TextColumn get flavorText => text().nullable()();

  TextColumn get colorsJson => text().nullable()();
  IntColumn get colorMask => integer().withDefault(const Constant(0))();
  TextColumn get colorIdentityJson => text().nullable()();
  IntColumn get colorIdentityMask => integer().withDefault(const Constant(0))();
  TextColumn get producedManaJson => text().nullable()();
  IntColumn get producedManaMask => integer().withDefault(const Constant(0))();

  TextColumn get power => text().nullable()();
  TextColumn get toughness => text().nullable()();
  TextColumn get loyalty => text().nullable()();
  TextColumn get defense => text().nullable()();
  RealColumn get cmc => real()();

  TextColumn get keywordsJson => text().nullable()();
  BoolColumn get hasCardFaces => boolean().withDefault(const Constant(false))();
  BoolColumn get hasColorIndicator =>
      boolean().withDefault(const Constant(false))();
  TextColumn get borderColor => text().nullable()();
  TextColumn get frame => text().nullable()();
  TextColumn get frameEffectsJson => text().nullable()();
  TextColumn get securityStamp => text().nullable()();

  BoolColumn get highresImage => boolean().withDefault(const Constant(false))();
  TextColumn get imageStatus => text().nullable()();
  TextColumn get imageUpdatedAt => text().nullable()();
  TextColumn get imageSmall => text().nullable()();
  TextColumn get imageNormal => text().nullable()();
  TextColumn get imageLarge => text().nullable()();
  TextColumn get imagePng => text().nullable()();
  TextColumn get imageArtCrop => text().nullable()();
  TextColumn get imageBorderCrop => text().nullable()();
  TextColumn get artist => text().nullable()();
  TextColumn get artistIdsJson => text().nullable()();
  TextColumn get illustrationId => text().nullable()();
  TextColumn get watermark => text().nullable()();

  BoolColumn get fullArt => boolean().withDefault(const Constant(false))();
  BoolColumn get textless => boolean().withDefault(const Constant(false))();
  BoolColumn get booster => boolean().withDefault(const Constant(false))();
  BoolColumn get storySpotlight =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get promo => boolean().withDefault(const Constant(false))();
  BoolColumn get reprint => boolean().withDefault(const Constant(false))();
  BoolColumn get variation => boolean().withDefault(const Constant(false))();
  BoolColumn get reserved => boolean().withDefault(const Constant(false))();
  BoolColumn get gameChanger => boolean().withDefault(const Constant(false))();
  BoolColumn get oversized => boolean().withDefault(const Constant(false))();
  BoolColumn get nonfoil => boolean().withDefault(const Constant(false))();
  BoolColumn get foil => boolean().withDefault(const Constant(false))();
  BoolColumn get etched => boolean().withDefault(const Constant(false))();
  BoolColumn get glossy => boolean().withDefault(const Constant(false))();
  BoolColumn get paper => boolean().withDefault(const Constant(false))();

  TextColumn get legalStandard => text().nullable()();
  TextColumn get legalFuture => text().nullable()();
  TextColumn get legalHistoric => text().nullable()();
  TextColumn get legalTimeless => text().nullable()();
  TextColumn get legalGladiator => text().nullable()();
  TextColumn get legalPioneer => text().nullable()();
  TextColumn get legalModern => text().nullable()();
  TextColumn get legalLegacy => text().nullable()();
  TextColumn get legalPauper => text().nullable()();
  TextColumn get legalVintage => text().nullable()();
  TextColumn get legalPenny => text().nullable()();
  TextColumn get legalCommander => text().nullable()();
  TextColumn get legalOathbreaker => text().nullable()();
  TextColumn get legalStandardBrawl => text().nullable()();
  TextColumn get legalBrawl => text().nullable()();
  TextColumn get legalCompetitiveBrawl => text().nullable()();
  TextColumn get legalAlchemy => text().nullable()();
  TextColumn get legalPauperCommander => text().nullable()();
  TextColumn get legalDuel => text().nullable()();
  TextColumn get legalOldSchool => text().nullable()();
  TextColumn get legalPremodern => text().nullable()();
  TextColumn get legalPredh => text().nullable()();
  TextColumn get legalTlr => text().nullable()();

  TextColumn get pricesUsd => text().nullable()();
  TextColumn get pricesUsdFoil => text().nullable()();
  TextColumn get pricesUsdEtched => text().nullable()();
  TextColumn get pricesEur => text().nullable()();
  TextColumn get pricesEurFoil => text().nullable()();
  TextColumn get pricesTix => text().nullable()();

  TextColumn get relatedGathererUri => text().nullable()();
  TextColumn get relatedTcgplayerInfiniteArticlesUri => text().nullable()();
  TextColumn get relatedTcgplayerInfiniteDecksUri => text().nullable()();
  TextColumn get relatedEdhrecUri => text().nullable()();

  TextColumn get purchaseTcgplayerUri => text().nullable()();
  TextColumn get purchaseCardmarketUri => text().nullable()();
  TextColumn get purchaseCardhoarderUri => text().nullable()();

  TextColumn get cardBackId => text().nullable()();
  TextColumn get allPartsJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {scryfallId};
}

/// Stores the individual faces of multi-faced Scryfall cards.
class ScryfallCardFaces extends Table {
  // Links each face to its parent card.
  TextColumn get cardId => text().references(ScryfallCards, #scryfallId)();
  IntColumn get faceIndex => integer()();

  TextColumn get name => text()();
  TextColumn get printedName => text().nullable()();
  TextColumn get flavorName => text().nullable()();

  TextColumn get manaCost => text().nullable()();
  TextColumn get typeLine => text().nullable()();
  TextColumn get printedTypeLine => text().nullable()();
  TextColumn get oracleText => text().nullable()();
  TextColumn get printedText => text().nullable()();
  TextColumn get flavorText => text().nullable()();

  TextColumn get colorsJson => text().nullable()();
  IntColumn get colorMask => integer().withDefault(const Constant(0))();
  TextColumn get colorIndicatorJson => text().nullable()();
  IntColumn get colorIndicatorMask =>
      integer().withDefault(const Constant(0))();

  TextColumn get power => text().nullable()();
  TextColumn get toughness => text().nullable()();
  TextColumn get loyalty => text().nullable()();
  TextColumn get defense => text().nullable()();
  RealColumn get cmc => real()();

  TextColumn get artist => text().nullable()();
  TextColumn get artistId => text().nullable()();
  TextColumn get illustrationId => text().nullable()();
  BoolColumn get highresImage => boolean().withDefault(const Constant(false))();
  TextColumn get imageStatus => text().nullable()();
  TextColumn get imageSmall => text().nullable()();
  TextColumn get imageNormal => text().nullable()();
  TextColumn get imageLarge => text().nullable()();
  TextColumn get imagePng => text().nullable()();
  TextColumn get imageArtCrop => text().nullable()();
  TextColumn get imageBorderCrop => text().nullable()();
  TextColumn get watermark => text().nullable()();

  @override
  Set<Column> get primaryKey => {cardId, faceIndex};
}

class ScryfallTags extends Table {
  TextColumn get scryfallId => text()();
  TextColumn get label => text()();
  TextColumn get slug => text()();
  TextColumn get description => text()();
  TextColumn get type => text()();

  TextColumn get parentIdsJson => text().map(const StringListConverter())();
  TextColumn get childIdsJson => text().map(const StringListConverter())();
  TextColumn get aliasesJson => text().map(const StringListConverter())();
  TextColumn get taggedJson => text().map(const StringListConverter())();

  @override
  Set<Column> get primaryKey => {scryfallId};
}

/// Stores the set data imported from Scryfall.
class ScryfallSets extends Table {
  TextColumn get scryfallId => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get releasedAt => text()();
  TextColumn get setType => text()();
  IntColumn get cardCount => integer()();
  TextColumn get parentSetCode => text().nullable()();
  BoolColumn get nonfoilOnly => boolean()();
  BoolColumn get foilOnly => boolean()();
  TextColumn get blockCode => text().nullable()();
  TextColumn get blockName => text().nullable()();
  TextColumn get iconSvgUri => text()();

  @override
  Set<Column> get primaryKey => {scryfallId};
}

// ==============================================================================
// Collection Tables
// ==============================================================================
//
// IDs are UUIDs generated on the client. Rows are never deleted directly:
// they are marked with isDeleted and synced, and only purged afterwards.
// A null folderId / parentId means the item lives in the (implicit) root.

/// A box, a deck or a board inside a deck.
@TableIndex(name: 'folders_parent', columns: {#parentId})
class Folders extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get parentId => text().nullable()();
  IntColumn get folderType => integer().map(FolderType.converter)();
  BoolColumn get isPrivate => boolean().withDefault(const Constant(false))();
  TextColumn get color => text().nullable()();

  /// Deck only.
  TextColumn get format => text().nullable()();

  /// Deck only.
  IntColumn get bracket => integer().nullable()();
  TextColumn get description => text().nullable()();

  /// Unix time in milliseconds.
  IntColumn get addedAt => integer()();

  // Sync
  /// Server version of this row, null if it was never synced.
  IntColumn get versionAt => integer().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  /// 0 = synced. Every local change increments it.
  IntColumn get dirtyRevision => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// One physical card (or a placeholder inside a deck, if [isOwned] is false).
@TableIndex(name: 'collection_entries_folder', columns: {#folderId})
@TableIndex(name: 'collection_entries_scryfall', columns: {#scryfallId})
class CollectionEntries extends Table {
  TextColumn get id => text()();

  /// No foreign key: the Scryfall tables are wiped and re-downloaded.
  TextColumn get scryfallId => text()();
  TextColumn get folderId => text().nullable()();
  BoolColumn get isProxy => boolean().withDefault(const Constant(false))();
  BoolColumn get isAltered => boolean().withDefault(const Constant(false))();
  BoolColumn get isSigned => boolean().withDefault(const Constant(false))();
  BoolColumn get isOwned => boolean().withDefault(const Constant(true))();
  IntColumn get quality => integer().map(CardQuality.converter)();
  IntColumn get finish => integer().map(CardFinish.converter)();

  /// Unix time in milliseconds. Stays the same when the card is moved.
  IntColumn get addedAt => integer()();

  // Sync
  IntColumn get versionAt => integer().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get dirtyRevision => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// =============================================================================
// Deck Tables
// =============================================================================

// Decks are folders (FolderType.deck) with board folders inside, see Folders.

// ==============================================================================
// AppDatabase and Queries
// ==============================================================================

@DriftDatabase(
  tables: [
    ScryfallCards,
    ScryfallCardFaces,
    ScryfallTags,
    ScryfallSets,
    Folders,
    CollectionEntries,
  ],
)
/// Provides access to the application's local Drift database.
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal([QueryExecutor? executor])
    : super(executor ?? _openConnection());

  /// Creates a separate database on [executor], e.g. an in-memory one in tests.
  AppDatabase.forTesting(super.executor);

  static AppDatabase? _instance;

  factory AppDatabase() {
    return _instance ??= AppDatabase._internal();
  }

  /// Version history:
  /// 1: Scryfall tables
  /// 2: Collection tables (Folders, CollectionEntries)
  @override
  int get schemaVersion => 2;

  /// The last schema version that changed the Scryfall tables. Upgrades from
  /// an older version drop and recreate them (the data gets re-downloaded).
  /// Bump this to the new [schemaVersion] whenever a Scryfall table changes.
  static const _lastScryfallSchemaChange = 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // Scryfall data doesn't need to be migrated. Will be deleted and redownloaded.
      if (from < _lastScryfallSchemaChange) {
        await m.deleteTable('scryfall_card_faces');
        await m.deleteTable('scryfall_cards');
        await m.deleteTable('scryfall_tags');
        await m.deleteTable('scryfall_sets');
        await m.createTable(scryfallCardFaces);
        await m.createTable(scryfallCards);
        await m.createTable(scryfallTags);
        await m.createTable(scryfallSets);
      }

      // User data: never drop these tables, always migrate step by step.
      if (from < 2) {
        await m.createTable(folders);
        await m.createTable(collectionEntries);
        await m.createIndex(foldersParent);
        await m.createIndex(collectionEntriesFolder);
        await m.createIndex(collectionEntriesScryfall);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA journal_mode = WAL;');
      await customStatement('PRAGMA synchronous = NORMAL;');
      await customStatement('PRAGMA temp_store = MEMORY;');
      await customStatement('PRAGMA cache_size = -50000;'); // 50 MB
      await customStatement('PRAGMA mmap_size = 268435456;'); // 256 MB
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'app_database',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationDocumentsDirectory,
      ),
    );
  }

  // =============================================================================
  // Custom queries
  // =============================================================================

  /// Get a single card by its Scryfall ID.
  Future<ScryfallCard?> getCardById(String scryfallId) async {
    return (select(
      scryfallCards,
    )..where((tbl) => tbl.scryfallId.equals(scryfallId))).getSingleOrNull();
  }

  /// Get several cards by their Scryfall IDs, keyed by ID. Unknown IDs are
  /// missing from the result.
  Future<Map<String, ScryfallCard>> getCardsByIds(List<String> ids) async {
    if (ids.isEmpty) return {};
    final rows = await (select(
      scryfallCards,
    )..where((tbl) => tbl.scryfallId.isIn(ids))).get();
    return {for (final row in rows) row.scryfallId: row};
  }

  /// The image of the first face for each of the given cards (for cards
  /// without a top-level image, like double-faced cards), keyed by card ID.
  Future<Map<String, String>> getFrontFaceImages(List<String> cardIds) async {
    if (cardIds.isEmpty) return {};
    final rows =
        await (select(scryfallCardFaces)
              ..where(
                (tbl) => tbl.cardId.isIn(cardIds) & tbl.imageNormal.isNotNull(),
              )
              ..orderBy([(t) => OrderingTerm(expression: t.faceIndex)]))
            .get();
    final result = <String, String>{};
    for (final face in rows) {
      result.putIfAbsent(face.cardId, () => face.imageNormal!);
    }
    return result;
  }

  /// Get all printed variants that share an Oracle ID.
  Future<List<ScryfallCard>> getCardVariantsByOracleId(String oracleId) async {
    return (select(scryfallCards)
          ..where((tbl) => tbl.oracleId.equals(oracleId))
          ..orderBy([
            (tbl) => OrderingTerm(expression: tbl.releasedAt),
            (tbl) => OrderingTerm(expression: tbl.setName),
          ]))
        .get();
  }

  /// Get all card faces associated with a specific card ID, ordered by face index.
  Future<List<ScryfallCardFace>> getCardFacesByCardId(String cardId) async {
    return (select(scryfallCardFaces)
          ..where((tbl) => tbl.cardId.equals(cardId))
          ..orderBy([(t) => OrderingTerm(expression: t.faceIndex)]))
        .get();
  }

  /// Get cards based on Scryfall syntax, search scope, and ordering preferences.
  Future<List<ScryfallCard>> getCardsByScryfallSyntax(
    String syntax,
    String searchScope,
    String orderBy,
    String orderDir,
  ) async {
    final tokens = tokenizeScryfallSyntax(syntax);
    final hasLangFilter = containsLangFilter(tokens);
    final hasTypeFilter = containsTypeFilter(tokens);
    final hasSetFilter = containsSetFilter(tokens);

    final oracleTagSlugs = collectOracleTagLookups(tokens);
    final illustrationTagSlugs = collectIllustrationTagLookups(tokens);
    final oracleTagIds = await _resolveTagLookups(oracleTagSlugs, 'oracle');
    final illustrationTagIds = await _resolveTagLookups(
      illustrationTagSlugs,
      'illustration',
    );

    final allSets = await select(scryfallSets).get();

    final query = select(scryfallCards)
      ..where((t) {
        Expression<bool> expr = const Constant(true);
        if (tokens.isNotEmpty) {
          expr = tokens
              .map(
                (tok) => compileQueryToken(
                  t,
                  tok,
                  oracleTagIds,
                  illustrationTagIds,
                  allSets,
                  this,
                ),
              )
              .reduce((a, b) => a & b);
        }
        if (!hasTypeFilter) {
          expr =
              expr &
              t.layout.isNotIn([
                'token',
                'double_faced_token',
                'emblem',
                'host',
                'art_series',
                'planar',
                'scheme',
                'vanguard',
              ]);
          expr = expr & t.typeLine.equals('Card').not();
        }
        if (!hasLangFilter) {
          expr = expr & t.lang.equals('en');
        }
        if (!hasSetFilter) {
          expr = expr & t.setType.isNotIn(['memorabilia', 'promo', 'funny']);
        }
        return expr;
      });

    query.orderBy([
      (t) => OrderingTerm(expression: t.releasedAt, mode: OrderingMode.desc),
    ]);
    final rows = await query.get();
    scopeCards(rows, searchScope);
    sortCards(rows, orderBy, orderDir, allSets);
    return rows;
  }

  /// All printings whose name (case-insensitive) is one of [names]. Also
  /// matches the printed (e.g. German) name and the front face of
  /// double-faced cards ("Delver of Secrets" finds "Delver of Secrets // ...").
  Future<List<ScryfallCard>> findCardsByNames(Iterable<String> names) async {
    final lowerNames = names.map((name) => name.toLowerCase()).toSet().toList();
    final result = <ScryfallCard>[];
    // Stay well below SQLite's limit for variables per statement.
    const chunkSize = 500;
    for (var start = 0; start < lowerNames.length; start += chunkSize) {
      final chunk = lowerNames.sublist(
        start,
        (start + chunkSize).clamp(0, lowerNames.length),
      );
      final placeholders = List.filled(chunk.length, '?').join(', ');
      final rows = await customSelect(
        'SELECT * FROM scryfall_cards '
        'WHERE lower(name) IN ($placeholders) '
        'OR lower(printed_name) IN ($placeholders) '
        "OR (instr(name, ' // ') > 0 AND "
        "lower(substr(name, 1, instr(name, ' // ') - 1)) IN ($placeholders))",
        variables: [
          for (var i = 0; i < 3; i++)
            for (final name in chunk) Variable<String>(name),
        ],
        readsFrom: {scryfallCards},
      ).get();
      result.addAll(rows.map((row) => scryfallCards.map(row.data)));
    }
    return result;
  }

  /// All printings with one of the given (set code, collector number) pairs,
  /// in any language.
  Future<List<ScryfallCard>> findCardsBySetAndNumber(
    Iterable<(String, String)> printings,
  ) async {
    final pairs = printings.toSet().toList();
    final result = <ScryfallCard>[];
    const chunkSize = 300;
    for (var start = 0; start < pairs.length; start += chunkSize) {
      final chunk = pairs.sublist(
        start,
        (start + chunkSize).clamp(0, pairs.length),
      );
      final query = select(scryfallCards)
        ..where(
          (t) => chunk
              .map(
                (pair) =>
                    t.setCode.equals(pair.$1.toLowerCase()) &
                    t.collectorNumber.equals(pair.$2),
              )
              .reduce((a, b) => a | b),
        );
      result.addAll(await query.get());
    }
    return result;
  }

  /// Of the cards [ids], returns the ones matching the Scryfall [syntax].
  ///
  /// Unlike [getCardsByScryfallSyntax], no default filters (language, tokens,
  /// promos, ...) apply: everything the user owns can be found. Throws a
  /// [FormatException] for invalid syntax.
  Future<Set<String>> filterCardIdsByScryfallSyntax(
    String syntax,
    Iterable<String> ids,
  ) async {
    return filterCardIdsByTokens(tokenizeScryfallSyntax(syntax), ids);
  }

  /// Like [filterCardIdsByScryfallSyntax], for already parsed [tokens]
  /// (all of them must match).
  Future<Set<String>> filterCardIdsByTokens(
    List<QueryToken> tokens,
    Iterable<String> ids,
  ) async {
    final idList = ids.toList();
    if (idList.isEmpty) return {};
    if (tokens.isEmpty) return idList.toSet();

    final oracleTagIds = await _resolveTagLookups(
      collectOracleTagLookups(tokens),
      'oracle',
    );
    final illustrationTagIds = await _resolveTagLookups(
      collectIllustrationTagLookups(tokens),
      'illustration',
    );
    final allSets = await select(scryfallSets).get();

    final matches = tokens
        .map(
          (token) => compileQueryToken(
            scryfallCards,
            token,
            oracleTagIds,
            illustrationTagIds,
            allSets,
            this,
          ),
        )
        .reduce((a, b) => a & b);
    final query = selectOnly(scryfallCards)
      ..addColumns([scryfallCards.scryfallId])
      ..where(scryfallCards.scryfallId.isIn(idList) & matches);
    final rows = await query.get();
    return {for (final row in rows) row.read(scryfallCards.scryfallId)!};
  }

  /// Resolve tag lookups for a set of [slugs] and a specific [tagType], returning a map of slugs to their associated tag IDs.
  Future<Map<String, List<String>>> _resolveTagLookups(
    Set<String> slugs,
    String tagType,
  ) async {
    if (slugs.isEmpty) return {};

    final allTags = await (select(
      scryfallTags,
    )..where((t) => t.type.equals(tagType))).get();
    final byId = {for (final tag in allTags) tag.scryfallId: tag};

    final result = <String, List<String>>{};
    for (final slug in slugs) {
      final roots = allTags.where(
        (t) => t.slug == slug || t.aliasesJson.contains(slug),
      );
      if (roots.isEmpty) continue;

      final ids = <String>{};
      final visited = <String>{};
      final queue = [for (final r in roots) r.scryfallId];

      while (queue.isNotEmpty) {
        final currentId = queue.removeLast();
        if (!visited.add(currentId)) continue;
        final row = byId[currentId];
        if (row == null) continue;
        ids.addAll(row.taggedJson);
        queue.addAll(row.childIdsJson);
      }

      if (ids.isNotEmpty) result[slug] = ids.toList();
    }
    return result;
  }
}
