import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../app_preferences_storage.dart';

class DownloadProgress {
  final int current;
  final int total;
  final String? currentType;
  final int? bytesDownloaded;
  final int? bytesTotal;
  final bool isRunning;

  DownloadProgress({
    required this.current,
    required this.total,
    this.currentType,
    this.bytesDownloaded,
    this.bytesTotal,
    required this.isRunning,
  });
}

class ScryfallDownloadService {
  final AppPreferencesStorage _prefs = AppPreferencesStorage();

  static const List<String> bulkDataTypes = [
    'oracle_cards',
    'all_cards',
    'rulings',
    'art_tags',
    'oracle_tags',
  ];

  final _progressController = StreamController<DownloadProgress>.broadcast();

  Stream<DownloadProgress> get progressStream => _progressController.stream;

  Future<Map<String, bool>> needsBulkDataDownload() async {
    try {
      await fetchBulkDataItems();
    } catch (_) {
      return { for (var type in bulkDataTypes) type: true };
    }

    var needsDownload = {
      for (var type in bulkDataTypes)
        type: await shouldDownloadBulkData(
          bulkDataType: type,
          bulkDataItem: await getDataTypeItem(type),
        ),
    };
    
    return needsDownload;
  }

  Future<void> downloadAllBulkData(bool forced) async {
    await fetchBulkDataItems();

    _progressController.add(DownloadProgress(current: 0, total: bulkDataTypes.length, isRunning: true));

    final cacheDirectory = await getBulkDataDirectory();
    await cacheDirectory.create(recursive: true);
    await pruneStaleCacheFiles(cacheDirectory, bulkDataTypes.toSet());

    final typesToDownload = needsBulkDataDownload();

    for (var i = 0; i < bulkDataTypes.length; i++) {
      if (!await typesToDownload.then((map) => map[bulkDataTypes[i]] ?? false) && !forced) {
        _progressController.add(DownloadProgress(current: i + 1, total: bulkDataTypes.length, currentType: bulkDataTypes[i], bytesDownloaded: 0, bytesTotal: 0, isRunning: true));
        continue;
      }
      final type = bulkDataTypes[i];
      final bulkDataItem = await getDataTypeItem(type);
      final totalBytes = bulkDataItem['compressed_size'] is int
          ? bulkDataItem['compressed_size'] as int
          : int.tryParse(bulkDataItem['compressed_size']?.toString() ?? '0') ?? 0;

      _progressController.add(DownloadProgress(current: i + 1, total: bulkDataTypes.length, currentType: type, bytesDownloaded: 0, bytesTotal: totalBytes, isRunning: true));

      await fetchAndStoreDataType(type, totalBytes, i + 1, bulkDataTypes.length);
    }

    _progressController.add(
      DownloadProgress(
        current: bulkDataTypes.length,
        total: bulkDataTypes.length,
        isRunning: false,
      ),
    );
  }
  
