import 'bulk_data_type.dart';

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
    },
    this.locallySupportedKeywords = const <String>{
      'a',
      'artist',
      'c',
      'ci',
      'cmc',
      'color',
      'colors',
      'commander',
      'e',
      'edh',
      'edition',
      'eur',
      'game',
      'id',
      'identity',
      'in',
      'is',
      'lang',
      'language',
      'mv',
      'n',
      'name',
      'o',
      'oracle',
      'r',
      'rarity',
      's',
      'set',
      't',
      'type',
      'usd',
      'year',
    },
    this.printSensitiveKeywords = const <String>{
      'artist',
      'a',
      'collector',
      'cn',
      'e',
      'edition',
      'eur',
      'f',
      'finish',
      'lang',
      'language',
      'number',
      'r',
      'rarity',
      's',
      'set',
      'usd',
      'year',
    },
    this.allCardsKeywords = const <String>{
      'lang',
      'language',
    },
  });

  final Set<String> remoteOnlyKeywords;
  final Set<String> locallySupportedKeywords;
  final Set<String> printSensitiveKeywords;
  final Set<String> allCardsKeywords;

  ScryfallSearchPlan plan(String rawQuery) {
    final terms = _extractKeywordTerms(rawQuery);
    final remoteOnly = <String>[];
    final local = <String>[];
    var searchBulkType = ScryfallBulkDataType.oracleCards;

    for (final term in terms) {
      final keyword = term.keyword.toLowerCase();
      if (remoteOnlyKeywords.contains(keyword) || !locallySupportedKeywords.contains(keyword)) {
        remoteOnly.add(term.source);
      } else {
        local.add(term.source);
      }

      if (allCardsKeywords.contains(keyword)) {
        searchBulkType = ScryfallBulkDataType.allCards;
      } else if (printSensitiveKeywords.contains(keyword) &&
          searchBulkType != ScryfallBulkDataType.allCards) {
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

  List<_KeywordTerm> _extractKeywordTerms(String rawQuery) {
    final matches = RegExp(r'(^|[\s(\-])([a-zA-Z][a-zA-Z0-9_]*)(:|=|!=|>=|<=|>|<)')
        .allMatches(rawQuery);

    return matches
        .map((match) => _KeywordTerm(
              keyword: match.group(2)!,
              source: rawQuery.substring(match.start, match.end).trim(),
            ))
        .toList(growable: false);
  }
}

class _KeywordTerm {
  const _KeywordTerm({
    required this.keyword,
    required this.source,
  });

  final String keyword;
  final String source;
}
