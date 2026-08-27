import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app_aethervault/services/card_database/scryfall_data_parser.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async {
        if (call.method == 'getTemporaryDirectory') {
          return Directory.systemTemp.path;
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      null,
    );
  });

  const exampleCard = {
    'id': 'card-1',
    'oracle_id': 'oracle-1',
    'name': 'Test Creature',
    'layout': 'normal',
    'set_id': 'set-1',
    'set': 'tst',
    'set_name': 'Test Set',
    'set_type': 'expansion',
    'collector_number': '1',
    'lang': 'en',
    'rarity': 'rare',
    'released_at': '2026-01-01',
    'type_line': 'Creature — Test',
    'mana_cost': '{2}{G}',
    'oracle_text': 'Test ability.',
    'colors': ['G'],
    'color_identity': ['G'],
    'produced_mana': ['G'],
    'cmc': 3,
    'power': '2',
    'toughness': '2',
    'keywords': ['Test'],
    'highres_image': true,
    'image_status': 'highres_scan',
    'image_updated_at': '2026-01-01T00:00:00Z',
    'border_color': 'black',
    'frame': '2015',
    'artist': 'Test Artist',
    'legalities': {
      'commander': 'legal',
      'modern': 'not_legal',
    },
    'prices': {
      'eur': '1.50',
      'usd': '2.00',
    },
    'image_uris': {
    'small': 'small.jpg',
    'normal': 'normal.jpg',
    'large': 'large.jpg',
    },
    'set_uri': 'https://scryfall.com/',
    'set_search_uri': 'https://scryfall.com/',
    'scryfall_set_uri': 'https://scryfall.com/',
    'scryfall_uri': 'https://scryfall.com/',
    'uri': 'https://scryfall.com/',
    'rulings_uri': 'https://scryfall.com/',
    'prints_search_uri': 'https://scryfall.com/',
  };
  group('ScryfallDataParser', () {
    group('parse chunk', () {
      test('parses an English card and maps its data', () {
        final result = ScryfallDataParser.parseChunk([
          jsonEncode(exampleCard),
        ], ['en']);

        expect(result.parsedCount, 1);
        expect(result.cards, hasLength(1));
        expect(result.faces, isEmpty);

        final card = result.cards.single;

        expect(card.scryfallId.value, 'card-1');
        expect(card.oracleId.value, 'oracle-1');
        expect(card.name.value, 'Test Creature');
        expect(card.manaCost.value, '{2}{G}');
        expect(card.typeLine.value, 'Creature — Test');
        expect(card.oracleText.value, 'Test ability.');
        expect(card.cmc.value, 3);
        expect(card.power.value, '2');
        expect(card.toughness.value, '2');
        expect(card.rarity.value, 'rare');
        expect(card.setCode.value, 'tst');
        expect(card.lang.value, 'en');
        expect(card.colorMask.value, 16);
        expect(card.colorIdentityMask.value, 16);
        expect(card.rarityValue.value, 3);
        expect(card.imageNormal.value, 'normal.jpg');
        expect(card.artist.value, 'Test Artist');
        expect(card.legalCommander.value, 'legal');
        expect(card.legalModern.value, 'not_legal');
        expect(card.pricesEur.value, '1.50');
        expect(card.pricesUsd.value, '2.00');
        expect(card.hasCardFaces.value, false);
      });

      test('filters cards by language', () {
        var exampleCard1 = Map<String, dynamic>.from(exampleCard);
        exampleCard1['id'] = 'en-card';
        exampleCard1['lang'] = 'en';
        var exampleCard2 = Map<String, dynamic>.from(exampleCard);
        exampleCard2['id'] = 'de-card';
        exampleCard2['lang'] = 'de';
        final lines = [
          jsonEncode(exampleCard1),
          jsonEncode(exampleCard2),
        ];

        final result = ScryfallDataParser.parseChunk(lines, ['en']);

        expect(result.parsedCount, 1);
        expect(result.cards.single.scryfallId.value, 'en-card');
      });

      test('filters digital cards', () {
        var exampleCard1 = Map<String, dynamic>.from(exampleCard);
        exampleCard1['id'] = 'paper-card';
        exampleCard1['digital'] = false;
        var exampleCard2 = Map<String, dynamic>.from(exampleCard);
        exampleCard2['id'] = 'digital-card';
        exampleCard2['digital'] = true;
        final lines = [
          jsonEncode(exampleCard1),
          jsonEncode(exampleCard2),
        ];

        final result = ScryfallDataParser.parseChunk(lines, ['en']);

        expect(result.parsedCount, 1);
        expect(result.cards.single.scryfallId.value, 'paper-card');
      });

      test('filters digital cards', () {
        var exampleCard1 = Map<String, dynamic>.from(exampleCard);
        exampleCard1['id'] = 'paper-card';
        exampleCard1['digital'] = false;
        var exampleCard2 = Map<String, dynamic>.from(exampleCard);
        exampleCard2['id'] = 'digital-card';
        exampleCard2['digital'] = true;
        final lines = [
          jsonEncode(exampleCard1),
          jsonEncode(exampleCard2),
        ];

        final result = ScryfallDataParser.parseChunk(lines, ['en']);

        expect(result.parsedCount, 1);
        expect(result.cards.single.scryfallId.value, 'paper-card');
      });

      test('parses a double-faced card and creates its faces', () {
        var transformCard = Map<String, dynamic>.from(exampleCard);
        transformCard['id'] = 'transform-1';
        transformCard['layout'] = 'transform';
        transformCard['name'] = 'Front // Back';
        transformCard['card_faces'] = [
          {
            'name': 'Front',
            'mana_cost': '{2}{G}',
            'type_line': 'Creature — Front',
            'oracle_text': 'Front ability.',
            'colors': ['G'],
            'power': '2',
            'toughness': '2',
          },
          {
            'name': 'Back',
            'mana_cost': '',
            'type_line': 'Creature — Back',
            'oracle_text': 'Back ability.',
            'colors': ['G'],
            'power': '3',
            'toughness': '3',
          },
        ];
        final result = ScryfallDataParser.parseChunk([
          jsonEncode(transformCard),
        ], ['en']);

        final card = result.cards.single;

        expect(card.hasCardFaces.value, true);
        expect(result.faces, hasLength(2));

        final frontFace = result.faces.firstWhere((f) => f.cardId.value == 'transform-1' && f.name.value == 'Front');
        final backFace = result.faces.firstWhere((f) => f.cardId.value == 'transform-1' && f.name.value == 'Back');
        expect(frontFace.manaCost.value, '{2}{G}');
        expect(frontFace.typeLine.value, 'Creature — Front');
        expect(frontFace.oracleText.value, 'Front ability.');
        expect(frontFace.power.value, '2');
        expect(frontFace.toughness.value, '2');
        expect(backFace.manaCost.value, '');
        expect(backFace.typeLine.value, 'Creature — Back');
        expect(backFace.oracleText.value, 'Back ability.');
        expect(backFace.power.value, '3');
        expect(backFace.toughness.value, '3');
      });

      test('calculates color and rarity masks', () {
        var exampleCardColor = Map<String, dynamic>.from(exampleCard);
        exampleCardColor['colors'] = ['W', 'U', 'B', 'R', 'G'];
        exampleCardColor['color_identity'] = ['W', 'U', 'B', 'R', 'G'];
        exampleCardColor['rarity'] = 'mythic';
        exampleCardColor['id'] = 'color-card';
        final result = ScryfallDataParser.parseChunk([
          jsonEncode(exampleCardColor),
        ], ['en']);

        final card = result.cards.single;

        expect(card.colorMask.value, 31);
        expect(card.colorIdentityMask.value, 31);
        expect(card.rarityValue.value, 4);
      });

      test('throws when a line is not a JSON object', () {
        expect(
          () => ScryfallDataParser.parseChunk(['[]'], ['en']),
          throwsFormatException,
        );
      });

      test('throws when a required card field is missing', () {
        expect(
          () => ScryfallDataParser.parseChunk([
            jsonEncode({
              'name': 'Incomplete Card',
              'layout': 'normal',
              'lang': 'en',
            }),
          ], ['en']),
          throwsFormatException,
        );
      });
    });

    group('tag parsing', () {
      test('maps Oracle Tag data', () {
        final tag = ScryfallDataParser.mapTag({
          'id': 'tag-1',
          'label': 'Card Draw',
          'slug': 'draw',
          'description': 'Draw cards.',
          'type': 'oracle',
          'parent_ids': ['parent-1'],
          'child_ids': ['child-1'],
          'aliases': ['card-draw'],
          'taggings': [
            {'oracle_id': 'oracle-1'},
            {'oracle_id': 'oracle-2'},
          ],
        });

        expect(tag.scryfallId.value, 'tag-1');
        expect(tag.label.value, 'Card Draw');
        expect(tag.slug.value, 'draw');
        expect(tag.description.value, 'Draw cards.');
        expect(tag.type.value, 'oracle');
        expect(tag.taggedJson.value, ['oracle-1', 'oracle-2']);
      });

      test('uses illustration IDs for illustration tags', () {
        final tag = ScryfallDataParser.mapTag({
          'id': 'tag-2',
          'label': 'Dragon',
          'slug': 'dragon',
          'type': 'illustration',
          'taggings': [
            {'illustration_id': 'illustration-1'},
            {'illustration_id': 'illustration-2'},
          ],
        });

        expect(tag.taggedJson.value, ['illustration-1', 'illustration-2']);
      });
    });

    group('progress', () {
      test('dispose closes the progress stream', () async {
        final parser = ScryfallDataParser();

        final done = expectLater(
          parser.progressStream,
          emitsDone,
        );

        parser.dispose();

        await done;
      });
    });
  });
}
