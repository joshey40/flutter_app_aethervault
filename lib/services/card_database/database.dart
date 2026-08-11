import 'package:drift/drift.dart';
import 'dart:convert';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'scryfall_query.dart';

// The database.g.dart file is generated with the build_runner: dart run build_runner build or dart run build_runner watch
part 'database.g.dart';

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) { return List<String>.from(json.decode(fromDb)); }

  @override
  String toSql(List<String> value) { return json.encode(value); }
}
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
  BoolColumn get hasColorIndicator => boolean().withDefault(const Constant(false))();
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
  BoolColumn get storySpotlight => boolean().withDefault(const Constant(false))();
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

class ScryfallCardFaces extends Table {
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
  IntColumn get colorIndicatorMask => integer().withDefault(const Constant(0))();

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

@DriftDatabase(tables: [ScryfallCards, ScryfallCardFaces, ScryfallTags])
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal([QueryExecutor? executor]) : super(executor ?? _openConnection());

  static AppDatabase? _instance;

  factory AppDatabase() {
    return _instance ??= AppDatabase._internal();
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          await m.deleteTable('scryfall_card_faces');
          await m.deleteTable('scryfall_cards');
          await m.deleteTable('scryfall_tags');
          await m.createAll();
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

  Future<List<ScryfallCardFace>> getCardFacesByCardId(String cardId) async {
    return (select(scryfallCardFaces)
          ..where((tbl) => tbl.cardId.equals(cardId))
          ..orderBy([(t) => OrderingTerm(expression: t.faceIndex)]))
        .get();
  }

  Future<List<ScryfallCard>> getCardsByScryfallSyntax(String syntax, String searchScope, String orderBy, String orderDir) async {
    final tokens = tokenizeScryfallSyntax(syntax);
    final hasLangFilter = containsLangFilter(tokens);
    final hasTypeFilter = containsTypeFilter(tokens);
    final hasSetFilter = containsSetFilter(tokens);

    final query = select(scryfallCards)
      ..where((t) {
        Expression<bool> expr = const Constant(true);
        if (tokens.isNotEmpty) {
          expr = tokens.map((tok) => compileQueryToken(t, tok)).reduce((a, b) => a & b);
        }
        if (!hasTypeFilter) {
          expr = expr & t.layout.isNotIn(['token', 'double_faced_token', 'emblem', 'host', 'art_series', 'planar', 'scheme', 'vanguard']);
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

    query.orderBy([(t) => OrderingTerm(expression: t.releasedAt, mode: OrderingMode.desc)]);
    final rows = await query.get();
    scopeCards(rows, searchScope);
    sortCards(rows, orderBy, orderDir);
    return rows;
  }
}