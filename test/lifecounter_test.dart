import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app_aethervault/services/life_counter/lifecounter_model.dart';
import 'package:flutter_app_aethervault/services/life_counter/lifecounter_storage.dart';
import 'package:flutter_app_aethervault/services/app_preferences_storage.dart';

void main() {
  group('LifecounterGame', () {
    test('creates default values for optional fields', () {
      final game = LifecounterGame(
        startLife: 40,
        playerCount: 3,
        currentLives: [40, 40, 40],
      );

      expect(game.commanderTax, [0, 0, 0]);
      expect(game.partnerEnabled, [false, false, false]);
      expect(game.partnerTax, [0, 0, 0]);
      expect(game.active, isTrue);

      expect(game.commanderDamage.length, 3);
      for (final row in game.commanderDamage) {
        expect(row.length, 3);
        for (final slots in row) {
          expect(slots, [0]);
        }
      }
    });

    test('serializes all fields to JSON', () {
      final game = LifecounterGame(
        startLife: 40,
        playerCount: 2,
        currentLives: [35, 27],
        commanderTax: [2, 4],
        commanderDamage: [
          [
            [0, 5],
            [7],
          ],
          [
            [3, 0],
            [0],
          ],
        ],
        partnerEnabled: [true, false],
        partnerTax: [2, 0],
        active: false,
        name: 'Test Game',
      );

      final json = game.toJson();

      expect(json['startLife'], 40);
      expect(json['playerCount'], 2);
      expect(json['currentLives'], [35, 27]);
      expect(json['commanderTax'], [2, 4]);
      expect(json['commanderDamage'], [
        [
          [0, 5],
          [7],
        ],
        [
          [3, 0],
          [0],
        ],
      ]);
      expect(json['partnerEnabled'], [true, false]);
      expect(json['partnerTax'], [2, 0]);
      expect(json['active'], false);
      expect(json['name'], 'Test Game');
    });

    test('encodes and decodes a game without changing its state', () {
      final game = LifecounterGame(
        startLife: 40,
        playerCount: 2,
        currentLives: [35, 27],
        commanderTax: [2, 4],
        commanderDamage: [
          [
            [0, 5],
            [7],
          ],
          [
            [3, 0],
            [0],
          ],
        ],
        partnerEnabled: [true, false],
        partnerTax: [2, 0],
        active: false,
        name: 'Test Game',
      );

      final decoded = LifecounterGame.decode(game.encode());

      expect(decoded, isNotNull);
      expect(decoded!.toJson(), game.toJson());
    });

    test('decode returns null for null data', () {
      expect(LifecounterGame.decode(null), isNull);
    });

    test('decode returns null for invalid JSON', () {
      expect(LifecounterGame.decode('{invalid json}'), isNull);
    });

    test('decode returns null when validation fails', () {
      final invalid = {
        'startLife': 0,
        'playerCount': 2,
        'currentLives': [20, 20],
      };

      expect(LifecounterGame.decode(jsonEncode(invalid)), isNull);
    });

    test('fills missing current lives with start life', () {
      final game = LifecounterGame.fromJson({
        'startLife': 40,
        'playerCount': 3,
        'currentLives': [25],
      });

      expect(game.currentLives, [25, 40, 40]);
    });

    test('truncates current lives when there are too many players', () {
      final game = LifecounterGame.fromJson({
        'startLife': 40,
        'playerCount': 2,
        'currentLives': [25, 30, 35],
      });

      expect(game.currentLives, [25, 30]);
    });

    test('normalizes commander tax to player count', () {
      final shorter = LifecounterGame.fromJson({
        'startLife': 40,
        'playerCount': 3,
        'currentLives': [40, 40, 40],
        'commanderTax': [2],
      });
      expect(shorter.commanderTax, [2, 0, 0]);

      final longer = LifecounterGame.fromJson({
        'startLife': 40,
        'playerCount': 2,
        'currentLives': [40, 40],
        'commanderTax': [2, 4, 6],
      });
      expect(longer.commanderTax, [2, 4]);
    });

    test('normalizes partner settings to player count', () {
      final game = LifecounterGame.fromJson({
        'startLife': 40,
        'playerCount': 3,
        'currentLives': [40, 40, 40],
        'partnerEnabled': [true],
        'partnerTax': [3],
      });

      expect(game.partnerEnabled, [true, false, false]);
      expect(game.partnerTax, [3, 0, 0]);
    });

    test('adds a second commander slot for partners', () {
      final game = LifecounterGame.fromJson({
        'startLife': 40,
        'playerCount': 2,
        'currentLives': [40, 40],
        'partnerEnabled': [true, false],
        'commanderDamage': [
          [
            [5],
            [2],
          ],
          [
            [3],
            [1],
          ],
        ],
      });

      expect(game.commanderDamage[0][0], [5, 0]);
      expect(game.commanderDamage[0][1], [2]);
      expect(game.commanderDamage[1][0], [3, 0]);
      expect(game.commanderDamage[1][1], [1]);
    });

    test('preserves extra commander slots when partners are disabled', () {
      final game = LifecounterGame.fromJson({
        'startLife': 40,
        'playerCount': 2,
        'currentLives': [40, 40],
        'partnerEnabled': [false, false],
        'commanderDamage': [
          [
            [5, 12],
            [2],
          ],
          [
            [3],
            [1],
          ],
        ],
      });

      expect(game.commanderDamage[0][0], [5, 12]);
    });

    test('validate accepts a valid game', () {
      final game = LifecounterGame(
        startLife: 40,
        playerCount: 2,
        currentLives: [40, 40],
      );

      expect(game.validate, returnsNormally);
    });

    test('validate rejects invalid player count', () {
      final game = LifecounterGame(
        startLife: 40,
        playerCount: 0,
        currentLives: [],
      );

      expect(game.validate, throwsFormatException);
    });

    test('validate rejects invalid start life', () {
      final game = LifecounterGame(
        startLife: 0,
        playerCount: 1,
        currentLives: [0],
      );

      expect(game.validate, throwsFormatException);
    });

    test('validate rejects lists with incorrect length', () {
      final game = LifecounterGame(
        startLife: 40,
        playerCount: 2,
        currentLives: [40],
      );

      expect(game.validate, throwsFormatException);
    });

    test('validate rejects insufficient commander damage slots', () {
      final game = LifecounterGame(
        startLife: 40,
        playerCount: 2,
        currentLives: [40, 40],
        partnerEnabled: [true, false],
        commanderDamage: [
          [
            [5],
            [0],
          ],
          [
            [0],
            [0],
          ],
        ],
      );

      expect(game.validate, throwsFormatException);
    });

    test('validate allows extra commander damage slots', () {
      final game = LifecounterGame(
        startLife: 40,
        playerCount: 2,
        currentLives: [40, 40],
        commanderDamage: [
          [
            [5, 12],
            [0],
          ],
          [
            [0],
            [0],
          ],
        ],
      );

      expect(game.validate, returnsNormally);
    });

    test('normalizeCommanderDamageSlots adds missing players and slots', () {
      final game = LifecounterGame(
        startLife: 40,
        playerCount: 3,
        currentLives: [40, 40, 40],
        partnerEnabled: [true, false, true],
        commanderDamage: [
          [
            [5],
          ],
        ],
      );

      game.normalizeCommanderDamageSlots();

      expect(game.commanderDamage.length, 3);
      expect(game.commanderDamage[0].length, 3);
      expect(game.commanderDamage[0][0], [5, 0]);
      expect(game.commanderDamage[0][1], [0]);
      expect(game.commanderDamage[0][2], [0, 0]);
      expect(game.commanderDamage[1].length, 3);
      expect(game.commanderDamage[2].length, 3);
    });

    test('normalizeCommanderDamageSlots truncates excess targets', () {
      final game = LifecounterGame(
        startLife: 40,
        playerCount: 2,
        currentLives: [40, 40],
        commanderDamage: [
          [
            [5],
            [3],
            [7],
          ],
          [
            [2],
            [1],
            [9],
          ],
          [
            [8],
            [6],
            [4],
          ],
        ],
      );

      game.normalizeCommanderDamageSlots();

      expect(game.commanderDamage.length, 2);
      expect(game.commanderDamage[0].length, 2);
      expect(game.commanderDamage[1].length, 2);
    });

    test('normalizeCommanderDamageSlots preserves extra commander slots', () {
      final game = LifecounterGame(
        startLife: 40,
        playerCount: 2,
        currentLives: [40, 40],
        partnerEnabled: [false, false],
        commanderDamage: [
          [
            [5, 12],
            [3, 8, 1],
          ],
          [
            [2],
            [1],
          ],
        ],
      );

      game.normalizeCommanderDamageSlots();

      expect(game.commanderDamage[0][0], [5, 12]);
      expect(game.commanderDamage[0][1], [3, 8, 1]);
    });
  });

  group('LifecounterStorage', () {
    late FakeAppPreferencesStorage prefs;
    late LifecounterStorage storage;

    setUp(() {
      prefs = FakeAppPreferencesStorage();
      storage = LifecounterStorage(prefs: prefs);
    });

    test('saves a game', () async {
      final game = LifecounterGame(
        startLife: 40,
        playerCount: 2,
        currentLives: [35, 27],
        name: 'Test Game',
      );

      await storage.saveGame(game);

      expect(prefs.savedGame, game.encode());
    });

    test('loads a saved game', () async {
      final game = LifecounterGame(
        startLife: 40,
        playerCount: 2,
        currentLives: [35, 27],
        name: 'Test Game',
      );

      prefs.savedGame = game.encode();

      final loaded = await storage.loadGame();

      expect(loaded, isNotNull);
      expect(loaded!.toJson(), game.toJson());
    });

    test('returns null when no game is saved', () async {
      expect(await storage.loadGame(), isNull);
    });

    test('returns null for invalid saved game data', () async {
      prefs.savedGame = '{invalid json}';

      expect(await storage.loadGame(), isNull);
    });

    test('clears the saved game', () async {
      prefs.savedGame = 'saved-game';

      await storage.clearGame();

      expect(prefs.savedGame, isNull);
      expect(prefs.clearGameCalled, isTrue);
    });

    test('throws LifecounterStorageException when saving fails', () async {
      prefs.throwOnSave = true;

      final game = LifecounterGame(
        startLife: 40,
        playerCount: 2,
        currentLives: [40, 40],
      );

      expect(
        () => storage.saveGame(game),
        throwsA(isA<LifecounterStorageException>()),
      );
    });

    test('returns null when loading fails', () async {
      prefs.throwOnLoad = true;

      expect(await storage.loadGame(), isNull);
    });

    test('throws LifecounterStorageException when clearing fails', () async {
      prefs.throwOnClear = true;

      expect(
        () => storage.clearGame(),
        throwsA(isA<LifecounterStorageException>()),
      );
    });
  });

}

class FakeAppPreferencesStorage extends AppPreferencesStorage {
  String? savedGame;
  bool clearGameCalled = false;

  bool throwOnSave = false;
  bool throwOnLoad = false;
  bool throwOnClear = false;

  @override
  Future<void> saveLifecounterGame(String json) async {
    if (throwOnSave) {
      throw Exception('Save failed');
    }
    savedGame = json;
  }

  @override
  Future<String?> loadLifecounterGame() async {
    if (throwOnLoad) {
      throw Exception('Load failed');
    }
    return savedGame;
  }

  @override
  Future<void> clearLifecounterGame() async {
    if (throwOnClear) {
      throw Exception('Clear failed');
    }
    clearGameCalled = true;
    savedGame = null;
  }
}
