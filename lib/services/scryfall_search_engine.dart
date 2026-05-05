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
      return _SearchTerm(
        kind: _SearchTermKind.exactName,
        value: rawToken.substring(1),
        isNegated: isNegated,
      );
    }

    // Match field[operator]value – operators: >=, <=, !=, :, =, >, <
    final fieldMatch = RegExp(r'^([a-zA-Z]+)(>=|<=|!=|:|=|>|<)(.+)$').firstMatch(rawToken);
    if (fieldMatch != null) {
      final field = fieldMatch.group(1)!.toLowerCase();
      final operator = fieldMatch.group(2)!;
      final value = _stripQuotes(fieldMatch.group(3)!);
      return _SearchTerm(
        kind: _fieldToKind(field),
        value: value,
        isNegated: isNegated,
        field: field,
        operator: operator,
      );
    }

    return _SearchTerm(
      kind: _SearchTermKind.looseText,
      value: _stripQuotes(rawToken),
      isNegated: isNegated,
    );
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
      case 'has':
        return _SearchTermKind.hasKeyword;
      case 'not':
        return _SearchTermKind.notKeyword;
      case 'name':
      case 'n':
        return _SearchTermKind.name;
      case 'pow':
      case 'power':
        return _SearchTermKind.power;
      case 'tou':
      case 'tough':
      case 'toughness':
        return _SearchTermKind.toughness;
      case 'loy':
      case 'loyalty':
        return _SearchTermKind.loyalty;
      case 'm':
      case 'mana':
        return _SearchTermKind.manaCost;
      case 'a':
      case 'art':
      case 'artist':
        return _SearchTermKind.artist;
      case 'ft':
      case 'flavor':
        return _SearchTermKind.flavorText;
      case 'kw':
      case 'keyword':
        return _SearchTermKind.keyword;
      case 'f':
      case 'format':
      case 'legal':
        return _SearchTermKind.format;
      case 'banned':
        return _SearchTermKind.banned;
      case 'restricted':
        return _SearchTermKind.restricted;
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

  /// Returns oracle text from top-level field, falling back to concatenated
  /// card_faces oracle texts for double-faced / adventure cards.
  String _oracleText(Map<String, dynamic> card) {
    final direct = card['oracle_text']?.toString() ?? '';
    if (direct.isNotEmpty) return direct.toLowerCase();
    final faces = card['card_faces'];
    if (faces is List && faces.isNotEmpty) {
      return faces
          .map((f) => (f as Map<String, dynamic>)['oracle_text']?.toString() ?? '')
          .join('\n')
          .toLowerCase();
    }
    return '';
  }

  /// Returns type line from top-level field, falling back to card_faces.
  String _typeLine(Map<String, dynamic> card) {
    final direct = card['type_line']?.toString() ?? '';
    if (direct.isNotEmpty) return direct.toLowerCase();
    final faces = card['card_faces'];
    if (faces is List && faces.isNotEmpty) {
      return faces
          .map((f) => (f as Map<String, dynamic>)['type_line']?.toString() ?? '')
          .join('\n')
          .toLowerCase();
    }
    return '';
  }

  bool _matchesTerm(Map<String, dynamic> card, _SearchTerm term) {
    final name = _lowerString(card['name']);
    final oracleText = _oracleText(card);
    final typeLine = _typeLine(card);
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
        return _matchesColorQuery(cardColors, term.value, term.operator);
      case _SearchTermKind.colorIdentity:
        return _matchesColorQuery(colorIdentity, term.value, term.operator);
      case _SearchTermKind.rarity:
        return _matchesRarity(rarity, term.value.toLowerCase(), term.operator);
      case _SearchTermKind.manaValue:
        return _matchesNumericQuery(manaValue, _opValueQuery(term.operator, term.value));
      case _SearchTermKind.set:
        return setCode == term.value.toLowerCase() || setName.contains(term.value.toLowerCase());
      case _SearchTermKind.language:
        return language.contains(term.value.toLowerCase());
      case _SearchTermKind.isKeyword:
        return _matchesIsKeyword(card, term.value, typeLine, keywords, cardColors);
      case _SearchTermKind.hasKeyword:
        return _matchesHasKeyword(card, term.value);
      case _SearchTermKind.notKeyword:
        return !_matchesIsKeyword(card, term.value, typeLine, keywords, cardColors);
      case _SearchTermKind.power:
        return _matchesPowerToughness(card['power'], term.value, term.operator);
      case _SearchTermKind.toughness:
        return _matchesPowerToughness(card['toughness'], term.value, term.operator);
      case _SearchTermKind.loyalty:
        return _matchesPowerToughness(card['loyalty'], term.value, term.operator);
      case _SearchTermKind.manaCost:
        return _matchesManaCost(card, term.value, term.operator);
      case _SearchTermKind.artist:
        return _lowerString(card['artist']).contains(term.value.toLowerCase());
      case _SearchTermKind.flavorText:
        return _lowerString(card['flavor_text']).contains(term.value.toLowerCase());
      case _SearchTermKind.keyword:
        return keywords.any((kw) => kw.contains(term.value.toLowerCase()));
      case _SearchTermKind.format:
        return _matchesFormat(card, term.value.toLowerCase(), 'legal');
      case _SearchTermKind.banned:
        return _matchesFormat(card, term.value.toLowerCase(), 'banned');
      case _SearchTermKind.restricted:
        return _matchesFormat(card, term.value.toLowerCase(), 'restricted');
      case _SearchTermKind.looseText:
        final loose = term.value.toLowerCase();
        return name.contains(loose) ||
            oracleText.contains(loose) ||
            typeLine.contains(loose) ||
            keywords.any((kw) => kw.contains(loose));
    }
  }

  // ---------------------------------------------------------------------------
  // Color matching
  //
  // Scryfall semantics:
  //   c:wu   / c>=wu  – card includes at least W and U (requested ⊆ card)
  //   c=wu           – card is exactly WU
  //   c>wu           – card is a proper superset of WU (more colors, includes WU)
  //   c<=wu          – card uses only colors from {W,U} (card ⊆ requested)
  //   c<wu           – card uses a proper subset of {W,U}
  //   c!=wu          – card is not exactly WU
  // ---------------------------------------------------------------------------
  bool _matchesColorQuery(List<String> cardColors, String value, String operator) {
    final normalized = value.toLowerCase();

    if (normalized == 'colorless' || normalized == 'c') {
      return cardColors.isEmpty;
    }
    if (normalized == 'multicolor' || normalized == 'm') {
      return cardColors.length > 1;
    }

    final requested = normalized.split('').where((c) => 'wubrg'.contains(c)).toSet();
    if (requested.isEmpty) return false;
    final card = cardColors.map((c) => c.toLowerCase()).toSet();

    switch (operator) {
      case ':':
      case '>=':
        // card ⊇ requested
        return requested.every(card.contains);
      case '=':
        // card == requested
        return card.length == requested.length && requested.every(card.contains);
      case '>':
        // card ⊃ requested (proper superset)
        return card.length > requested.length && requested.every(card.contains);
      case '<=':
        // card ⊆ requested
        return card.every(requested.contains);
      case '<':
        // card ⊂ requested (proper subset)
        return card.length < requested.length && card.every(requested.contains);
      case '!=':
        return !(card.length == requested.length && requested.every(card.contains));
      default:
        return requested.every(card.contains);
    }
  }

  // ---------------------------------------------------------------------------
  // Rarity matching with ordering: common < uncommon < rare < mythic
  // ---------------------------------------------------------------------------
  bool _matchesRarity(String cardRarity, String value, String operator) {
    const order = {'common': 0, 'uncommon': 1, 'rare': 2, 'mythic': 3};
    final cardRank = order[cardRarity];
    final queryRank = order[value];

    if (cardRank == null || queryRank == null) {
      return cardRarity == value;
    }

    switch (operator) {
      case ':':
      case '=':
        return cardRank == queryRank;
      case '>':
        return cardRank > queryRank;
      case '>=':
        return cardRank >= queryRank;
      case '<':
        return cardRank < queryRank;
      case '<=':
        return cardRank <= queryRank;
      case '!=':
        return cardRank != queryRank;
      default:
        return cardRank == queryRank;
    }
  }

  // ---------------------------------------------------------------------------
  // Power / toughness / loyalty matching
  // ---------------------------------------------------------------------------
  bool _matchesPowerToughness(dynamic rawValue, String queryValue, String operator) {
    final s = rawValue?.toString().trim() ?? '';
    if (s.isEmpty) return false;

    if (queryValue == '*') {
      return s.contains('*');
    }

    // Cards with variable P/T (containing *, +, or ?) are excluded from numeric
    // comparisons and only match when the query value is literally '*'.
    if (s.contains('*') || s.contains('+') || s == '?') {
      return false;
    }

    final value = double.tryParse(s);
    if (value == null) return false;

    return _matchesNumericQuery(value, _opValueQuery(operator, queryValue));
  }

  // ---------------------------------------------------------------------------
  // Mana cost matching
  // ---------------------------------------------------------------------------
  bool _matchesManaCost(Map<String, dynamic> card, String value, String operator) {
    final raw = _lowerString(card['mana_cost']);
    // Normalize by stripping braces so "{2}{W}{W}" becomes "2ww"
    final normalizedCost = raw.replaceAll('{', '').replaceAll('}', '');
    final normalizedQuery = value.toLowerCase().replaceAll('{', '').replaceAll('}', '');

    if (operator == '=') {
      return normalizedCost == normalizedQuery;
    }
    return normalizedCost.contains(normalizedQuery);
  }

  // ---------------------------------------------------------------------------
  // Format / legality matching
  // ---------------------------------------------------------------------------
  bool _matchesFormat(Map<String, dynamic> card, String format, String status) {
    final legalities = card['legalities'];
    if (legalities is! Map) return false;
    return legalities[format]?.toString() == status;
  }

  // ---------------------------------------------------------------------------
  // is: keyword matching
  // ---------------------------------------------------------------------------
  bool _matchesIsKeyword(
    Map<String, dynamic> card,
    String rawValue,
    String typeLine,
    List<String> keywords,
    List<String> colors,
  ) {
    final value = rawValue.toLowerCase();
    switch (value) {
      // --- Card types ---
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
      case 'battle':
        return typeLine.contains('battle');
      case 'tribal':
        return typeLine.contains('tribal');
      // --- Supertypes ---
      case 'legendary':
        return typeLine.contains('legendary');
      case 'basic':
        return typeLine.contains('basic');
      case 'snow':
        return typeLine.contains('snow');
      case 'world':
        return typeLine.contains('world');
      // --- Color properties ---
      case 'multicolor':
      case 'multi':
        return colors.length > 1;
      case 'colorless':
        return colors.isEmpty;
      case 'monocolored':
      case 'mono':
        return colors.length == 1;
      // --- Card categories ---
      case 'spell':
        return !typeLine.contains('land');
      case 'permanent':
        return typeLine.contains('creature') ||
            typeLine.contains('artifact') ||
            typeLine.contains('enchantment') ||
            typeLine.contains('land') ||
            typeLine.contains('planeswalker') ||
            typeLine.contains('battle');
      case 'historic':
        return typeLine.contains('legendary') ||
            typeLine.contains('artifact') ||
            typeLine.contains('saga');
      case 'vanilla':
        // Creature with no oracle text (no abilities)
        return typeLine.contains('creature') && _oracleText(card).trim().isEmpty;
      // --- Card flags ---
      case 'reprint':
        return card['reprint'] == true;
      case 'promo':
        return card['promo'] == true;
      case 'digital':
        return card['digital'] == true;
      case 'foil':
        return _stringList(card['finishes']).contains('foil');
      case 'nonfoil':
        return _stringList(card['finishes']).contains('nonfoil');
      case 'oversized':
        return card['oversized'] == true;
      case 'fullart':
      case 'full_art':
        return card['full_art'] == true;
      case 'textless':
        return card['textless'] == true;
      case 'spotlight':
      case 'story_spotlight':
        return card['story_spotlight'] == true;
      case 'booster':
        return card['booster'] == true;
      case 'commander':
        final legalities = card['legalities'];
        if (legalities is Map) return legalities['commander'] == 'legal';
        return false;
      default:
        return keywords.contains(value);
    }
  }

  // ---------------------------------------------------------------------------
  // has: keyword matching
  // ---------------------------------------------------------------------------
  bool _matchesHasKeyword(Map<String, dynamic> card, String value) {
    switch (value.toLowerCase()) {
      case 'watermark':
        final wm = card['watermark']?.toString() ?? '';
        return wm.isNotEmpty;
      case 'foil':
        return _stringList(card['finishes']).contains('foil');
      case 'nonfoil':
        return _stringList(card['finishes']).contains('nonfoil');
      case 'flavor':
      case 'flavortext':
        final ft = card['flavor_text']?.toString() ?? '';
        return ft.isNotEmpty;
      case 'artist':
        final a = card['artist']?.toString() ?? '';
        return a.isNotEmpty;
      default:
        return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Numeric query helpers
  // ---------------------------------------------------------------------------

  /// Combine operator and value into a single string for _matchesNumericQuery.
  /// ':' is treated as '=' for numeric fields.
  String _opValueQuery(String operator, String value) {
    final op = operator == ':' ? '=' : operator;
    return '$op$value';
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

  // ---------------------------------------------------------------------------
  // Utility helpers
  // ---------------------------------------------------------------------------

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
    this.operator = ':',
  });

  final _SearchTermKind kind;
  final String value;
  final bool isNegated;
  final String? field;
  final String operator;
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
  hasKeyword,
  notKeyword,
  power,
  toughness,
  loyalty,
  manaCost,
  artist,
  flavorText,
  keyword,
  format,
  banned,
  restricted,
}