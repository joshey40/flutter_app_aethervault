import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_app_aethervault/services/app_preferences_storage.dart';

void main() {
  late AppPreferencesStorage storage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage = AppPreferencesStorage();
  });

  group('Settings', () {
    test('loads dark theme by default', () async {
      expect(await storage.loadThemeMode(), ThemeMode.dark);
    });

    test('loads saved light theme', () async {
      SharedPreferences.setMockInitialValues({
        'settings.themeMode': 'light',
      });

      expect(await storage.loadThemeMode(), ThemeMode.light);
    });

    test('loads saved system theme', () async {
      SharedPreferences.setMockInitialValues({
        'settings.themeMode': 'system',
      });

      expect(await storage.loadThemeMode(), ThemeMode.system);
    });

    test('saves theme mode', () async {
      await storage.saveThemeMode(ThemeMode.light);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('settings.themeMode'), 'light');
    });

    test('loads English locale by default', () async {
      expect(await storage.loadLocale(), const Locale('en'));
    });

    test('loads saved German locale', () async {
      SharedPreferences.setMockInitialValues({
        'settings.locale': 'de',
      });

      expect(await storage.loadLocale(), const Locale('de'));
    });

    test('saves locale', () async {
      await storage.saveLocale(const Locale('de'));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('settings.locale'), 'de');
    });
  });

  group('Lifecounter', () {
    test('saves and loads a lifecounter game', () async {
      const json = '{"playerCount":2}';

      await storage.saveLifecounterGame(json);

      expect(await storage.loadLifecounterGame(), json);
    });

    test('returns null when no lifecounter game is saved', () async {
      expect(await storage.loadLifecounterGame(), isNull);
    });

    test('clears the lifecounter game', () async {
      await storage.saveLifecounterGame('test');

      await storage.clearLifecounterGame();

      expect(await storage.loadLifecounterGame(), isNull);
    });
  });

  group('Scryfall data', () {
    test('saves and loads bulk data items', () async {
      const json = '[{"type":"default_cards"}]';

      await storage.saveScryfallBulkDataItems(json);

      expect(await storage.loadScryfallBulkDataItems(), json);
    });

    test('returns null when no bulk data items are saved', () async {
      expect(await storage.loadScryfallBulkDataItems(), isNull);
    });

    test('saves and loads bulk data metadata', () async {
      const json = '{"updated_at":"2026-01-01"}';

      await storage.saveScryfallBulkDataMetadata(
        'default_cards',
        json,
      );

      expect(
        await storage.loadScryfallBulkDataMetadata(
          'default_cards',
        ),
        json,
      );
    });

    test('metadata is stored separately by bulk data type', () async {
      await storage.saveScryfallBulkDataMetadata(
        'default_cards',
        'default',
      );

      await storage.saveScryfallBulkDataMetadata(
        'oracle_cards',
        'oracle',
      );

      expect(
        await storage.loadScryfallBulkDataMetadata(
          'default_cards',
        ),
        'default',
      );

      expect(
        await storage.loadScryfallBulkDataMetadata(
          'oracle_cards',
        ),
        'oracle',
      );
    });

    test('removes bulk data metadata', () async {
      await storage.saveScryfallBulkDataMetadata(
        'default_cards',
        'metadata',
      );

      await storage.removeScryfallBulkDataMetadata(
        'default_cards',
      );

      expect(
        await storage.loadScryfallBulkDataMetadata(
          'default_cards',
        ),
        isNull,
      );
    });
  });
}