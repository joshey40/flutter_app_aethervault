import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ScryfallBulkType {
  oracleCards,
  defaultCards,
  allCards,
}

class ScryfallBulkMetadata {
  const ScryfallBulkMetadata({
    required this.bulkType,
    required this.lastDownload,
    required this.fileName,
    required this.fileSizeBytes,
  });

  final ScryfallBulkType bulkType;
  final DateTime? lastDownload;
  final String fileName;
  final int? fileSizeBytes;
}

extension ScryfallBulkTypeX on ScryfallBulkType {
  String get apiValue {
    switch (this) {
      case ScryfallBulkType.oracleCards:
        return 'oracle_cards';
      case ScryfallBulkType.defaultCards:
        return 'default_cards';
      case ScryfallBulkType.allCards:
        return 'all_cards';
    }
  }

  String get storageSuffix {
    return apiValue;
  }

  String get fileName {
    return 'scryfall_$apiValue.json';
  }
}

class ScryfallService {
  ScryfallService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _bulkIndexUrl = 'https://api.scryfall.com/bulk-data';
  final Map<String, String> _defaultHeaders = {
    'User-Agent': 'AetherVault/1.0 (+https://aethervault.joshey.org)',
    'Accept': 'application/json',
  };
  final Map<ScryfallBulkType, List<dynamic>> _webCacheData = {};
  final Map<ScryfallBulkType, int?> _webCacheSizeBytes = {};

  String _prefsLastDownloadKey(ScryfallBulkType bulkType) => 'scryfall.${bulkType.storageSuffix}.lastDownload';
  String _prefsFileNameKey(ScryfallBulkType bulkType) => 'scryfall.${bulkType.storageSuffix}.fileName';

  /// Returns whether a local cached file exists and its last download time (nullable)
  Future<DateTime?> lastDownload({ScryfallBulkType bulkType = ScryfallBulkType.allCards}) async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt(_prefsLastDownloadKey(bulkType));
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<String?> _localFilePath({ScryfallBulkType bulkType = ScryfallBulkType.allCards}) async {
    if (kIsWeb) {
      return null;
    }
    final prefs = await SharedPreferences.getInstance();
    final fileName = prefs.getString(_prefsFileNameKey(bulkType)) ?? bulkType.fileName;
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$fileName';
  }

  Future<bool> hasLocalCache({ScryfallBulkType bulkType = ScryfallBulkType.allCards}) async {
    if (kIsWeb) {
      return _webCacheData[bulkType] != null;
    }
    final path = await _localFilePath(bulkType: bulkType);
    final exists = await File(path!).exists();
    return exists;
  }

  Future<int?> localFileSizeBytes({ScryfallBulkType bulkType = ScryfallBulkType.allCards}) async {
    if (kIsWeb) {
      return _webCacheSizeBytes[bulkType];
    }
    final path = await _localFilePath(bulkType: bulkType);
    final file = File(path!);
    if (!await file.exists()) {
      return null;
    }
    return file.length();
  }

