class ScryfallSearchEngine {
  List<Map<String, dynamic>> filterCards(
    List<dynamic> cards,
    String query,
  ) {
    final sanitizedQuery = query.trim();
    if (sanitizedQuery.isEmpty) {
      return cards.cast<Map<String, dynamic>>();
    }

    final groups = _parseQueryGroups(sanitizedQuery);
    if (groups.isEmpty) {
      return cards.cast<Map<String, dynamic>>();
    }

    return cards.cast<Map<String, dynamic>>().where((card) {
      return groups.any((group) => _matchesGroup(card, group));
    }).toList();
  }

  List<List<_SearchTerm>> _parseQueryGroups(String query) {
    final tokens = _tokenize(query);
    final groups = <List<_SearchTerm>>[];
    var currentGroup = <_SearchTerm>[];

    for (final token in tokens) {
      if (token.toLowerCase() == 'or') {
        if (currentGroup.isNotEmpty) {
          groups.add(currentGroup);
          currentGroup = <_SearchTerm>[];
        }
        continue;
      }

      currentGroup.add(_parseToken(token));
    }

    if (currentGroup.isNotEmpty) {
      groups.add(currentGroup);
    }

    return groups;
  }

  List<String> _tokenize(String query) {
    final tokens = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var index = 0; index < query.length; index++) {
      final character = query[index];
      if (character == '"') {
        inQuotes = !inQuotes;
        buffer.write(character);
        continue;
      }

      if (character.trim().isEmpty && !inQuotes) {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }
        continue;
      }

