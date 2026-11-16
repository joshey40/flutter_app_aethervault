import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_app_aethervault/services/card_database/database.dart';
import 'package:flutter_app_aethervault/services/collection/collection_enums.dart';
import 'package:flutter_app_aethervault/services/collection/collection_repository.dart';
import 'package:flutter_app_aethervault/services/collection/collection_search.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    Future<void> card(String id, String name, String type, String lang) {
      return db
          .into(db.scryfallCards)
          .insert(
            ScryfallCardsCompanion.insert(
              scryfallId: id,
              layout: 'normal',
              name: name,
              setId: 'set',
              setCode: 'tst',
              setName: 'Test',
              setType: 'core',
              setUri: '',
              setSearchUri: '',
              scryfallSetUri: '',
              collectorNumber: '1',
              lang: lang,
              rarity: 'common',
              releasedAt: '2020-01-01',
              scryfallUri: '',
              uri: '',
              rulingsUri: '',
              printsSearchUri: '',
              typeLine: type,
              cmc: 1,
            ),
          );
    }

    await card('bolt', 'Lightning Bolt', 'Instant', 'en');
    await card('elves', 'Llanowar Elves', 'Creature — Elf Druid', 'en');
    await card('insel', 'Island', 'Basic Land — Island', 'de');
    await card('other', 'Grizzly Bears', 'Creature — Bear', 'en');
  });

  tearDown(() => db.close());

  const owned = ['bolt', 'elves', 'insel'];

  test('finds owned cards by name', () async {
    expect(await db.filterCardIdsByScryfallSyntax('bolt', owned), {'bolt'});
  });

  test('only searches the given cards', () async {
    expect(await db.filterCardIdsByScryfallSyntax('t:creature', owned), {
      'elves',
    });
  });

  test('does not apply the default language filter of the search', () async {
    expect(await db.filterCardIdsByScryfallSyntax('t:land', owned), {'insel'});
  });

  test('an empty query matches everything', () async {
    expect(await db.filterCardIdsByScryfallSyntax('  ', owned), owned.toSet());
  });

  group('own: and cond:', () {
    CardGroup group(
      String scryfallId, {
      CardFinish finish = CardFinish.nonfoil,
      CardQuality quality = CardQuality.nearMint,
      bool isProxy = false,
      bool isSigned = false,
    }) => CardGroup(
      scryfallId: scryfallId,
      finish: finish,
      quality: quality,
      isProxy: isProxy,
      isAltered: false,
      isSigned: isSigned,
      isOwned: true,
      entryIds: ['$scryfallId-${finish.value}-${quality.value}'],
      lastAddedAt: 0,
    );

    final foilElves = group('elves', finish: CardFinish.foil);
    final playedElves = group('elves', quality: CardQuality.played);
    final mintBolt = group('bolt', quality: CardQuality.mint, isProxy: true);
    final unknownIsland = group('insel', quality: CardQuality.unknown);
    final groups = [foilElves, playedElves, mintBolt, unknownIsland];

    Future<Set<String>> search(String query) =>
        CollectionSearch(db).filter(query, groups);

    test('own: filters by finish and flags, also negated', () async {
      expect(await search('own:foil'), {foilElves.key});
      expect(await search('own:proxy'), {mintBolt.key});
      expect(await search('-own:proxy'), {
        foilElves.key,
        playedElves.key,
        unknownIsland.key,
      });
    });

    test('cond: takes numbers and codes and compares them', () async {
      expect(await search('cond:nm'), {foilElves.key});
      expect(await search('condition:6'), {playedElves.key});
      expect(await search('cond<=NM'), {foilElves.key, mintBolt.key});
      // Unknown condition never matches a comparison.
      expect(await search('cond>=1'), {
        foilElves.key,
        playedElves.key,
        mintBolt.key,
      });
    });

    test('combines with Scryfall filters, or and brackets', () async {
      expect(await search('t:creature own:foil'), {foilElves.key});
      expect(await search('t:creature (own:foil or cond:pl)'), {
        foilElves.key,
        playedElves.key,
      });
      expect(await search('own:proxy or t:land'), {
        mintBolt.key,
        unknownIsland.key,
      });
    });

    test('invalid values are reported', () {
      expect(() => search('own:shiny'), throwsFormatException);
      expect(() => search('cond:8'), throwsFormatException);
    });
  });
}
