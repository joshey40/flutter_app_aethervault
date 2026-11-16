import '../card_database/database.dart';
import '../card_database/scryfall_query.dart';
import 'collection_enums.dart';
import 'collection_repository.dart';

/// Searches card groups of the collection with Scryfall syntax plus filters
/// for the user's own copies:
///
/// - `own:` nonfoil, foil, etched, proxy, altered, signed
/// - `cond:` / `condition:` 1-7 or M, NM, EX, GD, LP, PL, PO. With `<`, `>`,
///   `<=`, `>=` it compares the condition (1 = mint, 7 = poor), e.g.
///   `cond<=nm` finds mint and near mint cards.
///
/// Both can be negated (`-own:proxy`) and combined with `or` and brackets
/// like any other filter.
class CollectionSearch {
  const CollectionSearch(this._database);

  final AppDatabase _database;

  static const _ownKeys = {'own'};
  static const _conditionKeys = {'cond', 'condition'};

  static const _conditionCodes = {
    'm': CardQuality.mint,
    'nm': CardQuality.nearMint,
    'ex': CardQuality.excellent,
    'gd': CardQuality.good,
    'lp': CardQuality.lightPlayed,
    'pl': CardQuality.played,
    'po': CardQuality.poor,
  };

  static bool _isCollectionFilter(FilterToken token) =>
      _ownKeys.contains(token.key) || _conditionKeys.contains(token.key);

  /// The keys ([CardGroup.key]) of the [groups] matching [query].
  /// Throws a [FormatException] for invalid syntax.
  Future<Set<String>> filter(String query, List<CardGroup> groups) async {
    final tokens = tokenizeScryfallSyntax(query);
    if (tokens.isEmpty) return {for (final group in groups) group.key};

    // Check the collection filters first, so typos are reported right away.
    final cardFilters = <FilterToken>[];
    void collect(QueryToken token) {
      switch (token) {
        case ListToken():
          token.tokens.forEach(collect);
        case FilterToken() when _isCollectionFilter(token):
          _validate(token);
        case FilterToken():
          cardFilters.add(token);
      }
    }

    tokens.forEach(collect);

    // Every card filter is looked up once in the Scryfall data.
    final ids = {for (final group in groups) group.scryfallId};
    final cardMatches = <FilterToken, Set<String>>{};
    for (final token in cardFilters) {
      cardMatches[token] = await _database.filterCardIdsByTokens([token], ids);
    }

    bool matches(QueryToken token, CardGroup group) {
      switch (token) {
        case ListToken():
          final results = token.tokens.map((t) => matches(t, group));
          final combined = token.isOR
              ? results.any((result) => result)
              : results.every((result) => result);
          return token.isNegated ? !combined : combined;
        case FilterToken() when _isCollectionFilter(token):
          final result = _matchesCollectionFilter(token, group);
          return token.isNegated ? !result : result;
        case FilterToken():
          // Negation is already part of the database query.
          return cardMatches[token]!.contains(group.scryfallId);
      }
    }

    return {
      for (final group in groups)
        if (tokens.every((token) => matches(token, group))) group.key,
    };
  }

  static void _validate(FilterToken token) {
    if (_ownKeys.contains(token.key)) {
      if (token.op != FilterOp.contains && token.op != FilterOp.eq) {
        throw FormatException('own: unterstützt nur ":" ($token)');
      }
      _ownCheck(token.value);
    } else {
      _condition(token.value);
    }
  }

  static bool Function(CardGroup group) _ownCheck(String value) {
    return switch (value.toLowerCase()) {
      'nonfoil' => (group) => group.finish == CardFinish.nonfoil,
      'foil' => (group) => group.finish == CardFinish.foil,
      'etched' => (group) => group.finish == CardFinish.etched,
      'proxy' => (group) => group.isProxy,
      'altered' => (group) => group.isAltered,
      'signed' => (group) => group.isSigned,
      _ => throw FormatException(
        'Unbekannter Wert für own: "$value" '
        '(nonfoil, foil, etched, proxy, altered, signed)',
      ),
    };
  }

  static CardQuality _condition(String value) {
    final lower = value.toLowerCase();
    final number = int.tryParse(lower);
    if (number != null && number >= 1 && number <= 7) {
      return CardQuality.fromValue(number);
    }
    final quality = _conditionCodes[lower];
    if (quality == null) {
      throw FormatException(
        'Unbekannter Wert für cond: "$value" (1-7, M, NM, EX, GD, LP, PL, PO)',
      );
    }
    return quality;
  }

  static bool _matchesCollectionFilter(FilterToken token, CardGroup group) {
    if (_ownKeys.contains(token.key)) return _ownCheck(token.value)(group);

    final target = _condition(token.value).value;
    final quality = group.quality.value;
    if (token.op == FilterOp.ne) return quality != target;
    // Cards with unknown condition never match a condition.
    if (group.quality == CardQuality.unknown) return false;
    return switch (token.op) {
      FilterOp.gt => quality > target,
      FilterOp.gte => quality >= target,
      FilterOp.lt => quality < target,
      FilterOp.lte => quality <= target,
      _ => quality == target,
    };
  }
}
