class ParsedScryfallSearch {
  const ParsedScryfallSearch(this.filters);

  final List<ScryfallSearchFilter> filters;

  bool get isEmpty => filters.isEmpty;

  factory ParsedScryfallSearch.parse(String rawQuery) {
    final filters = <ScryfallSearchFilter>[];
    for (final token in tokenize(rawQuery)) {
      final negated = token.startsWith('-');
      final cleanToken = negated ? token.substring(1) : token;
      final comparison = RegExp(r'^([a-zA-Z][a-zA-Z0-9_]*)(<=|>=|!=|=|<|>|:)(.+)$').firstMatch(cleanToken);

      if (comparison == null) {
        filters.add(ScryfallSearchFilter(
          keyword: 'name',
          operator: ':',
          value: cleanToken,
          normalizedValue: normalize(cleanToken),
          negated: negated,
        ));
        continue;
      }

      final keyword = comparison.group(1)!.toLowerCase();
      final operator = comparison.group(2)!;
      final value = comparison.group(3)!.trim();
      filters.add(ScryfallSearchFilter(
        keyword: keyword,
        operator: operator,
        value: value,
        normalizedValue: normalize(value),
        negated: negated,
      ));
    }
    return ParsedScryfallSearch(filters);
  }

  static List<String> tokenize(String rawQuery) {
    final tokens = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < rawQuery.length; i++) {
      final char = rawQuery[i];
      if (char == '"') {
        inQuotes = !inQuotes;
        continue;
      }
      if (!inQuotes && char.trim().isEmpty) {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }
        continue;
      }
      buffer.write(char);
    }

    if (buffer.isNotEmpty) tokens.add(buffer.toString());
    return tokens;
  }

  static String normalize(String value) => value.toLowerCase().trim();
}

class ScryfallSearchFilter {
  const ScryfallSearchFilter({
    required this.keyword,
    required this.operator,
    required this.value,
    required this.normalizedValue,
    required this.negated,
  });

  final String keyword;
  final String operator;
  final String value;
  final String normalizedValue;
  final bool negated;

  String get canonicalKeyword {
    switch (keyword) {
      case 'name':
      case 'n':
        return 'name';
      case 'type':
      case 't':
        return 'type';
      case 'oracle':
      case 'o':
        return 'oracle';
      case 'artist':
      case 'a':
        return 'artist';
      case 'set':
      case 's':
      case 'e':
      case 'edition':
        return 'set';
      case 'rarity':
      case 'r':
        return 'rarity';
      case 'lang':
      case 'language':
        return 'lang';
      case 'game':
        return 'game';
      case 'c':
      case 'color':
      case 'colors':
        return 'colors';
      case 'ci':
      case 'id':
      case 'identity':
      case 'commander':
      case 'edh':
        return 'identity';
      case 'mv':
      case 'cmc':
        return 'manaValue';
      case 'usd':
        return 'usd';
      case 'eur':
        return 'eur';
      case 'year':
        return 'year';
      case 'is':
        return 'is';
      case 'in':
        return 'in';
      default:
        return keyword;
    }
  }
}