      buffer.write(character);
    }

    if (buffer.isNotEmpty) {
      tokens.add(buffer.toString());
    }

    return tokens;
  }

  _SearchTerm _parseToken(String token) {
    var rawToken = token.trim();
    var isNegated = false;

    if (rawToken.startsWith('-') && rawToken.length > 1) {
      isNegated = true;
      rawToken = rawToken.substring(1);
    }

    if (rawToken.startsWith('!') && rawToken.length > 1) {
      return _SearchTerm(kind: _SearchTermKind.exactName, value: rawToken.substring(1), isNegated: isNegated);
    }

    final colonIndex = rawToken.indexOf(':');
    if (colonIndex > 0) {
      final field = rawToken.substring(0, colonIndex).toLowerCase();
      final value = _stripQuotes(rawToken.substring(colonIndex + 1));
      return _SearchTerm(kind: _fieldToKind(field), value: value, isNegated: isNegated, field: field);
    }

    return _SearchTerm(kind: _SearchTermKind.looseText, value: _stripQuotes(rawToken), isNegated: isNegated);
  }

  _SearchTermKind _fieldToKind(String field) {
    switch (field) {
      case 't':
      case 'type':
        return _SearchTermKind.type;
      case 'o':
      case 'oracle':
        return _SearchTermKind.oracleText;
      case 'c':
      case 'color':
        return _SearchTermKind.color;
      case 'id':
      case 'identity':
        return _SearchTermKind.colorIdentity;
      case 'r':
      case 'rarity':
        return _SearchTermKind.rarity;
      case 'mv':
      case 'manavalue':
      case 'cmc':
        return _SearchTermKind.manaValue;
      case 's':
      case 'e':
      case 'set':
      case 'edition':
        return _SearchTermKind.set;
      case 'lang':
      case 'language':
        return _SearchTermKind.language;
      case 'is':
        return _SearchTermKind.isKeyword;
      case 'name':
        return _SearchTermKind.name;
      default:
        return _SearchTermKind.looseText;
    }
  }

  bool _matchesGroup(Map<String, dynamic> card, List<_SearchTerm> group) {
    for (final term in group) {
      final matches = _matchesTerm(card, term);
      if (term.isNegated ? matches : !matches) {
        return false;
      }
    }
    return true;
  }

  bool _matchesTerm(Map<String, dynamic> card, _SearchTerm term) {
    final name = _lowerString(card['name']);
    final oracleText = _lowerString(card['oracle_text']);
    final typeLine = _lowerString(card['type_line']);
    final setName = _lowerString(card['set_name']);
    final setCode = _lowerString(card['set']);
    final language = _lowerString(card['lang']);
    final rarity = _lowerString(card['rarity']);
    final cardColors = _stringList(card['colors']);
    final colorIdentity = _stringList(card['color_identity']);
    final keywords = _stringList(card['keywords']);
    final manaValue = _doubleValue(card['cmc']);

    switch (term.kind) {
      case _SearchTermKind.exactName:
        return name == term.value.toLowerCase();
      case _SearchTermKind.name:
        return name.contains(term.value.toLowerCase());
      case _SearchTermKind.type:
        return typeLine.contains(term.value.toLowerCase());
      case _SearchTermKind.oracleText:
        return oracleText.contains(term.value.toLowerCase());
      case _SearchTermKind.color:
        return _matchesColorQuery(cardColors, term.value);
      case _SearchTermKind.colorIdentity:
        return _matchesColorQuery(colorIdentity, term.value);
      case _SearchTermKind.rarity:
        return rarity == term.value.toLowerCase();
      case _SearchTermKind.manaValue:
        return _matchesNumericQuery(manaValue, term.value);
      case _SearchTermKind.set:
        return setCode.contains(term.value.toLowerCase()) || setName.contains(term.value.toLowerCase());
      case _SearchTermKind.language:
        return language.contains(term.value.toLowerCase());
      case _SearchTermKind.isKeyword:
        return _matchesIsKeyword(card, term.value, typeLine, keywords, cardColors);
      case _SearchTermKind.looseText:
        final loose = term.value.toLowerCase();
        return name.contains(loose) || oracleText.contains(loose) || typeLine.contains(loose) || keywords.any((keyword) => keyword.contains(loose));
    }
  }

  bool _matchesColorQuery(List<String> colors, String value) {
    final normalized = value.toLowerCase();
    if (normalized == 'colorless' || normalized == 'c') {
      return colors.isEmpty;
    }
    if (normalized == 'multicolor' || normalized == 'm') {
      return colors.length > 1;
    }

    final requestedColors = normalized.split('').where((char) => 'wubrg'.contains(char)).toSet().toList()..sort();
    if (requestedColors.isEmpty) {
      return false;
    }

    final cardColors = colors.map((color) => color.toLowerCase()).toList()..sort();
    if (cardColors.length != requestedColors.length) {
      return false;
    }

    for (var index = 0; index < requestedColors.length; index++) {
      if (cardColors[index] != requestedColors[index]) {
        return false;
      }
    }

    return true;
  }

  bool _matchesNumericQuery(double value, String rawQuery) {
    final comparison = RegExp(r'^(>=|<=|!=|>|<|=)?\s*([0-9]+(?:\.[0-9]+)?)$').firstMatch(rawQuery.trim());
    if (comparison == null) {
      return false;
    }

    final operator = comparison.group(1) ?? '=';
    final expected = double.parse(comparison.group(2)!);

    switch (operator) {
      case '>':
        return value > expected;
      case '>=':
        return value >= expected;
      case '<':
        return value < expected;
      case '<=':
        return value <= expected;
      case '!=':
        return value != expected;
      case '=':
      default:
        return value == expected;
    }
  }

  bool _matchesIsKeyword(
    Map<String, dynamic> card,
    String rawValue,
    String typeLine,
    List<String> keywords,
    List<String> colors,
  ) {
    final value = rawValue.toLowerCase();
    switch (value) {
      case 'creature':
        return typeLine.contains('creature');
      case 'instant':
        return typeLine.contains('instant');
      case 'sorcery':
        return typeLine.contains('sorcery');
      case 'artifact':
        return typeLine.contains('artifact');
      case 'enchantment':
        return typeLine.contains('enchantment');
      case 'land':
        return typeLine.contains('land');
      case 'planeswalker':
        return typeLine.contains('planeswalker');
      case 'legendary':
        return typeLine.contains('legendary');
      case 'multicolor':
        return colors.length > 1;
      case 'colorless':
        return colors.isEmpty;
      case 'spell':
        return !typeLine.contains('land');
      default:
        return keywords.contains(value);
    }
  }

  String _lowerString(dynamic value) {
    return value?.toString().toLowerCase() ?? '';
  }

  List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.map((entry) => entry.toString().toLowerCase()).toList();
    }
    return const [];
  }

  double _doubleValue(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _stripQuotes(String value) {
    final sanitized = value.trim();
    if (sanitized.length >= 2 && sanitized.startsWith('"') && sanitized.endsWith('"')) {
      return sanitized.substring(1, sanitized.length - 1);
    }
    return sanitized;
  }
}

class _SearchTerm {
  _SearchTerm({
    required this.kind,
    required this.value,
    required this.isNegated,
    this.field,
  });

  final _SearchTermKind kind;
  final String value;
  final bool isNegated;
  final String? field;
}

enum _SearchTermKind {
  looseText,
  exactName,
  name,
  type,
  oracleText,
  color,
  colorIdentity,
  rarity,
  manaValue,
  set,
  language,
  isKeyword,
}