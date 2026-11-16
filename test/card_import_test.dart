import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_app_aethervault/services/card_database/database.dart';
import 'package:flutter_app_aethervault/services/collection/collection_enums.dart';
import 'package:flutter_app_aethervault/services/import/card_import_resolver.dart';
import 'package:flutter_app_aethervault/services/import/card_list_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CSV', () {
    test('reads a Moxfield export', () {
      const csv =
          '"Count","Tradelist Count","Name","Edition","Condition","Language","Foil","Tags","Last Modified","Collector Number","Alter","Proxy","Purchase Price"\n'
          '"1","1","Rampant Growth","fic","Near Mint","English","","","2026-11-16 12:15:57.337000","313","False","False",""\n'
          '"2","2","Sol Ring","msc","Near Mint","German","foil","","2026-11-16 12:15:36.840000","211","True","False",""\n'
          '"4","4","Sol Ring","frc","Near Mint","English","","","2026-11-16 12:14:41.970000","21","False","False",""\n';

      final result = parseCardList(csv);

      expect(result.format, 'csv');
      expect(result.errors, isEmpty);
      expect(result.lines.map((l) => l.quantity), [1, 2, 4]);
      final solRing = result.lines[1];
      expect(solRing.name, 'Sol Ring');
      expect(solRing.setCode, 'msc');
      expect(solRing.collectorNumber, '211');
      expect(solRing.language, 'de');
      expect(solRing.finish, CardFinish.foil);
      expect(solRing.quality, CardQuality.nearMint);
      expect(solRing.isAltered, isTrue);
      expect(solRing.isProxy, isFalse);
      expect(result.lines.first.finish, CardFinish.nonfoil);
    });

    test('reads a ManaBox export with Scryfall IDs', () {
      const csv =
          'Name,Set code,Set name,Collector number,Foil,Rarity,Quantity,ManaBox ID,Scryfall ID,Purchase price,Misprint,Altered,Condition,Language,Purchase price currency\n'
          '"Ghave, Guru of Spores",2x2,Double Masters 2022,216,foil,mythic,3,1,ABC-123,1.5,false,false,lightly_played,de,EUR\n';

      final line = parseCardList(csv).lines.single;

      expect(line.name, 'Ghave, Guru of Spores');
      expect(line.quantity, 3);
      expect(line.setCode, '2x2');
      expect(line.scryfallId, 'abc-123');
      expect(line.finish, CardFinish.foil);
      // TCGplayer "lightly played" is Excellent on our scale.
      expect(line.quality, CardQuality.excellent);
      expect(line.language, 'de');
    });

    test('reads an Archidekt-like export', () {
      const csv =
          'Quantity,Name,Finish,Condition,Language,Edition Code,Collector Number\n'
          '1,Fire // Ice,Etched,MP,EN,mh2,290\n';

      final line = parseCardList(csv).lines.single;

      expect(line.name, 'Fire // Ice');
      expect(line.finish, CardFinish.etched);
      expect(line.quality, CardQuality.lightPlayed);
      expect(line.language, 'en');
    });

    test('reports rows without a name or with a bad amount', () {
      const csv = 'Count,Name\nx,Sol Ring\n2,\n1,Island\n';

      final result = parseCardList(csv);

      expect(result.lines.single.name, 'Island');
      expect(result.errors.map((e) => e.lineNumber), [2, 3]);
    });
  });

  group('text lists', () {
    test('reads lines with set and collector number', () {
      const text =
          '1 Ghave, Guru of Spores (2X2) 216\n'
          '1 Abzan Charm (DMC) 138\n'
          "1 Ambition's Cost (C20) 129\n";

      final result = parseCardList(text);

      expect(result.format, 'text');
      expect(result.lines.first.name, 'Ghave, Guru of Spores');
      expect(result.lines.first.setCode, '2x2');
      expect(result.lines.first.collectorNumber, '216');
      expect(result.lines.last.name, "Ambition's Cost");
    });

    test('reads plain names and the usual markers', () {
      const text =
          'Deck\n'
          '1 Abzan Charm\n'
          '4x Lightning Bolt\n'
          'Command Tower\n'
          '\n'
          'Sideboard\n'
          '1 Sol Ring (CMM) 410 *F*\n'
          '1x Sol Ring (cmm) 410 *E* [Ramp]\n';

      final lines = parseCardList(text).lines;

      expect(lines.map((l) => l.name), [
        'Abzan Charm',
        'Lightning Bolt',
        'Command Tower',
        'Sol Ring',
        'Sol Ring',
      ]);
      expect(lines[1].quantity, 4);
      expect(lines[2].quantity, 1);
      expect(lines[3].finish, CardFinish.foil);
      expect(lines[4].finish, CardFinish.etched);
      expect(lines[4].setCode, 'cmm');
      expect(lines[4].collectorNumber, '410');
    });
  });

  group('set and collector number lines', () {
    test('read set, number, language and finish', () {
      final lines = parseCardList(
        '1 msc 211 de foil\n'
        'cmm 410\n'
        '3x 2X2 216 E\n'
        'sld 136a foil ja\n',
      ).lines;

      expect(lines.map((l) => l.setCode), ['msc', 'cmm', '2x2', 'sld']);
      expect(lines.map((l) => l.collectorNumber), [
        '211',
        '410',
        '216',
        '136a',
      ]);
      expect(lines.map((l) => l.quantity), [1, 1, 3, 1]);
      expect(lines.map((l) => l.language), ['de', null, null, 'ja']);
      expect(lines.map((l) => l.finish), [
        CardFinish.foil,
        CardFinish.nonfoil,
        CardFinish.etched,
        CardFinish.foil,
      ]);
      expect(lines.every((l) => l.name == null), isTrue);
    });

    test('lines with other words stay card names', () {
      final lines = parseCardList(
        '1 Sol Ring\n'
        'Gond Gate\n'
        '1 Sol Ring (CMM) 410 *F*\n',
      ).lines;

      expect(lines.map((l) => l.name), ['Sol Ring', 'Gond Gate', 'Sol Ring']);
      expect(lines.last.collectorNumber, '410');
    });
  });

  group('matching', () {
    late AppDatabase db;
    late CardImportResolver resolver;

    setUpAll(() {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    });

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      resolver = CardImportResolver(db);
      Future<void> card(
        String id,
        String name,
        String set,
        String number,
        String released, {
        String lang = 'en',
        String? printedName,
        bool promo = false,
        String setType = 'expansion',
      }) {
        return db
            .into(db.scryfallCards)
            .insert(
              ScryfallCardsCompanion.insert(
                scryfallId: id,
                layout: 'normal',
                name: name,
                printedName: Value(printedName),
                setId: set,
                setCode: set,
                setName: set.toUpperCase(),
                setType: setType,
                setUri: '',
                setSearchUri: '',
                scryfallSetUri: '',
                collectorNumber: number,
                lang: lang,
                rarity: 'common',
                releasedAt: released,
                scryfallUri: '',
                uri: '',
                rulingsUri: '',
                printsSearchUri: '',
                typeLine: 'Artifact',
                cmc: 1,
                promo: Value(promo),
              ),
            );
      }

      await card('ring-old', 'Sol Ring', 'lea', '270', '1993-08-05');
      await card('ring-new', 'Sol Ring', 'cmm', '410', '2023-08-04');
      await card(
        'ring-promo',
        'Sol Ring',
        'pcmm',
        '1',
        '2024-01-01',
        promo: true,
      );
      await card(
        'ring-de',
        'Sol Ring',
        'cmm',
        '410',
        '2023-08-04',
        lang: 'de',
        printedName: 'Solring',
      );
      await card(
        'delver-sld',
        'Delver of Secrets // Insectile Aberration',
        'sld',
        '2367',
        '2025-01-01',
        setType: 'box',
      );
      await card(
        'delver',
        'Delver of Secrets // Insectile Aberration',
        'isd',
        '51',
        '2011-09-30',
      );
    });

    tearDown(() => db.close());

    Future<ResolvedImportLine> match(String text) async =>
        (await resolver.resolve(parseCardList(text).lines)).single;

    test('set and collector number are certain', () async {
      final result = await match('1 Sol Ring (LEA) 270');
      expect(result.card?.scryfallId, 'ring-old');
      expect(result.isCertain, isTrue);
    });

    test('name only takes the newest normal printing, with a hint', () async {
      final result = await match('2 Sol Ring');
      expect(result.card?.scryfallId, 'ring-new');
      expect(result.notes, {ImportNote.ambiguousPrinting});
    });

    test('the requested language is used if it exists', () async {
      const csv =
          'Count,Name,Edition,Collector Number,Language\n'
          '1,Sol Ring,cmm,410,German\n';
      final result = await match(csv);
      expect(result.card?.scryfallId, 'ring-de');
      expect(result.isCertain, isTrue);
    });

    test('unknown languages fall back to English, with a hint', () async {
      const csv =
          'Count,Name,Edition,Collector Number,Language\n'
          '1,Sol Ring,cmm,410,Japanese\n';
      final result = await match(csv);
      expect(result.card?.scryfallId, 'ring-new');
      expect(result.notes, {ImportNote.languageFallback});
    });

    test('finds double-faced cards by their front name', () async {
      final result = await match('1 Delver of Secrets (ISD) 51');
      expect(result.card?.scryfallId, 'delver');
      expect(result.isCertain, isTrue);
    });

    test('name only prefers regular sets over special products', () async {
      // The Secret Lair printing is newer, but the regular one is taken.
      final result = await match('1 Delver of Secrets');
      expect(result.card?.scryfallId, 'delver');
      expect(result.notes, {ImportNote.ambiguousPrinting});
    });

    test('finds cards by their printed (German) name', () async {
      final result = await match('1 Solring');
      expect(result.card?.scryfallId, 'ring-de');
    });

    test('set and number lines are certain, in the given language', () async {
      expect((await match('cmm 410')).card?.scryfallId, 'ring-new');
      final german = await match('2 cmm 410 de');
      expect(german.card?.scryfallId, 'ring-de');
      expect(german.isCertain, isTrue);
    });

    test('reports cards that are not there', () async {
      final result = await match('1 Black Lotus');
      expect(result.card, isNull);
      expect(result.notes, {ImportNote.notFound});
      expect(result.willImport, isFalse);
    });
  });
}
