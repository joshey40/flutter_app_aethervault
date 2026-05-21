import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as http_io;
import 'package:shared_preferences/shared_preferences.dart';

// kept intentionally minimal; no flutter-specific imports required

/// Minimal DownloadService placeholder: keeps constants but no implementation.
class DownloadService {
  DownloadService._();
  static final DownloadService instance = DownloadService._();

  final Uri bulkApi = Uri.parse('https://api.scryfall.com/bulk-data');
  final String bulkDataType = 'all_cards';
  final Map<String, String> defaultHeaders = {
    'User-Agent': 'AetherVault/0.1 (https://github.com/joshey40)',
    'Accept': 'application/json',
  };
  final String localFileName = 'scryfall_all_cards.json';

    // directory name under application support where scryfall data will be stored
    final String _storageSubdir = 'scryfall';
    Directory? _testStorageDir;
    http.Client? _httpClient;

    /// For tests: inject an `http.Client` to use instead of creating a new one.
    void setHttpClientForTesting(http.Client client) {
        _httpClient = client;
    }

    /// For tests: set a directory to use instead of the platform Application Support dir.
    void setTestStorageDirectory(Directory dir) {
        _testStorageDir = dir;
        // Ensure the test storage dir is clean for deterministic tests and
        // clear any saved download timestamp.
        (() async {
            try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove(_prefsKey);
                final sub = Directory('${dir.path}/$_storageSubdir');
                if (await sub.exists()) {
                    final data = File('${sub.path}/$localFileName');
                    if (await data.exists()) await data.delete();
                }
            } catch (_) {}
        })();
    }

  Future<bool> isFileUpToDate() =>
      _isFileUpToDate();

  Future<bool> isLocalFileAvailable() =>
      _getLocalFile().then((f) async {
          if (f == null) return false;
          final prefs = await SharedPreferences.getInstance();
          return prefs.containsKey(_prefsKey);
      });

  Future<File?> getLocalFile() =>
      _getLocalFile();

  Future<bool> isAllCardsAvailable() =>
      _isAllCardsAvailable();

  Future<File> downloadAllCards({bool force = false, void Function(int, int?)? onProgress}) =>
      _downloadAllCards(force: force, onProgress: onProgress);

  Future<Map<String, dynamic>> getBulkMetadata() =>
            _getBulkMetadata();

    Future<Map<String, dynamic>> _getBulkMetadata() async {
        final client = _httpClient ?? http.Client();
        try {
            final resp = await client.get(bulkApi, headers: defaultHeaders);
            if (resp.statusCode != 200) {
                throw HttpException('Failed to fetch bulk metadata: ${resp.statusCode}');
            }
            final Map<String, dynamic> jsonBody = jsonDecode(resp.body) as Map<String, dynamic>;
            final List<dynamic> data = jsonBody['data'] as List<dynamic>;
            final entry = data.firstWhere(
                (e) => e is Map<String, dynamic> && e['type'] == bulkDataType,
                orElse: () => null,
            );
            if (entry == null) {
                throw Exception('Bulk metadata for "$bulkDataType" not found');
            }
            final Map<String, dynamic> result = Map<String, dynamic>.from(entry as Map);
            return result;
        } catch (e) {
            rethrow;
        } finally {
            if (_httpClient == null) client.close();
        }
    }

    Future<File?> _getLocalFile() async {
                final f = await _localFile();
                return await f.exists() ? f : null;
    }

    Future<Directory> _supportDir() async {
        if (_testStorageDir != null) return _testStorageDir!;
        return await getApplicationSupportDirectory();
    }

    Future<File> _localFile() async {
        final dir = await _supportDir();
        final sub = Directory('${dir.path}/$_storageSubdir');
        if (!await sub.exists()) await sub.create(recursive: true);
        return File('${sub.path}/$localFileName');
    }

    final String _prefsKey = 'scryfall_downloaded_at';

    Future<void> _writeDownloadTimestamp(DateTime t) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefsKey, t.toUtc().toIso8601String());
    }

    Future<DateTime?> _readDownloadTimestamp() async {
        final prefs = await SharedPreferences.getInstance();
        final s = prefs.getString(_prefsKey);
        if (s == null) return null;
        try {
            return DateTime.parse(s).toUtc();
        } catch (_) {
            return null;
        }
    }

    Future<bool> _isFileUpToDate() async {
        final local = await _getLocalFile();
        if (local == null) return false;
        final meta = await _getBulkMetadata();
        final updatedAt = meta['updated_at'] as String?;
        if (updatedAt == null) return false;
        final remoteTime = DateTime.parse(updatedAt).toUtc();

        final tolerance = const Duration(seconds: 600);
        final dlTs = await _readDownloadTimestamp();
        final localTime = (await local.lastModified()).toUtc();
        if (dlTs != null) {
            final dlOk = !dlTs.add(tolerance).isBefore(remoteTime);
            final fileOk = !localTime.add(tolerance).isBefore(remoteTime);
            return dlOk && fileOk;
        }
        return !localTime.add(tolerance).isBefore(remoteTime);
    }

    Future<bool> _isAllCardsAvailable() async {
        final local = await _getLocalFile();
        if (local == null) return false;
        return await _isFileUpToDate();
    }

    Future<File> _downloadAllCards({bool force = false, void Function(int, int?)? onProgress}) async {
        if (!force) {
            final local = await _getLocalFile();
            if (local != null) {
                final upToDate = await _isFileUpToDate();
                if (upToDate) return local;
            }
        }

        final meta = await _getBulkMetadata();
        final downloadUri = meta['download_uri'] as String?;
        if (downloadUri == null) throw Exception('download_uri missing from metadata');
        final expectedSize = (meta['size'] is int) ? meta['size'] as int : null;

        final uri = Uri.parse(downloadUri);
        final client = _httpClient ?? http_io.IOClient(HttpClient()..autoUncompress = false);
        final req = http.Request('GET', uri);
        req.headers.addAll(defaultHeaders);
        final streamed = await client.send(req);
        if (streamed.statusCode != 200) {
            if (_httpClient == null) client.close();
            throw HttpException('Failed to download file: ${streamed.statusCode}');
        }

        final local = await _localFile();
        final tempPath = '${local.path}.tmp';
        final tempFile = File(tempPath);
        final sink = tempFile.openWrite();

        int downloaded = 0;
        int? total = (streamed.contentLength != null && streamed.contentLength! > 0)
            ? streamed.contentLength
            : null;
        if (total == null && expectedSize != null) total = expectedSize;

        Stream<List<int>> stream = streamed.stream;
        final responseEncoding = streamed.headers['content-encoding']?.toLowerCase();
        // Prefer the actual HTTP response header to decide decompression. The
        // underlying IO client may auto-decompress and remove the header, so
        // only decompress when the response explicitly contains gzip.
        final shouldDecompress = responseEncoding == 'gzip';
        if (shouldDecompress) stream = stream.transform(gzip.decoder);

        try {
            await for (final chunk in stream) {
                sink.add(chunk);
                downloaded += chunk.length;
                if (onProgress != null) onProgress(downloaded, total);
            }
        } on FormatException catch (e) {
            await sink.close();
            if (_httpClient == null) client.close();
            throw Exception('Decompression failed: $e');
        } catch (e) {
            rethrow;
        } finally {
            await sink.close();
            if (_httpClient == null) client.close();
        }

        final finalFile = await _localFile();
        if (await finalFile.exists()) await finalFile.delete();
        final moved = await tempFile.rename(finalFile.path);
        await _writeDownloadTimestamp(DateTime.now().toUtc());
        return moved;
    }
}
