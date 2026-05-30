import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as http_io;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bulk_data_type.dart';

typedef DownloadProgressCallback = void Function(int receivedBytes, int? totalBytes);

class DownloadService {
  DownloadService._();
  static final DownloadService instance = DownloadService._();

  final Uri bulkApi = Uri.parse('https://api.scryfall.com/bulk-data');
  final Map<String, String> defaultHeaders = const <String, String>{
    'User-Agent': 'AetherVault/0.1 (https://github.com/joshey40)',
    'Accept': 'application/json',
  };

  final String _storageSubdir = 'scryfall';
  Directory? _testStorageDir;
  http.Client? _httpClient;

  void setHttpClientForTesting(http.Client client) {
    _httpClient = client;
  }

  void setTestStorageDirectory(Directory dir) {
    _testStorageDir = dir;
  }

  Future<bool> isFileUpToDate({
    ScryfallBulkDataType type = ScryfallBulkDataType.allCards,
  }) =>
      _isFileUpToDate(type);

  Future<bool> isLocalFileAvailable({
    ScryfallBulkDataType type = ScryfallBulkDataType.allCards,
  }) async {
    final file = await _getLocalFile(type);
    if (file == null) return false;

    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_prefsKey(type));
  }

  Future<File?> getLocalFile({
    ScryfallBulkDataType type = ScryfallBulkDataType.allCards,
  }) =>
      _getLocalFile(type);

  Future<bool> isOracleCardsAvailable() =>
      isFileUpToDate(type: ScryfallBulkDataType.oracleCards);

  Future<bool> isAllCardsAvailable() =>
      isFileUpToDate(type: ScryfallBulkDataType.allCards);

  Future<bool> isDefaultCardsAvailable() =>
      isFileUpToDate(type: ScryfallBulkDataType.defaultCards);

  Future<File> downloadOracleCards({
    bool force = false,
    DownloadProgressCallback? onProgress,
  }) =>
      downloadBulkData(
        type: ScryfallBulkDataType.oracleCards,
        force: force,
        onProgress: onProgress,
      );

  Future<File> downloadAllCards({
    bool force = false,
    DownloadProgressCallback? onProgress,
  }) =>
      downloadBulkData(
        type: ScryfallBulkDataType.allCards,
        force: force,
        onProgress: onProgress,
      );

  Future<File> downloadDefaultCards({
    bool force = false,
    DownloadProgressCallback? onProgress,
  }) =>
      downloadBulkData(
        type: ScryfallBulkDataType.defaultCards,
        force: force,
        onProgress: onProgress,
      );

  Future<File> downloadBulkData({
    required ScryfallBulkDataType type,
    bool force = false,
    DownloadProgressCallback? onProgress,
  }) =>
      _downloadBulkData(type: type, force: force, onProgress: onProgress);

  Future<ScryfallBulkDataMetadata> getBulkMetadata({
    ScryfallBulkDataType type = ScryfallBulkDataType.allCards,
  }) =>
      _getBulkMetadata(type);

  Future<ScryfallBulkDataMetadata> _getBulkMetadata(ScryfallBulkDataType type) async {
    final client = _httpClient ?? http.Client();
    try {
      final response = await client.get(bulkApi, headers: defaultHeaders);
      if (response.statusCode != 200) {
        throw HttpException('Failed to fetch bulk metadata: ${response.statusCode}');
      }

      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      final data = jsonBody['data'];
      if (data is! List) {
        throw const FormatException('Scryfall bulk metadata response does not contain a data list.');
      }

      final entry = data.whereType<Map<String, dynamic>>().cast<Map<String, dynamic>?>().firstWhere(
            (item) => item?['type'] == type.apiType,
            orElse: () => null,
          );
      if (entry == null) {
        throw Exception('Bulk metadata for "${type.apiType}" not found.');
      }

      return ScryfallBulkDataMetadata.fromJson(type, entry);
    } finally {
      if (_httpClient == null) client.close();
    }
  }

  Future<File?> _getLocalFile(ScryfallBulkDataType type) async {
    final file = await _localFile(type);
    return await file.exists() ? file : null;
  }

  Future<Directory> _supportDir() async {
    if (_testStorageDir != null) return _testStorageDir!;
    return getApplicationSupportDirectory();
  }

  Future<File> _localFile(ScryfallBulkDataType type) async {
    final dir = await _supportDir();
    final sub = Directory('${dir.path}/$_storageSubdir');
    if (!await sub.exists()) await sub.create(recursive: true);
    return File('${sub.path}/${type.localFileName}');
  }

  String _prefsKey(ScryfallBulkDataType type) => 'scryfall_${type.apiType}_downloaded_at';

  Future<void> _writeDownloadTimestamp(ScryfallBulkDataType type, DateTime timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey(type), timestamp.toUtc().toIso8601String());
  }

  Future<DateTime?> _readDownloadTimestamp(ScryfallBulkDataType type) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_prefsKey(type));
    if (value == null) return null;
    return DateTime.tryParse(value)?.toUtc();
  }

  Future<bool> _isFileUpToDate(ScryfallBulkDataType type) async {
    final local = await _getLocalFile(type);
    if (local == null) return false;

    final metadata = await _getBulkMetadata(type);
    final remoteTime = metadata.updatedAt;
    final localTime = (await local.lastModified()).toUtc();
    final downloadTime = await _readDownloadTimestamp(type);
    const tolerance = Duration(minutes: 10);

    if (downloadTime != null) {
      final timestampOk = !downloadTime.add(tolerance).isBefore(remoteTime);
      final fileOk = !localTime.add(tolerance).isBefore(remoteTime);
      return timestampOk && fileOk;
    }

    return !localTime.add(tolerance).isBefore(remoteTime);
  }

  Future<File> _downloadBulkData({
    required ScryfallBulkDataType type,
    required bool force,
    DownloadProgressCallback? onProgress,
  }) async {
    if (!force) {
      final local = await _getLocalFile(type);
      if (local != null && await _isFileUpToDate(type)) return local;
    }

    final metadata = await _getBulkMetadata(type);
    final client = _httpClient ?? http_io.IOClient(HttpClient()..autoUncompress = false);
    final request = http.Request('GET', metadata.downloadUri)..headers.addAll(defaultHeaders);
    final streamed = await client.send(request);

    if (streamed.statusCode != 200) {
      if (_httpClient == null) client.close();
      throw HttpException(
        'Failed to download ${type.apiType}: ${streamed.statusCode}',
        uri: metadata.downloadUri,
      );
    }

    final local = await _localFile(type);
    final tempFile = File('${local.path}.tmp');
    final sink = tempFile.openWrite();

    int downloaded = 0;
    int? total = streamed.contentLength != null && streamed.contentLength! > 0
        ? streamed.contentLength
        : metadata.size;

    Stream<List<int>> stream = streamed.stream;
    final responseEncoding = streamed.headers['content-encoding']?.toLowerCase();
    final metadataEncoding = metadata.contentEncoding?.toLowerCase();
    final shouldDecompress = responseEncoding == 'gzip' || metadataEncoding == 'gzip';
    if (shouldDecompress) stream = stream.transform(gzip.decoder);

    try {
      await for (final chunk in stream) {
        sink.add(chunk);
        downloaded += chunk.length;
        onProgress?.call(downloaded, total);
      }
    } on FormatException catch (error) {
      throw Exception('Decompression failed for ${type.apiType}: $error');
    } finally {
      await sink.close();
      if (_httpClient == null) client.close();
    }

    if (await local.exists()) await local.delete();
    final moved = await tempFile.rename(local.path);
    await _writeDownloadTimestamp(type, DateTime.now().toUtc());
    return moved;
  }
}