  Future<void> fetchBulkDataItems() async {
    final url = Uri.parse('https://api.scryfall.com/bulk-data');
    final response = await http.get(
      url,
      headers: {
        'User-Agent': 'AetherVault/1.0',
        'Accept': 'application/json;q=0.9,*/*;q=0.8',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final bulkDataItems = jsonData['data'] as List<dynamic>;

      await _prefs.saveScryfallBulkDataItems(json.encode(bulkDataItems));
    } else {
      throw Exception('Failed to fetch bulk data items from Scryfall API');
    }
  }
  
  Future<Map<String, dynamic>> getDataTypeItem(String bulkDataType) async {
    final bulkDataItemsJson = await _prefs.loadScryfallBulkDataItems();

    if (bulkDataItemsJson == null) {
      throw Exception('No bulk data items found in preferences storage');
    }

    final bulkDataItems = json.decode(bulkDataItemsJson) as List<dynamic>;
    final bulkDataItem = bulkDataItems.firstWhere(
      (item) => item is Map<String, dynamic> && item['type'] == bulkDataType,
      orElse: () => null,
    );

    if (bulkDataItem is! Map<String, dynamic>) {
      throw Exception('Bulk data type "$bulkDataType" not found in Scryfall API');
    }
    return bulkDataItem;
  }

  Future<bool> shouldDownloadBulkData({required String bulkDataType, required Map<String, dynamic> bulkDataItem}) async {
    final file = File(await getBulkDataFilePath(bulkDataType));
    final remoteUpdatedAt = bulkDataItem['updated_at']?.toString();
    final cachedUpdatedAt = await _loadCachedUpdatedAt(bulkDataType);

    return shouldDownloadCacheEntry(
      cachedFileExists: await file.exists(),
      metadataFileExists: cachedUpdatedAt != null,
      cachedUpdatedAt: cachedUpdatedAt,
      remoteUpdatedAt: remoteUpdatedAt,
    );
  }

  static bool shouldDownloadCacheEntry({required bool cachedFileExists, required bool metadataFileExists, required String? cachedUpdatedAt, required String? remoteUpdatedAt}) {
    if (!cachedFileExists || !metadataFileExists) {
      return true;
    }
    if (remoteUpdatedAt == null || remoteUpdatedAt.isEmpty) {
      return true;
    }
    if (cachedUpdatedAt == null || cachedUpdatedAt.isEmpty) {
      return true;
    }
    final cached = DateTime.parse(cachedUpdatedAt);
    final remote = DateTime.parse(remoteUpdatedAt);
    return remote.difference(cached) >= const Duration(days: 28);
  }

  Future<void> fetchAndStoreDataType(String bulkDataType, int totalBytes, int currentIndex, int totalFiles) async {
    final bulkDataItem = await getDataTypeItem(bulkDataType);
    final downloadUri = bulkDataItem['jsonl_download_uri'];
    if (downloadUri is! String || downloadUri.isEmpty) {
      throw Exception('No download URI found for bulk data type "$bulkDataType"');
    }

    final shouldDownload = await shouldDownloadBulkData(
      bulkDataType: bulkDataType,
      bulkDataItem: bulkDataItem,
    );

    if (!shouldDownload) {
      _progressController.add(DownloadProgress(current: currentIndex, total: totalFiles, currentType: bulkDataType, bytesDownloaded: totalBytes, bytesTotal: totalBytes, isRunning: true));
      return;
    }

    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(downloadUri));
      request.headers.addAll({
        'User-Agent': 'AetherVault/1.0',
        'Accept': 'application/json;q=0.9,*/*;q=0.8',
      });

      final response = await client.send(request);
      if (response.statusCode != 200) {
        throw Exception('Failed to download bulk data type "$bulkDataType"');
      }

      final targetDirectory = await getBulkDataDirectory();
      await targetDirectory.create(recursive: true);
      final destinationPath = await getBulkDataFilePath(bulkDataType);
      final tempPath = '$destinationPath.tmp';
      final tempFile = File(tempPath);

      var downloadedBytes = 0;
      await writeStreamToFile(
        response.stream,
        tempPath,
        onProgress: (bytesWritten) {
          downloadedBytes = bytesWritten;
          _progressController.add(DownloadProgress(current: currentIndex, total: totalFiles, currentType: bulkDataType, bytesDownloaded: downloadedBytes, bytesTotal: totalBytes, isRunning: true));
        },
      );

      if (!await tempFile.exists() || ((await tempFile.length()) == 0 && totalBytes > 0)) {
        throw Exception('Downloaded file for "$bulkDataType" was empty');
      }

      final existingFile = File(destinationPath);
      if (await existingFile.exists()) {
        await existingFile.delete();
      }
      await tempFile.rename(destinationPath);
      await _writeMetadataForBulkData(bulkDataType, bulkDataItem, destinationPath);
    } finally {
      client.close();
    }
  }

  Future<void> _writeMetadataForBulkData(String bulkDataType, Map<String, dynamic> bulkDataItem, String destinationPath) async {
    final metadata = {
      'type': bulkDataType,
      'updated_at': bulkDataItem['updated_at']?.toString(),
      'download_uri': bulkDataItem['download_uri']?.toString(),
      'path': destinationPath,
      'downloaded_at': DateTime.now().toIso8601String(),
    };
    await _prefs.saveScryfallBulkDataMetadata(bulkDataType, json.encode(metadata));
  }

  Future<String?> _loadCachedUpdatedAt(String bulkDataType) async {
    final metadataJson = await _prefs.loadScryfallBulkDataMetadata(bulkDataType);
    if (metadataJson == null || metadataJson.isEmpty) {
      return null;
    }

    try {
      final metadata = json.decode(metadataJson);
      if (metadata is Map<String, dynamic> && metadata['updated_at'] is String) {
        return metadata['updated_at'] as String;
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  Future<Directory> getBulkDataDirectory() async {
    final downloadDirectory = await getApplicationDocumentsDirectory();
    return Directory('${downloadDirectory.path}/bulk_data');
  }

  Future<String> getBulkDataFilePath(String bulkDataType) async {
    return '${(await getBulkDataDirectory()).path}/$bulkDataType.jsonl.gz';
  }

  Future<void> pruneStaleCacheFiles(Directory cacheDirectory, Set<String> activeTypes) async {
    if (!await cacheDirectory.exists()) {
      return;
    }

    final entities = await cacheDirectory.list().toList();
    for (final entity in entities) {
      final name = entity.path.split(Platform.pathSeparator).last;
      final isTempFile = name.endsWith('.tmp');
      final isDataFile = name.endsWith('.jsonl.gz');

      if (isTempFile) {
        await entity.delete();
        continue;
      }

      final typeName = name.replaceFirst('.jsonl.gz', '');

      if (isDataFile && !activeTypes.contains(typeName)) {
        await entity.delete();
      }
    }
  }

  Future<void> writeStreamToFile(Stream<List<int>> stream, String destinationPath, {required void Function(int bytesWritten) onProgress}) async {
    final sink = File(destinationPath).openWrite();
    try {
      var bytesWritten = 0;
      await for (final chunk in stream) {
        sink.add(chunk);
        bytesWritten += chunk.length;
        onProgress(bytesWritten);
      }
      await sink.flush();
    } finally {
      await sink.close();
    }
  }

  void dispose() {
    _progressController.close();
  }
}