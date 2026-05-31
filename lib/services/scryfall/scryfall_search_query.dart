import 'bulk_data_type.dart';
import 'scryfall_search_filter.dart';

class ScryfallSearchQuery {
  const ScryfallSearchQuery({
    required this.rawQuery,
    required this.executionMode,
    required this.localTerms,
    required this.remoteOnlyTerms,
    this.reason,
  });

  final String rawQuery;
  final ScryfallSearchExecutionMode executionMode;
  final List<String> localTerms;
  final List<String> remoteOnlyTerms;
  final String? reason;

  bool get requiresRemoteFallback =>
      executionMode == ScryfallSearchExecutionMode.remoteOnly ||
      executionMode == ScryfallSearchExecutionMode.localThenRemoteFallback;
}

enum ScryfallSearchExecutionMode {
  localOnly,
  localThenRemoteFallback,
  remoteOnly,
}

class ScryfallSearchPlan {
  const ScryfallSearchPlan({
    required this.query,
    required this.searchBulkType,
    required this.collectionBulkType,
  });

  final ScryfallSearchQuery query;

  /// Source for local search. Normal searches use oracle_cards to avoid
  /// duplicates; print-sensitive searches use default_cards or all_cards.
  final ScryfallBulkDataType searchBulkType;

  /// Source for exact print ownership and language/variant tracking.
  final ScryfallBulkDataType collectionBulkType;
}

class ScryfallSearchPlanner {
  ScryfallSearchPlanner({
    this.remoteOnlyKeywords = const <String>{
      'art',
      'atag',
      'artisttag',
      'function',
      'ftag',
      'otag',
      'oracletag',
      'cube',
      'lore',
      'prefer',
      'order',
      'unique',
      'include',
    },
    this.locallySupportedKeywords = const <String>{
      'artist',
      'artistId',
      'banned',
      'border',
      'colors',
      'collectorNumber',
      'date',
      'defense',
      'eur',
      'flavor',
      'frame',
      'game',
      'identity',
      'in',
      'is',
      'lang',
      'layout',
      'legal',
      'loyalty',
      'mana',
      'manaValue',
      'name',
      'oracle',
      'power',
      'producedMana',
      'rarity',
      'restricted',
      'set',
      'setName',
      'setType',
      'tix',
      'toughness',
      'type',
      'usd',
      'year',
    },
    this.printSensitiveKeywords = const <String>{
      'artist',
      'artistId',
      'border',
      'collectorNumber',
      'date',
      'eur',
      'frame',
      'game',
      'in',
      'is',
      'lang',
      'layout',
      'rarity',
      'set',
      'setName',
      'setType',
      'tix',
      'usd',
      'year',
    },
    this.allCardsKeywords = const <String>{
      'lang',
    },
  });

  final Set<String> remoteOnlyKeywords;
  final Set<String> locallySupportedKeywords;
  final Set<String> printSensitiveKeywords;
  final Set<String> allCardsKeywords;

  ScryfallSearchPlan plan(String rawQuery) {
    final filters = ParsedScryfallSearch.parse(rawQuery).filters;
    final remoteOnly = <String>[];
    final local = <String>[];
    var searchBulkType = ScryfallBulkDataType.oracleCards;

    for (final filter in filters) {
      final keyword = filter.canonicalKeyword;
      if (remoteOnlyKeywords.contains(keyword) || !locallySupportedKeywords.contains(keyword)) {
        remoteOnly.add(filter.source);
      } else {
        local.add(filter.source);
      }

      if (_requiresAllCards(filter)) {
        searchBulkType = ScryfallBulkDataType.allCards;
      } else if (_isPrintSensitive(filter) && searchBulkType != ScryfallBulkDataType.allCards) {
        searchBulkType = ScryfallBulkDataType.defaultCards;
      }
    }

    final executionMode = remoteOnly.isEmpty
        ? ScryfallSearchExecutionMode.localOnly
        : local.isEmpty
            ? ScryfallSearchExecutionMode.remoteOnly
            : ScryfallSearchExecutionMode.localThenRemoteFallback;

    final reason = remoteOnly.isEmpty
        ? null
        : 'Query contains terms that are not represented reliably in local search: ${remoteOnly.join(', ')}';

    return ScryfallSearchPlan(
      searchBulkType: searchBulkType,
      collectionBulkType: ScryfallBulkDataType.allCards,
      query: ScryfallSearchQuery(
        rawQuery: rawQuery,
        executionMode: executionMode,
        localTerms: local,
        remoteOnlyTerms: remoteOnly,
        reason: reason,
      ),
    );
  }

  bool _requiresAllCards(ScryfallSearchFilter filter) {
    if (allCardsKeywords.contains(filter.canonicalKeyword)) return true;
    if (filter.canonicalKeyword == 'is') {
      return const <String>{'extra', 'token', 'funny'}.contains(filter.normalizedValue);
    }
    return false;
  }

  bool _isPrintSensitive(ScryfallSearchFilter filter) {
    if (printSensitiveKeywords.contains(filter.canonicalKeyword)) return true;
    if (filter.canonicalKeyword == 'is') {
      return const <String>{
        'foil',
        'nonfoil',
        'etched',
        'promo',
        'variation',
        'booster',
        'story',
        'fullart',
        'textless',
        'oversized',
        'highres',
      }.contains(filter.normalizedValue);
    }
    return false;
  }
}

extension on ScryfallSearchFilter {
  String get source => '${negated ? '-' : ''}$keyword$operator$value';
}
