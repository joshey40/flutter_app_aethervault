import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_app_aethervault/services/card_database/database.dart';
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
}
