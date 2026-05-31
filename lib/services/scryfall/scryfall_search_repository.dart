import 'bulk_data_type.dart';
import 'scryfall_card_print.dart';
import 'scryfall_search_query.dart';

enum ScryfallSearchSortMode {
  nameAsc,
  nameDesc,
  manaValueAsc,
  newestFirst,
  oldestFirst,
  setAsc,
}

class ScryfallSearchResult {
  const ScryfallSearchResult({
    required this.cards,
    required this.source,
    this.fallbackReason,
  });

  final List<ScryfallCardPrint> cards;
  final ScryfallSearchResultSource source;
  final String? fallbackReason;
}

enum ScryfallSearchResultSource {
  localOracleCards,
  localDefaultCards,
  localAllCards,
  remoteScryfallApi,
}

abstract interface class LocalScryfallSearchDataSource {
  Future<List<ScryfallCardPrint>> searchCards({
    required String rawQuery,
    required ScryfallBulkDataType type,
    ScryfallSearchSortMode sortMode = ScryfallSearchSortMode.nameAsc,
  });
}

abstract interface class RemoteScryfallSearchDataSource {
  Future<List<ScryfallCardPrint>> search(String rawQuery);
}

class HybridScryfallSearchRepository {
  const HybridScryfallSearchRepository({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.planner,
  });

  final LocalScryfallSearchDataSource localDataSource;
  final RemoteScryfallSearchDataSource remoteDataSource;
  final ScryfallSearchPlanner planner;

  Future<ScryfallSearchResult> search(
    String rawQuery, {
    ScryfallSearchSortMode sortMode = ScryfallSearchSortMode.nameAsc,
  }) async {
    final normalizedQuery = rawQuery.trim();
    if (normalizedQuery.isEmpty) {
      return const ScryfallSearchResult(
        cards: <ScryfallCardPrint>[],
        source: ScryfallSearchResultSource.localOracleCards,
      );
    }

    final plan = planner.plan(normalizedQuery);

    switch (plan.query.executionMode) {
      case ScryfallSearchExecutionMode.localOnly:
        try {
          return ScryfallSearchResult(
            cards: await localDataSource.searchCards(
              rawQuery: normalizedQuery,
              type: plan.searchBulkType,
              sortMode: sortMode,
            ),
            source: _sourceForBulkType(plan.searchBulkType),
          );
        } on UnsupportedError catch (error) {
          return _remoteSearch(normalizedQuery, plan.query.reason ?? 'Local parser does not support this query yet: $error', sortMode);
        }
      case ScryfallSearchExecutionMode.remoteOnly:
        return _remoteSearch(normalizedQuery, plan.query.reason, sortMode);
      case ScryfallSearchExecutionMode.localThenRemoteFallback:
        try {
          return ScryfallSearchResult(
            cards: await localDataSource.searchCards(
              rawQuery: normalizedQuery,
              type: plan.searchBulkType,
              sortMode: sortMode,
            ),
            source: _sourceForBulkType(plan.searchBulkType),
            fallbackReason: plan.query.reason,
          );
        } on UnsupportedError {
          return _remoteSearch(normalizedQuery, plan.query.reason, sortMode);
        } catch (_) {
          return _remoteSearch(normalizedQuery, plan.query.reason, sortMode);
        }
    }
  }

  Future<ScryfallSearchResult> _remoteSearch(
    String query,
    String? reason,
    ScryfallSearchSortMode sortMode,
  ) async {
    return ScryfallSearchResult(
      cards: _sortCards(await remoteDataSource.search(query), sortMode),
      source: ScryfallSearchResultSource.remoteScryfallApi,
      fallbackReason: reason,
    );
  }

  static List<ScryfallCardPrint> _sortCards(
    List<ScryfallCardPrint> cards,
    ScryfallSearchSortMode sortMode,
  ) {
    final sorted = [...cards];
    sorted.sort((a, b) {
      switch (sortMode) {
        case ScryfallSearchSortMode.nameAsc:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case ScryfallSearchSortMode.nameDesc:
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        case ScryfallSearchSortMode.manaValueAsc:
          return (a.manaValue ?? 999).compareTo(b.manaValue ?? 999);
        case ScryfallSearchSortMode.newestFirst:
          return (b.releasedAt ?? DateTime(0)).compareTo(a.releasedAt ?? DateTime(0));
        case ScryfallSearchSortMode.oldestFirst:
          return (a.releasedAt ?? DateTime(9999)).compareTo(b.releasedAt ?? DateTime(9999));
        case ScryfallSearchSortMode.setAsc:
          final setCompare = a.setCode.compareTo(b.setCode);
          if (setCompare != 0) return setCompare;
          return a.collectorNumber.compareTo(b.collectorNumber);
      }
    });
    return sorted;
  }

  static ScryfallSearchResultSource _sourceForBulkType(ScryfallBulkDataType type) {
    switch (type) {
      case ScryfallBulkDataType.oracleCards:
        return ScryfallSearchResultSource.localOracleCards;
      case ScryfallBulkDataType.defaultCards:
        return ScryfallSearchResultSource.localDefaultCards;
      case ScryfallBulkDataType.allCards:
        return ScryfallSearchResultSource.localAllCards;
    }
  }
}
