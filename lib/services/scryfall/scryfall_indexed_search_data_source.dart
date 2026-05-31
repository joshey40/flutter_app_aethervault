import 'bulk_data_type.dart';
import 'download_service.dart';
import 'scryfall_card_print.dart';
import 'scryfall_local_json_search_data_source.dart';
import 'scryfall_search_repository.dart';
import 'scryfall_sqlite_search_index.dart';

class ScryfallIndexedSearchDataSource implements LocalScryfallSearchDataSource {
  ScryfallIndexedSearchDataSource({
    DownloadService? downloadService,
    ScryfallSqliteSearchIndex? searchIndex,
    ScryfallLocalJsonSearchDataSource? fallbackDataSource,
    this.maxResults,
  })  : _downloadService = downloadService ?? DownloadService.instance,
        _searchIndex = searchIndex ?? ScryfallSqliteSearchIndex.instance,
        _fallbackDataSource = fallbackDataSource ?? ScryfallLocalJsonSearchDataSource(maxResults: maxResults);

  final DownloadService _downloadService;
  final ScryfallSqliteSearchIndex _searchIndex;
  final ScryfallLocalJsonSearchDataSource _fallbackDataSource;
  final int? maxResults;

  @override
  Future<List<ScryfallCardPrint>> searchCards({
    required String rawQuery,
    required ScryfallBulkDataType type,
    ScryfallSearchSortMode sortMode = ScryfallSearchSortMode.nameAsc,
  }) async {
    final file = await _downloadService.getLocalFile(type: type);
    if (file == null) {
      throw StateError('Scryfall ${type.apiType} file is not available.');
    }

    try {
      return await _searchIndex.search(
        type: type,
        sourceFile: file,
        rawQuery: rawQuery,
        maxResults: maxResults,
        sortMode: sortMode,
      );
    } on UnsupportedError {
      return _fallbackDataSource.searchCards(
        rawQuery: rawQuery,
        type: type,
        sortMode: sortMode,
      );
    }
  }
}
