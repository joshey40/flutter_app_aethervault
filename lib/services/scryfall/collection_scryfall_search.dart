import 'dart:convert';
import 'dart:isolate';

import 'bulk_data_type.dart';
import 'download_service.dart';
import 'scryfall_search_evaluator.dart';
import 'scryfall_search_filter.dart';
import 'scryfall_search_json_utils.dart';

class CollectionScryfallSearch {
  CollectionScryfallSearch({DownloadService? downloadService}) : _downloadService = downloadService ?? DownloadService.instance;

  final DownloadService _downloadService;

  Future<Set<String>> searchOwnedIds({
    required String rawQuery,
    required Set<String> ownedScryfallIds,
    ScryfallBulkDataType type = ScryfallBulkDataType.allCards,
  }) async {
    if (ownedScryfallIds.isEmpty) return const <String>{};

    final file = await _downloadService.getLocalFile(type: type);
    if (file == null) {
      throw StateError('Scryfall ${type.apiType} file is not available.');
    }

    return Isolate.run(
      () => _searchOwnedIdsInFile(
        path: file.path,
        rawQuery: rawQuery,
        ownedScryfallIds: ownedScryfallIds,
      ),
    );
  }

  static Future<Set<String>> _searchOwnedIdsInFile({
    required String path,
    required String rawQuery,
    required Set<String> ownedScryfallIds,
  }) async {
    final query = ParsedScryfallSearch.parse(rawQuery);
    final includeExtras = ScryfallSearchEvaluator.shouldIncludeExtras(query);
    final matches = <String>{};

    await for (final cardJson in ScryfallJsonSearchUtils.readTopLevelJsonObjects(path)) {
      final decoded = jsonDecode(cardJson);
      if (decoded is! Map<String, dynamic>) continue;

      final id = decoded['id'] as String? ?? '';
      if (!ownedScryfallIds.contains(id)) continue;
      if (!includeExtras && ScryfallJsonSearchUtils.isExtra(decoded)) continue;
      if (!ScryfallSearchEvaluator.matchesQuery(decoded, query)) continue;

      matches.add(id);
      if (matches.length == ownedScryfallIds.length) break;
    }

    return matches;
  }
}
