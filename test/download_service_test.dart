import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_app_aethervault/services/scryfall/bulk_data_type.dart';
import 'package:flutter_app_aethervault/services/scryfall/download_service.dart';

void main() {
  test('downloadAllCards writes file and returns File', () async {
    final now = DateTime.now().toUtc();
    final downloadPath = 'https://data.scryfall.io/all-cards/all-cards-test.json';
    final cardsJson = jsonEncode({
      'cards': [
        {'id': '1', 'name': 'Test Card'},
      ],
    });
    final gzipped = GZipCodec().encode(utf8.encode(cardsJson));

    final bulkJson = _bulkResponseJson(
      updatedAt: now,
      type: ScryfallBulkDataType.allCards,
      downloadUri: downloadPath,
      size: gzipped.length,
    );

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
      final service = DownloadService.instance;
      service.setTestStorageDirectory(temp);
      service.setHttpClientForTesting(mock);

      final progress = <int>[];
      final file = await service.downloadAllCards(onProgress: (got, total) {
        progress.add(got);
      });

      expect(await file.exists(), isTrue);
      final content = await file.readAsString();
      expect(jsonDecode(content)['cards'][0]['name'], 'Test Card');
      expect(file.path.endsWith(ScryfallBulkDataType.allCards.localFileName), isTrue);
      expect(progress.isNotEmpty, isTrue);
    } finally {
      await temp.delete(recursive: true);
    }
  });

  test('downloadDefaultCards writes a separate file', () async {
    final now = DateTime.now().toUtc();
    final downloadPath = 'https://data.scryfall.io/default-cards/default-cards-test.json';
    final cardsJson = jsonEncode([
      {'id': '1', 'name': 'Default Test Card'},
    ]);
    final gzipped = GZipCodec().encode(utf8.encode(cardsJson));

    final bulkJson = _bulkResponseJson(
      updatedAt: now,
      type: ScryfallBulkDataType.defaultCards,
      downloadUri: downloadPath,
      size: gzipped.length,
    );

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
      final service = DownloadService.instance;
      service.setTestStorageDirectory(temp);
      service.setHttpClientForTesting(mock);

      final file = await service.downloadDefaultCards();

      expect(await file.exists(), isTrue);
      expect(file.path.endsWith(ScryfallBulkDataType.defaultCards.localFileName), isTrue);
      expect(jsonDecode(await file.readAsString())[0]['name'], 'Default Test Card');
    } finally {
      await temp.delete(recursive: true);
    }
  });

  test('getBulkMetadata returns typed metadata', () async {
    final now = DateTime.now().toUtc();
    final bulkJson = _bulkResponseJson(
      updatedAt: now,
      type: ScryfallBulkDataType.defaultCards,
      downloadUri: 'https://data.scryfall.io/default-cards/default.json',
      size: 123,
    );

    final mock = MockClient((http.Request request) async {
      if (request.url.toString() == 'https://api.scryfall.com/bulk-data') {
        return http.Response(bulkJson, 200, headers: {'content-type': 'application/json'});
      }
      return http.Response('not found', 404);
    });

    final service = DownloadService.instance;
    service.setHttpClientForTesting(mock);

    final metadata = await service.getBulkMetadata(type: ScryfallBulkDataType.defaultCards);
    expect(metadata.type, ScryfallBulkDataType.defaultCards);
    expect(metadata.downloadUri.toString(), 'https://data.scryfall.io/default-cards/default.json');
    expect(metadata.size, 123);
  });

  test('isLocalFileAvailable and isAllCardsAvailable behave correctly', () async {
    final now = DateTime.now().toUtc();
    final downloadPath = 'https://data.scryfall.io/all-cards/all-cards-test.json';
    final cardsJson = jsonEncode({
      'cards': [
        {'id': '1', 'name': 'Test Card'},
      ],
    });
    final gzipped = GZipCodec().encode(utf8.encode(cardsJson));

    final bulkJson = _bulkResponseJson(
      updatedAt: now,
      type: ScryfallBulkDataType.allCards,
      downloadUri: downloadPath,
      size: gzipped.length,
    );

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
      final service = DownloadService.instance;
      service.setTestStorageDirectory(temp);
      service.setHttpClientForTesting(mock);

      expect(await service.isLocalFileAvailable(), isFalse);
      expect(await service.isAllCardsAvailable(), isFalse);

      final file = await service.downloadAllCards(onProgress: null);
      expect(await file.exists(), isTrue);
      expect(await service.isLocalFileAvailable(), isTrue);

      final oldTime = now.subtract(const Duration(days: 1));
      await file.setLastModified(oldTime);
      expect(await service.isAllCardsAvailable(), isFalse);

      final newTime = now.add(const Duration(minutes: 10));
      await file.setLastModified(newTime);
      expect(await service.isAllCardsAvailable(), isTrue);
    } finally {
      await temp.delete(recursive: true);
    }
  });
}

String _bulkResponseJson({
  required DateTime updatedAt,
  required ScryfallBulkDataType type,
  required String downloadUri,
  required int size,
}) {
  return jsonEncode({
    'object': 'list',
    'has_more': false,
    'data': [
      {
        'object': 'bulk_data',
        'id': '${type.apiType}_test',
        'type': type.apiType,
        'updated_at': updatedAt.toIso8601String(),
        'uri': 'https://api.scryfall.com/bulk-data/${type.apiType}_test',
        'name': type.userFacingName,
        'size': size,
        'download_uri': downloadUri,
        'content_type': 'application/json',
        'content_encoding': 'gzip',
      },
    ],
  });
}