  Future<ScryfallBulkMetadata> metadata({
    ScryfallBulkType bulkType = ScryfallBulkType.allCards,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    return ScryfallBulkMetadata(
      bulkType: bulkType,
      lastDownload: await lastDownload(bulkType: bulkType),
      fileName: prefs.getString(_prefsFileNameKey(bulkType)) ?? bulkType.fileName,
      fileSizeBytes: await localFileSizeBytes(bulkType: bulkType),
    );
  }

  /// Check bulk index and return the chosen download uri (oracle_cards preferred)
  Future<String?> fetchBulkIndexAndChooseUri({ScryfallBulkType bulkType = ScryfallBulkType.allCards}) async {
    try {
      final res = await _client.get(Uri.parse(_bulkIndexUrl), headers: _defaultHeaders);
      if (res.statusCode != 200) {
        if (kDebugMode) debugPrint('ScryfallService: failed to fetch bulk index HTTP ${res.statusCode}');
        return null;
      }

      final decoded = json.decode(res.body) as Map<String, dynamic>;
      final data = decoded['data'] as List<dynamic>?;
      if (data == null) return null;

      // Log available types for debugging
      try {
        // noop: keep original data processing
        data;
      } catch (_) {}

      // Prefer the requested bulk type, fall back to first with "download_uri"
      String? downloadUri;
      for (final entry in data) {
        final map = entry as Map<String, dynamic>;
        if (map['type'] == bulkType.apiValue && map['download_uri'] != null) {
          downloadUri = map['download_uri'] as String;
          break;
        }
      }
      if (downloadUri == null) {
        for (final entry in data) {
          final map = entry as Map<String, dynamic>;
          if (map['download_uri'] != null) {
            downloadUri = map['download_uri'] as String;
            break;
          }
        }
      }
      if (kDebugMode) debugPrint('ScryfallService: chosen downloadUri for ${bulkType.apiValue}: $downloadUri');
      return downloadUri;
    } catch (e) {
      if (kDebugMode) debugPrint('ScryfallService: fetchBulkIndexAndChooseUri failed after retries: $e');
      return null;
    }
    
  }

  /// Downloads the bulk file and saves locally while reporting progress via [onProgress] (0..1)
  Future<void> downloadBulk(
    String downloadUri, {
    required void Function(double) onProgress,
    ScryfallBulkType bulkType = ScryfallBulkType.allCards,
  }) async {
    if (kDebugMode) debugPrint('ScryfallService: starting download for ${bulkType.apiValue} -> $downloadUri');
    if (kIsWeb) {
      onProgress(0);
      final response = await _client.get(Uri.parse(downloadUri), headers: _defaultHeaders);
      if (response.statusCode != 200) {
        if (kDebugMode) debugPrint('ScryfallService: failed to download bulk (web) HTTP ${response.statusCode}');
        throw Exception('Failed to download Scryfall bulk data');
      }

      final decoded = json.decode(response.body) as List<dynamic>;
      _webCacheData[bulkType] = decoded;
      _webCacheSizeBytes[bulkType] = response.bodyBytes.length;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefsLastDownloadKey(bulkType), DateTime.now().millisecondsSinceEpoch);
      onProgress(1);
      return;
    }

    final req = http.Request('GET', Uri.parse(downloadUri));
    req.headers.addAll(_defaultHeaders);
    final streamed = await _client.send(req);
    if (streamed.statusCode != 200) {
      if (kDebugMode) debugPrint('ScryfallService: failed to download bulk HTTP ${streamed.statusCode}');
      throw Exception('Failed to download Scryfall bulk data: HTTP ${streamed.statusCode}');
    }

    final contentLength = streamed.contentLength ?? 0;
    final path = await _localFilePath(bulkType: bulkType);
    final file = File(path!);
    await file.parent.create(recursive: true);
    final sink = file.openWrite();

    int received = 0;
    final completer = Completer<void>();

    streamed.stream.listen((chunk) {
      received += chunk.length;
      sink.add(chunk);
      if (contentLength > 0) {
        onProgress(received / contentLength);
      }
    }, onDone: () async {
      await sink.close();
      // store timestamp
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefsLastDownloadKey(bulkType), DateTime.now().millisecondsSinceEpoch);
      await prefs.setString(_prefsFileNameKey(bulkType), file.uri.pathSegments.last);
      onProgress(1);
      completer.complete();
    }, onError: (e) async {
      await sink.close();
      if (kDebugMode) debugPrint('ScryfallService: error while downloading/saving bulk: $e');
      completer.completeError(Exception('Failed to save Scryfall bulk data: $e'));
    }, cancelOnError: true);

    await completer.future;
  }

  /// Whether cache is older than [maxAgeDays]
  Future<bool> isCacheStale({int maxAgeDays = 7, ScryfallBulkType bulkType = ScryfallBulkType.allCards}) async {
    final last = await lastDownload(bulkType: bulkType);
    if (last == null) return true;
    return DateTime.now().difference(last) > Duration(days: maxAgeDays);
  }

  Future<List<dynamic>?> loadLocalBulkType({ScryfallBulkType bulkType = ScryfallBulkType.oracleCards}) async {
    try {
      if (kIsWeb) {
        return _webCacheData[bulkType];
      }
      final path = await _localFilePath(bulkType: bulkType);
      final file = File(path!);
      if (!await file.exists()) return null;
      // file can be large; do not compute heavy transforms on main isolate
      final raw = await compute(_readAndDecode, file.path);
      return raw as List<dynamic>?;
    } catch (_) {
      return null;
    }
  }

  Future<void> prepareData({required void Function(double) onProgress}) async {
    final steps = 3;
    int step = 0;
    Future<void> onProgressWrapper(double progress) async {
      final overallProgress = (step + progress) / steps;
      onProgress(overallProgress);
    }
    // download card data
    final oracleUri = await fetchBulkIndexAndChooseUri(bulkType: ScryfallBulkType.oracleCards);
    if (oracleUri != null) {
      await downloadBulk(oracleUri, onProgress: onProgressWrapper, bulkType: ScryfallBulkType.oracleCards);
      step++;
    } else {
      if (kDebugMode) debugPrint('ScryfallService: no download URI found for oracle_cards');
    }
    final defaultUri = await fetchBulkIndexAndChooseUri(bulkType: ScryfallBulkType.defaultCards);
    if (defaultUri != null) {
      await downloadBulk(defaultUri, onProgress: onProgressWrapper, bulkType: ScryfallBulkType.defaultCards);
      step++;
    } else {
      if (kDebugMode) debugPrint('ScryfallService: no download URI found for default_cards');
    }
    final allUri = await fetchBulkIndexAndChooseUri(bulkType: ScryfallBulkType.allCards);
    if (allUri != null) {
      await downloadBulk(allUri, onProgress: onProgressWrapper, bulkType: ScryfallBulkType.allCards);
      step++;
    } else {
      if (kDebugMode) debugPrint('ScryfallService: no download URI found for all_cards');
    }
  }

  static Future<dynamic> _readAndDecode(String path) async {
    final file = File(path);
    final contents = await file.readAsString();
    return json.decode(contents);
  }
}
