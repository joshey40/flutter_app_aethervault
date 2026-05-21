import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_app_aethervault/services/scryfall/download_service.dart';

void main() {
  test('downloadAllCards writes file and returns File', () async {
    final now = DateTime.now().toUtc();
    final downloadPath = 'https://data.scryfall.io/all-cards/all-cards-test.json';
    final cardsJson = jsonEncode({"cards": [
      {"id": "1", "name": "Test Card"}
    ]});
    final gzipped = GZipCodec().encode(utf8.encode(cardsJson));

    final bulkJson = jsonEncode({
      "object": "list",
      "has_more": false,
      "data": [
        {
          "object": "bulk_data",
          "id": "abc",
          "type": "all_cards",
          "updated_at": now.toIso8601String(),
          "uri": "https://api.scryfall.com/bulk-data/abc",
          "name": "All Cards",
          "size": gzipped.length,
          "download_uri": downloadPath,
          "content_type": "application/json",
          "content_encoding": "gzip"
        }
      ]
    });

    final mock = MockClient((http.Request request) async {
      final url = request.url.toString();
      if (url == 'https://api.scryfall.com/bulk-data') {
        return http.Response(bulkJson, 200, headers: {'content-type': 'application/json'});
      }
      if (url == downloadPath) {
        return http.Response.bytes(gzipped, 200, headers: {'content-encoding': 'gzip'});
      }
      return http.Response('not found', 404);
    });

    SharedPreferences.setMockInitialValues({});
    final temp = await Directory.systemTemp.createTemp('scryfall_test');
    try {
        final svc = DownloadService.instance;
        svc.setTestStorageDirectory(temp);
      svc.setHttpClientForTesting(mock);

      final progress = <int>[];
      final file = await svc.downloadAllCards(onProgress: (got, total) {
        progress.add(got);
      });

      expect(await file.exists(), isTrue);
      final content = await file.readAsString();
      expect(jsonDecode(content)['cards'][0]['name'], 'Test Card');
      expect(progress.isNotEmpty, isTrue);
    } finally {
      await temp.delete(recursive: true);
    }
  });

  test('getBulkMetadata returns correct entry', () async {
    final now = DateTime.now().toUtc();
    final bulkJson = jsonEncode({
      "object": "list",
      "has_more": false,
      "data": [
        {
          "object": "bulk_data",
          "id": "meta",
          "type": "all_cards",
          "updated_at": now.toIso8601String(),
          "download_uri": "https://data.scryfall.io/all-cards/all.json",
          "size": 123,
          "content_type": "application/json",
          "content_encoding": "gzip"
        }
      ]
    });

    final mock = MockClient((http.Request request) async {
      if (request.url.toString() == 'https://api.scryfall.com/bulk-data') {
        return http.Response(bulkJson, 200, headers: {'content-type': 'application/json'});
      }
      return http.Response('not found', 404);
    });

    final svc = DownloadService.instance;
    svc.setHttpClientForTesting(mock);

    final meta = await svc.getBulkMetadata();
    expect(meta['type'], 'all_cards');
    expect(meta['download_uri'], 'https://data.scryfall.io/all-cards/all.json');
  });

  test('isLocalFileAvailable and isAllCardsAvailable behave correctly', () async {
    final now = DateTime.now().toUtc();
    final downloadPath = 'https://data.scryfall.io/all-cards/all-cards-test.json';
    final cardsJson = jsonEncode({"cards": [{"id": "1", "name": "Test Card"}]});
    final gzipped = GZipCodec().encode(utf8.encode(cardsJson));

    final bulkJson = jsonEncode({
      "object": "list",
      "has_more": false,
      "data": [
        {
          "object": "bulk_data",
          "id": "abc",
          "type": "all_cards",
          "updated_at": now.toIso8601String(),
          "download_uri": downloadPath,
          "size": gzipped.length,
          "content_type": "application/json",
          "content_encoding": "gzip"
        }
      ]
    });

    final mock = MockClient((http.Request request) async {
      final url = request.url.toString();
      if (url == 'https://api.scryfall.com/bulk-data') {
        return http.Response(bulkJson, 200, headers: {'content-type': 'application/json'});
      }
      if (url == downloadPath) {
        return http.Response.bytes(gzipped, 200, headers: {'content-encoding': 'gzip'});
      }
      return http.Response('not found', 404);
    });

    final temp = await Directory.systemTemp.createTemp('scryfall_test');
    try {
      final svc = DownloadService.instance;
      svc.setTestStorageDirectory(temp);
      svc.setHttpClientForTesting(mock);

      // Initially no file
      expect(await svc.isLocalFileAvailable(), isFalse);
      expect(await svc.isAllCardsAvailable(), isFalse);

      // Download file (will have updated_at == now)
      final file = await svc.downloadAllCards(onProgress: null);
      expect(await file.exists(), isTrue);

      // File should now be available
      expect(await svc.isLocalFileAvailable(), isTrue);

      // If we set the file's modified time to before remote updated_at, it's not up to date
      final oldTime = now.subtract(const Duration(days: 1));
      await file.setLastModified(oldTime);
      expect(await svc.isAllCardsAvailable(), isFalse);

      // Now set modified time to after remote -> should be up to date
      final newTime = now.add(const Duration(minutes: 10));
      await file.setLastModified(newTime);
      expect(await svc.isAllCardsAvailable(), isTrue);
    } finally {
      await temp.delete(recursive: true);
    }
  });
}
