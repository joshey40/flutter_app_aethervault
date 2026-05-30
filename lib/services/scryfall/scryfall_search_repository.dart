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
  localDefaultCards,
  remoteScryfallApi,
}

abstract interface class LocalScryfallSearchDataSource {
  Future<List<ScryfallCardPrint>> searchDefaultCards(String rawQuery);
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
        source: ScryfallSearchResultSource.localDefaultCards,
      );
    }

    final plan = planner.plan(normalizedQuery);

    switch (plan.query.executionMode) {
      case ScryfallSearchExecutionMode.localOnly:
        return ScryfallSearchResult(
          cards: await localDataSource.searchDefaultCards(normalizedQuery),
          source: ScryfallSearchResultSource.localDefaultCards,
        );
      case ScryfallSearchExecutionMode.remoteOnly:
        return ScryfallSearchResult(
          cards: await remoteDataSource.search(normalizedQuery),
          source: ScryfallSearchResultSource.remoteScryfallApi,
          fallbackReason: plan.query.reason,
        );
      case ScryfallSearchExecutionMode.localThenRemoteFallback:
        try {
          return ScryfallSearchResult(
            cards: await localDataSource.searchDefaultCards(normalizedQuery),
            source: ScryfallSearchResultSource.localDefaultCards,
            fallbackReason: plan.query.reason,
          );
        } catch (_) {
          return ScryfallSearchResult(
            cards: await remoteDataSource.search(normalizedQuery),
            source: ScryfallSearchResultSource.remoteScryfallApi,
            fallbackReason: plan.query.reason,
          );
        }
    }
  }
}
