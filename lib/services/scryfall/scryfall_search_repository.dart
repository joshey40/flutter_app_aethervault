import 'bulk_data_type.dart';
import 'scryfall_card_print.dart';
import 'scryfall_search_query.dart';

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

  Future<ScryfallSearchResult> search(String rawQuery) async {
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
            ),
            source: _sourceForBulkType(plan.searchBulkType),
          );
        } on UnsupportedError catch (error) {
          return _remoteSearch(normalizedQuery, 'Local parser does not support this query yet: $error');
        }
      case ScryfallSearchExecutionMode.remoteOnly:
        return _remoteSearch(normalizedQuery, plan.query.reason);
      case ScryfallSearchExecutionMode.localThenRemoteFallback:
        try {
          return ScryfallSearchResult(
            cards: await localDataSource.searchCards(
              rawQuery: normalizedQuery,
              type: plan.searchBulkType,
            ),
            source: _sourceForBulkType(plan.searchBulkType),
            fallbackReason: plan.query.reason,
          );
        } on UnsupportedError {
          return _remoteSearch(normalizedQuery, plan.query.reason);
        } catch (_) {
          return _remoteSearch(normalizedQuery, plan.query.reason);
        }
    }
  }

  Future<ScryfallSearchResult> _remoteSearch(String query, String? reason) async {
    return ScryfallSearchResult(
      cards: await remoteDataSource.search(query),
      source: ScryfallSearchResultSource.remoteScryfallApi,
      fallbackReason: reason,
    );
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
