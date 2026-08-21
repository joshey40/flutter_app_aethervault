import 'package:drift/drift.dart';
import 'database.dart';

enum FilterOp { eq, ne, gt, gte, lt, lte, contains }

FilterOp _mapOp(String s) => switch (s) {
      ':' => FilterOp.contains,
      '=' => FilterOp.eq,
      '!=' => FilterOp.ne,
      '>' => FilterOp.gt,
      '>=' => FilterOp.gte,
      '<' => FilterOp.lt,
      '<=' => FilterOp.lte,
      _ => throw FormatException('Unknown operator: $s'),
    };

sealed class QueryToken {}

class FilterToken extends QueryToken {
  final String key;
  final FilterOp op;
  final String value;
  final bool isNegated;
  FilterToken({
    required this.key,
    required this.op,
    required this.value,
    this.isNegated = false,
  });

  @override
  String toString() => '${isNegated ? '-' : ''}$key${op.name}$value';
}

class ListToken extends QueryToken {
  final bool isOR;
  final List<QueryToken> tokens;
  final bool isNegated;
  ListToken({
    required this.isOR,
    required this.tokens,
    this.isNegated = false,
  });
}

// Utility functions

List<String> _splitTokens(String input) {
  final tokens = <String>[];
  final buf = StringBuffer();

  void flush() {
    if (buf.isNotEmpty) {
      tokens.add(buf.toString());
      buf.clear();
    }
  }

  var i = 0;
  while (i < input.length) {
    final c = input[i];
    if (c == ' ' || c == '\t' || c == '\n') {
      flush();
      i++;
    } else if (c == '"') {
      buf.write(c);
      i++;
      while (i < input.length && input[i] != '"') {
        buf.write(input[i]);
        i++;
      }
      if (i < input.length) {
        buf.write('"');
        i++;
      }
    } else if (c == '(') {
      if (buf.toString() == '-') {
        buf.clear();
        tokens.add('-(');
      } else {
        flush();
        tokens.add('(');
      }
      i++;
    } else if (c == ')') {
      flush();
      tokens.add(')');
      i++;
    } else {
      buf.write(c);
      i++;
    }
  }
  flush();
  return tokens;
}

List<QueryToken> tokenizeScryfallSyntax(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return [];
  final tokens = _splitTokens(trimmed);
  final root = _TokenParser(tokens).parse();
  if (root is ListToken && !root.isOR && !root.isNegated) return root.tokens;
  return [root];
}

bool containsLangFilter(List<QueryToken> tokens) {
  bool check(QueryToken t) {
    if (t is FilterToken) return t.key == 'lang' || t.key == 'language';
    if (t is ListToken) return t.tokens.any(check);
    return false;
  }
  return tokens.any(check);
}

bool containsTypeFilter(List<QueryToken> tokens) {
  bool check(QueryToken t) {
    if (t is FilterToken) return (t.key == 't' || t.key == 'type') && t.isNegated == false;
    if (t is ListToken) return t.tokens.any(check);
    return false;
  }
  return tokens.any(check);
}

bool containsSetFilter(List<QueryToken> tokens) {
  bool check(QueryToken t) {
    if (t is FilterToken) return (t.key == 's' || t.key == 'e' || t.key == 'set' || t.key == 'edition') && t.isNegated == false;
    if (t is ListToken) return t.tokens.any(check);
    return false;
  }
  return tokens.any(check);
}

const Map<String, String> _isValueToOracleTagSlug = {
  'frenchvanilla': 'french-vanilla',
  'manland': 'creatureland',
  'creatureland': 'creatureland'
};

Set<String> collectOracleTagLookups(List<QueryToken> tokens) {
  final result = <String>{};
  void visit(QueryToken t) {
    if (t is FilterToken) {
      if (t.key == 'function' || t.key == 'tag' || t.key == 'oracletag' || t.key == 'otag') {
        result.add(t.value.toLowerCase());
      }
      final mappedSlug = _isValueToOracleTagSlug[t.value.toLowerCase()];
      if ((t.key == 'is' || t.key == 'not') && mappedSlug != null) {
        result.add(mappedSlug);
      }
    } else if (t is ListToken) {
      t.tokens.forEach(visit);
    }
  }
  tokens.forEach(visit);
  return result;
}

Set<String> collectIllustrationTagLookups(List<QueryToken> tokens) {
  final result = <String>{};
  void visit(QueryToken t) {
    if (t is FilterToken && (t.key == 'art' || t.key == 'atag' || t.key == 'arttag')) {
      result.add(t.value.toLowerCase());
    } else if (t is ListToken) {
      t.tokens.forEach(visit);
    }
  }
  tokens.forEach(visit);
  return result;
}

void scopeCards(List<ScryfallCard> cards, String searchScope) {
  if (searchScope == 'one_card') {
    final seen = <String, ScryfallCard>{};
    for (final card in cards) {
      if (card.oracleId == null) continue;
      final key = card.oracleId!;
      seen.putIfAbsent(key, () => card);
    }
    cards
      ..clear()
      ..addAll(seen.values);
  }
}

void sortCards(List<ScryfallCard> cards, String orderBy, String orderDir, List<ScryfallSet> allSets) {
  int cmp(ScryfallCard a, ScryfallCard b) {
    final powerA = double.tryParse(a.power ?? '') ?? 0.0;
    final powerB = double.tryParse(b.power ?? '') ?? 0.0;
    final toughA = double.tryParse(a.toughness ?? '') ?? 0.0;
    final toughB = double.tryParse(b.toughness ?? '') ?? 0.0;
    final setReleaseA = allSets.firstWhere((s) => s.code == a.setCode).releasedAt;
    final setReleaseB = allSets.firstWhere((s) => s.code == b.setCode).releasedAt;
    final result = switch (orderBy) {
      'name' => a.name.compareTo(b.name),
      'released_at' => a.releasedAt.compareTo(b.releasedAt),
      'set' => setReleaseA.compareTo(setReleaseB),
      'rarity' => a.rarityValue.compareTo(b.rarityValue),
      'color' => a.colorMask.compareTo(b.colorMask),
      'cmc' => a.cmc.compareTo(b.cmc),
      'power' => powerA.compareTo(powerB),
      'toughness' => toughA.compareTo(toughB),
      _ => a.name.compareTo(b.name),
    };
    return orderDir == 'desc' ? -result : result;
  }
  cards.sort(cmp);
}

// Parser

final _filterRe = RegExp(r'^(-)?(\w+)(:|>=|<=|=|!=|>|<)(?:"([^"]*)"|(\S+))$');

class _TokenParser {
  final List<String> tokens;
  int pos = 0;
  _TokenParser(this.tokens);

  QueryToken parse() {
    final result = _parseOr();
    if (pos != tokens.length) {
      throw FormatException('Unerwartetes Token "${tokens[pos]}"');
    }
    return result;
  }

  QueryToken _parseOr() {
    final terms = [_parseAnd()];
    while (pos < tokens.length && tokens[pos].toUpperCase() == 'OR') {
      pos++;
      terms.add(_parseAnd());
    }
    return terms.length == 1 ? terms.first : ListToken(isOR: true, tokens: terms);
  }

  QueryToken _parseAnd() {
    final terms = <QueryToken>[];
    while (pos < tokens.length &&
        tokens[pos].toUpperCase() != 'OR' &&
        tokens[pos] != ')') {
      terms.add(_parseTerm());
    }
    if (terms.isEmpty) throw const FormatException('Ausdruck erwartet');
    return terms.length == 1 ? terms.first : ListToken(isOR: false, tokens: terms);
  }

  QueryToken _parseTerm() {
    final tok = tokens[pos];

    if (tok == '(' || tok == '-(') {
      pos++;
      final inner = _parseOr();
      if (pos >= tokens.length || tokens[pos] != ')') {
        throw const FormatException('Schließende Klammer fehlt');
      }
      pos++;
      return _negate(inner, tok == '-(');
    }

    pos++;
    final m = _filterRe.firstMatch(tok);
    if (m != null) {
      return FilterToken(
        key: m.group(2)!.toLowerCase(),
        op: _mapOp(m.group(3)!),
        value: m.group(4) ?? m.group(5)!,
        isNegated: m.group(1) != null,
      );
    }

    var value = tok;
    final negated = value.startsWith('-');
    if (negated) value = value.substring(1);
    if (value.startsWith('"') && value.endsWith('"') && value.length >= 2) {
      value = value.substring(1, value.length - 1);
    }
    return FilterToken(key: 'name', op: FilterOp.contains, value: value, isNegated: negated);
  }

  QueryToken _negate(QueryToken t, bool negated) {
    if (!negated) return t;
    return switch (t) {
      FilterToken f => FilterToken(key: f.key, op: f.op, value: f.value, isNegated: !f.isNegated),
      ListToken l => ListToken(isOR: l.isOR, tokens: l.tokens, isNegated: !l.isNegated),
    };
  }
}

// Compiler for compiling QueryToken into a Drift Expression

const Map<String, int> _colorBits = {'w': 1, 'u': 2, 'b': 4, 'r': 8, 'g': 16};

int _colorMaskFromValue(String value) {
  final v = value.toLowerCase();
  const nicknames = {
    'colorless': 0,
    'c': 0,
    // Guilds
    'azorius': 3, // w u
    'dimir': 6, // u b
    'rakdos': 12, // b r
    'gruul': 24, // r g
    'selesnya': 17, // g w
    'orzhov': 5, // w b
    'izzet': 10, // u r
    'golgari': 20, // b g
    'boros': 9, // r w
    'simic': 18, // g u
    // Strixhaven Colleges
    'prismari': 10, // u r
    'lorehold': 9, // w r
    'silverquill': 5, // w b
    'quandrix': 18, // g u
    'witherbloom': 20, // b g
    // Shards
    'esper': 7, // w u b
    'grixis': 14, // u b r
    'jund': 28, // b r g
    'naya': 25, // r g w
    'bant': 19, // g w u
    // Wedges
    'abzan': 21, // w b g
    'jeskai': 11, // w u r
    'sultai': 22, // u b g
    'mardu': 13, // w b r
    'temur': 26, // u r g
    // Four-Color
    'chaos': 30, // u b r g
    'aggression': 29, // w b r g
    'altruism': 27, // w u r g
    'growth': 23, // w u b g
    'artifice': 15, // w u b r
    // Nephilim-Nicknames
    'glint-eye': 30, // u b r g
    'dune-brood': 29, // w b r g
    'ink-treader': 27, // w u r g
    'witch-maw': 23, // w u b g
    'yore-tiller': 15, // w u b r
    // Five-Color
    'five': 31, // w u b r g
    'five-color': 31, // w u b r g
  };
  if (nicknames.containsKey(v)) return nicknames[v]!;

  var mask = 0;
  for (final ch in v.split('')) {
    mask |= _colorBits[ch] ?? 0;
  }
  return mask;
}

GeneratedColumn<String> _legalityColumn($ScryfallCardsTable t, String format) {
  return switch (format.toLowerCase()) {
    'standard' => t.legalStandard,
    'future' => t.legalFuture,
    'historic' => t.legalHistoric,
    'timeless' => t.legalTimeless,
    'gladiator' => t.legalGladiator,
    'pioneer' => t.legalPioneer,
    'modern' => t.legalModern,
    'legacy' => t.legalLegacy,
    'pauper' => t.legalPauper,
    'vintage' => t.legalVintage,
    'penny' => t.legalPenny,
    'edh' => t.legalCommander,
    'commander' => t.legalCommander,
    'oathbreaker' => t.legalOathbreaker,
    'standardbrawl' => t.legalStandardBrawl,
    'brawl' => t.legalBrawl,
    'alchemy' => t.legalAlchemy,
    'paupercommander' => t.legalPauperCommander,
    'duel' => t.legalDuel,
    'oldschool' => t.legalOldSchool,
    'premodern' => t.legalPremodern,
    'predh' => t.legalPredh,
    _ => throw FormatException('Unbekanntes Format: $format'),
  };
}

Expression<bool> _numericExpression(Expression<double> col, FilterOp op, String rawValue) {
  final n = double.tryParse(rawValue);
  if (n == null) throw FormatException('Ungültiger Zahlenwert: $rawValue');
  return switch (op) {
    FilterOp.contains => col.equals(n),
    FilterOp.eq => col.equals(n),
    FilterOp.ne => col.equals(n).not(),
    FilterOp.gt => col.isBiggerThanValue(n),
    FilterOp.gte => col.isBiggerOrEqualValue(n),
    FilterOp.lt => col.isSmallerThanValue(n),
    FilterOp.lte => col.isSmallerOrEqualValue(n),
  };
}

Expression<bool> _numericStringExpression(Expression<String> col, FilterOp op, String rawValue) {
  // Convert * to 0, since Scryfall treats * as 0 for comparison purposes
  final n = rawValue == '*' ? 0.0 : double.tryParse(rawValue);
  if (n == null) throw FormatException('Ungültiger Zahlenwert: $rawValue');
  final expr = switch (op) {
    FilterOp.contains => col.cast<double>().equals(n),
    FilterOp.eq => col.cast<double>().equals(n),
    FilterOp.ne => col.cast<double>().equals(n).not(),
    FilterOp.gt => col.cast<double>().isBiggerThanValue(n),
    FilterOp.gte => col.cast<double>().isBiggerOrEqualValue(n),
    FilterOp.lt => col.cast<double>().isSmallerThanValue(n),
    FilterOp.lte => col.cast<double>().isSmallerOrEqualValue(n),
  };
  return col.isNull().not() & expr;
}

Expression<bool> _rarityCompareExpression(Expression<int> col, FilterOp op, String rawValue) {
  final v = rawValue.toLowerCase();
  final rarityOrder = ['common', 'uncommon', 'rare', 'mythic'];
  final index = rarityOrder.indexOf(v) + 1;
  if (index < 1 || index > 4) throw FormatException('Ungültige Seltenheit: $rawValue');
  return _numericExpression(col.cast<double>(), op, index.toString());
}

Expression<bool> _colorMaskExpression(Expression<int> col, FilterOp op, String rawValue, bool isIdentity) {
  final v = rawValue.toLowerCase();

  if (v == 'c' || v == 'colorless') {
    final isColorless = col.equals(0);
    return op == FilterOp.ne ? isColorless.not() : isColorless;
  }

  Expression<int> bitAsInt(int bit) {
    final hasBit = col.bitwiseAnd(Constant(bit)).equals(bit);
    return const Constant(1).iif(hasBit, const Constant(0));
  }
  Expression<int> colorPopcount = bitAsInt(1) + bitAsInt(2) + bitAsInt(4) + bitAsInt(8) + bitAsInt(16);

  if (v == 'm' || v == 'multicolor') {
    final isMulti = colorPopcount.isBiggerOrEqualValue(2);
    return op == FilterOp.ne ? isMulti.not() : isMulti;
  }

  final asNumber = int.tryParse(v);
  if (asNumber != null) {
    final count = colorPopcount;
    return switch (op) {
      FilterOp.contains || FilterOp.eq => count.equals(asNumber),
      FilterOp.ne => count.equals(asNumber).not(),
      FilterOp.gt => count.isBiggerThanValue(asNumber),
      FilterOp.gte => count.isBiggerOrEqualValue(asNumber),
      FilterOp.lt => count.isSmallerThanValue(asNumber),
      FilterOp.lte => count.isSmallerOrEqualValue(asNumber),
    };
  }

  final mask = _colorMaskFromValue(v);
  final maskConst = Constant(mask);
  final isSuperset = col.bitwiseAnd(maskConst).equals(mask);
  final isSubset = col.bitwiseAnd(maskConst).equalsExp(col);
  final isEqual = col.equals(mask);

  return switch (op) {
    FilterOp.contains => isIdentity ? isSubset : isSuperset,
    FilterOp.gte => isSuperset,
    FilterOp.gt => isSuperset & isEqual.not(),
    FilterOp.lte => isSubset,
    FilterOp.lt => isSubset & isEqual.not(),
    FilterOp.eq => isEqual,
    FilterOp.ne => isEqual.not(),
  };
}

Expression<String> _tildeToNamePattern(Expression<String> nameCol, String rawValue) {
  final parts = rawValue.split('~');
  Expression<String> pattern = const Variable<String>('%');
  for (var i = 0; i < parts.length; i++) {
    pattern = pattern + Variable<String>(parts[i]);
    if (i < parts.length - 1) pattern = pattern + nameCol;
  }
  return pattern + const Variable<String>('%');
}

Expression<bool> _powerToughnessCompareExpression(Expression<String> col, FilterOp op, Expression<String> otherCol) {
  final colNum = col.cast<double>();
  final otherColNum = otherCol.cast<double>();
  return switch (op) {
    FilterOp.contains || FilterOp.eq => colNum.equalsExp(otherColNum),
    FilterOp.ne => colNum.equalsExp(otherColNum).not(),
    FilterOp.gt => colNum.isBiggerThan(otherColNum),
    FilterOp.gte => colNum.isBiggerOrEqual(otherColNum),
    FilterOp.lt => colNum.isSmallerThan(otherColNum),
    FilterOp.lte => colNum.isSmallerOrEqual(otherColNum),
  };
}

Expression<bool> _withFaceFallback($ScryfallCardsTable t, AppDatabase db, Expression<bool> cardMatch, Expression<bool> faceCondition) {
  final needsFaceValues = t.layout.isIn(const ['transform', 'modal_dfc', 'meld']);
  return (needsFaceValues & _anyFaceMatches(db, t.scryfallId, faceCondition)) | (needsFaceValues.not() & cardMatch);
}

Expression<bool> _dateCompareExpression(Expression<String> col, FilterOp op, DateTime date) {
  final colDate = col.cast<DateTime>();
  return switch (op) {
    FilterOp.contains || FilterOp.eq => colDate.equals(date),
    FilterOp.ne => colDate.equals(date).not(),
    FilterOp.gt => colDate.isBiggerThanValue(date),
    FilterOp.gte => colDate.isBiggerOrEqualValue(date),
    FilterOp.lt => colDate.isSmallerThanValue(date),
    FilterOp.lte => colDate.isSmallerOrEqualValue(date),
  };
}

const Map<String, String> _hybridCanonicalOrder = {
  'UW': 'WU', 'BU': 'UB', 'RB': 'BR', 'GR': 'RG', 'WG': 'GW', // allied
  'BW': 'WB', 'RU': 'UR', 'GB': 'BG', 'WR': 'RW', 'UG': 'GU', // enemy
};

List<String> _parseManaSymbols(String value) {
  if (value.contains('{')) {
    final matches = RegExp(r'\{([^}]+)\}').allMatches(value);
    return matches.map((m) {
      var symbol = m.group(1)!.toUpperCase();

      String canonicalizeColorPair(String twoColors) {
        return _hybridCanonicalOrder[twoColors] ?? twoColors;
      }

      final phyrexianHybrid = RegExp(r'^([WUBRG])/([WUBRG])/P$').firstMatch(symbol);
      if (phyrexianHybrid != null) {
        final pair = canonicalizeColorPair('${phyrexianHybrid.group(1)}${phyrexianHybrid.group(2)}');
        symbol = '${pair[0]}/${pair[1]}/P';
      } else if (RegExp(r'^[WUBRG]/[WUBRG]$').hasMatch(symbol)) {
        final pair = canonicalizeColorPair(symbol.replaceAll('/', ''));
        symbol = '${pair[0]}/${pair[1]}';
      }

      return '{$symbol}';
    }).toList();
  }
  final upper = value.toUpperCase();
  const validChars = 'WUBRGCSXYZP';
  final symbols = <String>[];
  final digitBuf = StringBuffer();

  void flushDigits() {
    if (digitBuf.isNotEmpty) {
      symbols.add('{${digitBuf.toString()}}');
      digitBuf.clear();
    }
  }

  for (final c in upper.split('')) {
    if (int.tryParse(c) != null) {
      digitBuf.write(c);
    } else if (validChars.contains(c)) {
      flushDigits();
      symbols.add('{$c}');
    } else {
      throw FormatException('Ungültiges Manakosten-Symbol: $value');
    }
  }
  flushDigits();
  return symbols;
}

Expression<String> _stripSymbols(Expression<String> col, Iterable<String> symbols) {
  var expr = col;
  for (final s in symbols) {
    expr = FunctionCallExpression<String>('REPLACE', [expr, Constant(s), const Constant('')]);
  }
  return expr;
}

Expression<bool> _manaCostExpression(Expression<String> col, FilterOp op, String rawValue) {
  final symbols = _parseManaSymbols(rawValue);

  final counts = <String, int>{};
  for (final s in symbols) {
    counts[s] = (counts[s] ?? 0) + 1;
  }

  Expression<int> occurrenceDiff(String symbol) {
    final replaced = FunctionCallExpression<String>(
      'REPLACE',
      [col, Constant(symbol), const Constant('')],
    );
    return FunctionCallExpression<int>('LENGTH', [col]) -
        FunctionCallExpression<int>('LENGTH', [replaced]);
  }

  final hasAll = counts.entries.map((e) => occurrenceDiff(e.key).isBiggerOrEqualValue(e.value * e.key.length)).reduce((a, b) => a & b);
  final matchesExactCounts = counts.entries.map((e) => occurrenceDiff(e.key).equals(e.value * e.key.length)).reduce((a, b) => a & b);
  final atMostCounts = counts.entries.map((e) => occurrenceDiff(e.key).isSmallerOrEqualValue(e.value * e.key.length)).reduce((a, b) => a & b);
  final noOtherSymbols = _stripSymbols(col, counts.keys).equals('');

  final isSubset = noOtherSymbols & atMostCounts;
  final isEqual = matchesExactCounts & noOtherSymbols;

  return switch (op) {
    FilterOp.contains => hasAll,
    FilterOp.eq => isEqual,
    FilterOp.ne => isEqual.not(),
    FilterOp.gte => hasAll,
    FilterOp.gt => hasAll & isEqual.not(),
    FilterOp.lte => isSubset,
    FilterOp.lt => isSubset & isEqual.not(),
  };
}

Expression<bool> _hasHybridSymbol(Expression<String> manaCost) {
  return manaCost.like('%W/U%') | manaCost.like('%W/B%') | manaCost.like('%B/R%') | manaCost.like('%B/G%') | manaCost.like('%U/B%') | manaCost.like('%U/R%') | manaCost.like('%R/G%') | manaCost.like('%R/W%') | manaCost.like('%G/W%') | manaCost.like('%G/U%');
}

Expression<bool> _isExpression($ScryfallCardsTable t, String value, Map<String, List<String>> oracleTagIds, AppDatabase db) {
  // Unsupported:
  // - newinpauper
  // - planeswalker_deck, league, buyabox, giftbox, intro_pack, gameday, prerelease, release, fnm, judge_gift, arena_league, player_rewards, media_insert, instore, convention, set_promo
  // - universesbeyond, default, atypical, new
  // - unique
  // - digital, alchemy, rebalanced, spotlight, scryfallpreview
  // - colorshifted
  switch (value.toLowerCase()) {
    // Mana Costs
    case 'hybrid':
      return _withFaceFallback(t, db, _hasHybridSymbol(t.manaCost), _hasHybridSymbol(db.scryfallCardFaces.manaCost));
    case 'phyrexian':
      return _withFaceFallback(t, db, t.manaCost.like('%/P}%'), db.scryfallCardFaces.manaCost.like('%/P}%'));
    // Multi-faced Cards
    case 'split' || 'flip' || 'transform' || 'meld' || 'leveler' || 'mdfc':
      return t.layout.equals(value.toLowerCase().replaceAll('mdfc', 'modal_dfc'));
    case 'dfc':
      return t.layout.equals('transform') | t.layout.equals('modal_dfc');
    case 'meldpart':
      final cardMelds = t.oracleText.like('%melds with%') | t.oracleText.like('%meld them into%');
      final faceMelds = db.scryfallCardFaces.oracleText.like('%melds with%') | db.scryfallCardFaces.oracleText.like('%meld them into%');
      return t.layout.equals('meld') & (cardMelds | _anyFaceMatches(db, t.scryfallId, faceMelds));
    case 'meldresult':
      final cardMelds = t.oracleText.like('%melds with%') | t.oracleText.like('%meld them into%');
      final faceMelds = db.scryfallCardFaces.oracleText.like('%melds with%') | db.scryfallCardFaces.oracleText.like('%meld them into%');
      return t.layout.equals('meld') & (cardMelds | _anyFaceMatches(db, t.scryfallId, faceMelds)).not();
    // Spells, Permanents, and Effects
    case 'spell':
      return t.typeLine.like('%Instant%') | t.typeLine.like('%Sorcery%');
    case 'permanent':
      return t.typeLine.like('%Creature%') | t.typeLine.like('%Artifact%') | t.typeLine.like('%Enchantment%') | t.typeLine.like('%Planeswalker%') | t.typeLine.like('%Land%') | t.typeLine.like('%Battle%') | t.typeLine.like('%Conspiracy%') | t.typeLine.like('%Phenomenon%') | t.typeLine.like('%Plane%') | t.typeLine.like('%Scheme%');
    case 'historic':
      return t.typeLine.like('%Artifact%') | t.typeLine.like('%Legendary%') | t.typeLine.like('%Saga%');
    case 'party':
      final typeMatch = t.typeLine.like('%Cleric%') | t.typeLine.like('%Rogue%') | t.typeLine.like('%Warrior%') | t.typeLine.like('%Wizard%');
      return typeMatch | _cardOrAnyFace(db, t.scryfallId, t.oracleText.like('%changeling%'), db.scryfallCardFaces.oracleText.like('%changeling%'));
    case 'outlaw':
      final typeMatch = t.typeLine.like('%Rogue%') | t.typeLine.like('%Warlock%') | t.typeLine.like('%Assassin%') | t.typeLine.like('%Pirate%') | t.typeLine.like('%Mercenary%');
      return typeMatch | _cardOrAnyFace(db, t.scryfallId, t.oracleText.like('%changeling%'), db.scryfallCardFaces.oracleText.like('%changeling%'));
    case 'modal':
      final cardModal = t.oracleText.like('%choose%') & t.oracleText.like('%—%');
      final faceModal = db.scryfallCardFaces.oracleText.like('%choose%') & db.scryfallCardFaces.oracleText.like('%—%');
      return cardModal | _anyFaceMatches(db, t.scryfallId, faceModal);
    case 'vanilla':
      final cardVanilla = t.oracleText.isNull() | t.oracleText.equals('');
      final anyFaceHasText = _anyFaceMatches(db, t.scryfallId, db.scryfallCardFaces.oracleText.isNotNull() & db.scryfallCardFaces.oracleText.equals('').not());
      return (t.hasCardFaces.not() & cardVanilla) | (t.hasCardFaces & anyFaceHasText.not());
    case 'frenchvanilla':
      return _tagExpression(t, 'french-vanilla', true, oracleTagIds, const {});
    case 'bear':
      final ptMatch = _withFaceFallback(t, db,
        t.power.equals('2') & t.toughness.equals('2'),
        db.scryfallCardFaces.power.equals('2') & db.scryfallCardFaces.toughness.equals('2'));
      return ptMatch & t.cmc.equals(2);
    // Extra Cards and Funny Cards
    case 'funny':
      return t.setType.equals('funny');
    // Sets and Blocks
    case 'booster':
      return t.booster.equals(true);
    case 'promo': 
      return t.promo.equals(true);
    case 'datestamped':
      return t.securityStamp.equals('date');
    // Format Legality
    case 'commander':
      return _legalityColumn(t, 'commander').equals('legal') & (
        _cardOrAnyFace(db, t.scryfallId, t.oracleText.like('%can be your commander%'), db.scryfallCardFaces.oracleText.like('%can be your commander%')) |
        ((t.typeLine.like('%creature%') | t.typeLine.like('%vehicle%')) & t.typeLine.like('%legendary%')) |
        (t.typeLine.like('Legendary Artifact — Spacecraft') & t.power.isNotNull()) |
        t.typeLine.like('%background%') |
        t.name.equals('Grist, the Hunger Tide'));
    case 'companion':
      return _cardOrAnyFace(db, t.scryfallId, t.oracleText.like('%Companion — %'), db.scryfallCardFaces.oracleText.like('%Companion — %'));
    case 'duelcommander':
      return _legalityColumn(t, 'duel').equals('legal') & (
        _cardOrAnyFace(db, t.scryfallId, t.oracleText.like('%can be your commander%'), db.scryfallCardFaces.oracleText.like('%can be your commander%')) |
        (t.typeLine.like('%creature%') & t.typeLine.like('%legendary%')) |
        t.name.equals('Grist, the Hunger Tide'));
    case 'partner':
      return _cardOrAnyFace(db, t.scryfallId, t.oracleText.like('%Partner%'), db.scryfallCardFaces.oracleText.like('%Partner%'));
    case 'gamechanger':
      return t.gameChanger.equals(true);
    case 'reserved':
      return t.reserved.equals(true);
    // Border, Frame, Foil & Resolution
    case 'full':
      return t.fullArt.equals(true);
    case 'nonfoil':
      return t.foil.equals(false);
    case 'foil':
      return t.foil.equals(true);
    case 'etched':
      return t.etched.equals(true);
    case 'glossy':
      return t.glossy.equals(true);
    case 'hires':
      return t.highresImage.equals(true);
    // Reprints
    case 'reprint':
      return t.reprint.equals(true);
    // Shortcuts and Nicknames
    case 'bikeland':
    case 'cycleland':
    case 'bicycleland':
      return t.oracleText.regexp(r'\(\{T\}: Add \{[WUBRG]\} or \{[WUBRG]\}\.\)\\nThis land enters tapped\.\\nCycling \{2\} \(\{2\}, Discard this card: Draw a card\.\)');
    case 'bondland':
    case 'crowdland':
    case 'bbdland':
    case 'battlebondland':
      return t.oracleText.regexp(r'This land enters tapped unless you have two or more opponents\.\\n\{T\}: Add \{[WUBRG]\} or \{[WUBRG]\}\.');
    case 'bounceland':
    case 'karoo':
      return t.oracleText.regexp(r'When this land enters, return a land you control to its owner’s hand\.') |
        t.oracleText.regexp(r'When this land enters, sacrifice it unless you return an untapped (Plains|Island|Swamp|Mountain|Forest) you control to its owner’s hand\.');
    case 'canopyland':
    case 'canland':
      return t.oracleText.regexp(r'\{T\}, Pay 1 life: Add \{[WUBRG]\} or \{[WUBRG]\}\.\\n\{1\}, \{T\}, Sacrifice this land: Draw a card\.');
    case 'checkland':
      return t.oracleText.regexp(r'This land enters tapped unless you control (an|a) (Plains|Island|Swamp|Mountain|Forest) or (an|a) (Plains|Island|Swamp|Mountain|Forest)\.\\n\{T\}: Add \{[WUBRG]\} or \{[WUBRG]\}\.');
    case 'creatureland':
    case 'manland':
      return _tagExpression(t, 'creatureland', true, oracleTagIds, const {});
    case 'dual':
      return t.oracleText.regexp(r'\(\{T\}: Add \{[WUBRG]\} or \{[WUBRG]\}\.\)') & t.typeLine.regexp(r'Land — (Plains|Island|Swamp|Mountain|Forest)');
    case 'fastland':
      return t.oracleText.regexp(r'This land enters tapped unless you control two or fewer other lands\.\\n\{T\}: Add \{[WUBRG]\}\ or \{[WUBRG]\}\.');
    case 'fetchland':
      return t.oracleText.regexp(r'\{T\}, Pay 1 life, Sacrifice this land: Search your library for (an|a) (Plains|Island|Swamp|Mountain|Forest) or (Plains|Island|Swamp|Mountain|Forest) card, put it onto the battlefield, then shuffle\.');
    case 'filterland':
      return t.oracleText.regexp(r'\{T\}: Add \{C\}\.\\n\{[WUBRG]/[WUBRG]\}, \{T\}: Add \{[WUBRG]\}\{[WUBRG]\}, \{[WUBRG]\}\{[WUBRG]\}, or \{[WUBRG]\}\{[WUBRG]\}\.') |
        t.oracleText.regexp(r'\{1\}, \{T\}: Add \{[WUBRG]\}\{[WUBRG]\}\.') |
        t.name.like('%Cascading Cataracts%') | t.name.like('%Crystal Quarry%');
    case 'gainland':
      return t.oracleText.regexp(r'This land enters tapped\.\\nWhen this land enters, you gain 1 life\.\\n\{T\}: Add \{[WUBRG]\} or \{[WUBRG]\}\.');
    case 'painland':
      return t.oracleText.regexp(r'\{T\}: Add \{C\}\.\\n\{T\}: Add \{[WUBRG]\} or \{[WUBRG]\}\. This land deals 1 damage to you\.');
    case 'pathway':
      return t.typeLine.equals('Land // Land');
    case 'scryland':
      return t.oracleText.regexp(r'This land enters tapped\.\\nWhen this land enters, scry 1\. \(Look at the top card of your library\. You may put that card on the bottom\.\)\\n\{T\}: Add \{[WUBRG]\} or \{[WUBRG]\}\.');
    case 'surveilland':
      return t.oracleText.regexp(r'\(\{T\}: Add \{[WUBRG]\} or \{[WUBRG]\}\.\)\\nThis land enters tapped\.\\nWhen this land enters, surveil 1\. \(Look at the top card of your library\. You may put it into your graveyard\.\)');
    case 'shadowland':
    case 'snarl':
      return t.oracleText.regexp(r'As this land enters, you may reveal (an|a) (Plains|Island|Swamp|Mountain|Forest) or (Plains|Island|Swamp|Mountain|Forest) card from your hand\. If you don\’t, this land enters tapped\.\\n\{T\}: Add \{[WUBRG]\} or \{[WUBRG]\}\.');
    case 'shockland':
      return t.oracleText.regexp(r'\(\{T\}: Add \{[WUBRG]\}\.\)\\nAs this land enters, you may pay 2 life\. If you don’t, it enters tapped\.');
    case 'slowland':
      return t.oracleText.regexp(r'This land enters tapped unless you control two or more other lands\.\\n\{T\}: Add \{[WUBRG]\} or \{[WUBRG]\}\.');
    case 'storageland':
      return t.oracleText.like('%storage counter%') & t.typeLine.like('%Land%');
    case 'tangoland':
    case 'battleland':
      return t.oracleText.regexp(r'\(\{T\}: Add \{[WUBRG]\}\.\)\\nThis land enters tapped unless you control two or more basic lands\.');
    case 'tricycleland':
    case 'trikeland':
    case 'triome':
      return t.oracleText.regexp(r'\(\{T\}: Add \{[WUBRG]\}, \{[WUBRG]\}, or \{[WUBRG]\}\.\)\\nThis land enters tapped\.\\nCycling \{3\} \(\{3\}, Discard this card: Draw a card\.\)');
    case 'triland':
      return t.oracleText.regexp(r'This land enters tapped\.\\n\{T\}: Add \{[WUBRG]\}, \{[WUBRG]\}, or \{[WUBRG]\}\.');
    case 'masterpiece':
      return t.setType.equals('masterpiece');
    // Default
    default:
      throw FormatException('Unbekanntes is: $value');
  }
}

Expression<bool> _tagExpression($ScryfallCardsTable t, String tag, bool isOracleTag, Map<String, List<String>> oracleTagIds, Map<String, List<String>> illustrationTagIds) {
  final lookup = isOracleTag ? oracleTagIds : illustrationTagIds;
  final ids = lookup[tag.toLowerCase()] ?? const <String>[];
  if (ids.isEmpty) return const Constant(false);
  return isOracleTag ? t.oracleId.isIn(ids) : t.illustrationId.isIn(ids);
}

Expression<bool> _blockAndGroupExpression($ScryfallCardsTable t, String code, List<ScryfallSet> allSets, bool isBlock) {
  List<String> sets;
  if (isBlock) {
    sets = allSets.where((s) => s.blockCode?.toLowerCase() == code.toLowerCase()).map((s) => s.code.toLowerCase()).toList();
  } else {
    greatestAncestorSetCode(String code) {
      final set = allSets.firstWhere((s) => s.code.toLowerCase() == code.toLowerCase(), orElse: () => throw FormatException('Unbekannter Set-Code: $code'));
      if (set.parentSetCode == null) return set.code.toLowerCase();
      return greatestAncestorSetCode(set.parentSetCode!);
    }
    // Get all sets that have the same greatest ancestor set code
    final ancestorCode = greatestAncestorSetCode(code);
    if (ancestorCode == null) throw FormatException('Unbekannter Set-Code: $code');
    sets = allSets.where((s) => greatestAncestorSetCode(s.code) == ancestorCode).map((s) => s.code.toLowerCase()).toList();
  }
  if (sets.isEmpty) throw FormatException('Unbekannter Set-Code: $code');
  return t.setCode.isIn(sets);
}

Expression<bool> _anyFaceMatches(AppDatabase db, Expression<String> cardId, Expression<bool> condition) {
  final facesQuery = db.selectOnly(db.scryfallCardFaces)
    ..addColumns([db.scryfallCardFaces.cardId])
    ..where(db.scryfallCardFaces.cardId.equalsExp(cardId) & condition);
  return existsQuery(facesQuery);
}

Expression<bool> _cardOrAnyFace(AppDatabase db, Expression<String> cardId, Expression<bool> cardCondition, Expression<bool> faceCondition) {
  return cardCondition | _anyFaceMatches(db, cardId, faceCondition);
}

Expression<bool> _compileFilter($ScryfallCardsTable t, FilterToken f, Map<String, List<String>> oracleTagIds, Map<String, List<String>> illustrationTagIds, List<ScryfallSet> allSets, AppDatabase db) {
  // TODO: Handle faces
  // Unsupported filters (from the original scryfall syntax):
  // - edhrecrank (not included in scryfall data)
  // - cube (not included in scryfall data)
  // - game (paper only)
  // - new (way to complicated to be worth it)
  switch (f.key) {
    case 'name':
      return t.name.like('%${f.value}%') | t.printedName.like('%${f.value}%') | t.flavorName.like('%${f.value}%');

    // Colors and Color Identity
    case 'c':
    case 'color':
      final cardMatch = _colorMaskExpression(t.colorMask, f.op, f.value, false);
      final faceMatch = _anyFaceMatches(db, t.scryfallId, _colorMaskExpression(db.scryfallCardFaces.colorMask, f.op, f.value, false));
      final needsFaceColors = t.layout.isIn(const ['transform', 'modal_dfc', 'meld']);
      return (needsFaceColors & faceMatch) | (needsFaceColors.not() & cardMatch);

    case 'id':
    case 'identity':
      return _colorMaskExpression(t.colorIdentityMask, f.op, f.value, true);

    // Card Types
    case 't':
    case 'type':
      return t.typeLine.like('%${f.value}%') | t.printedTypeLine.like('%${f.value}%');

    // Card Text
    case 'o':
    case 'oracle':
      final cardPattern = _tildeToNamePattern(t.name, f.value);
      final cardMatch = FunctionCallExpression<bool>('LIKE', [cardPattern, t.oracleText]) | FunctionCallExpression<bool>('LIKE', [cardPattern, t.printedText]);
      final facePattern = _tildeToNamePattern(db.scryfallCardFaces.name, f.value);
      final faceMatch = FunctionCallExpression<bool>('LIKE', [facePattern, db.scryfallCardFaces.oracleText]) | FunctionCallExpression<bool>('LIKE', [facePattern, db.scryfallCardFaces.printedText]);
      return cardMatch | _anyFaceMatches(db, t.scryfallId, faceMatch);

    case 'kw':
    case 'keyword':
      return t.keywordsJson.like('%"${f.value}"%');

    // Mana Costs
    case 'm':
    case 'mana':
      final cardMatch = _manaCostExpression(t.manaCost, f.op, f.value);
      final faceMatch = _anyFaceMatches(db, t.scryfallId, _manaCostExpression(db.scryfallCardFaces.manaCost, f.op, f.value));
      return (t.hasCardFaces & faceMatch) | (t.hasCardFaces.not() & cardMatch);
    
    case 'cmc':
    case 'mv':
      return _numericExpression(t.cmc, f.op, f.value);
    
    case 'produces':
      return _colorMaskExpression(t.producedManaMask, f.op, f.value, false);

    // Power, Toughness, and Loyalty
    case 'pow':
    case 'power':
      if (f.value == 'tou' || f.value == 'toughness') {
        return _withFaceFallback(t, db,
          _powerToughnessCompareExpression(t.power, f.op, t.toughness),
          _powerToughnessCompareExpression(db.scryfallCardFaces.power, f.op, db.scryfallCardFaces.toughness));
      }
      return _withFaceFallback(t, db,
        _numericStringExpression(t.power, f.op, f.value),
        _numericStringExpression(db.scryfallCardFaces.power, f.op, f.value));

    case 'tou':
    case 'toughness':
      if (f.value == 'pow' || f.value == 'power') {
        return _withFaceFallback(t, db,
          _powerToughnessCompareExpression(t.toughness, f.op, t.power),
          _powerToughnessCompareExpression(db.scryfallCardFaces.toughness, f.op, db.scryfallCardFaces.power));
      }
      return _withFaceFallback(t, db,
        _numericStringExpression(t.toughness, f.op, f.value),
        _numericStringExpression(db.scryfallCardFaces.toughness, f.op, f.value));

    case 'loy':
    case 'loyalty':
      return _withFaceFallback(t, db,
        _numericStringExpression(t.loyalty, f.op, f.value),
        _numericStringExpression(db.scryfallCardFaces.loyalty, f.op, f.value));

    // Rarity
    case 'r':
    case 'rarity':
      return _rarityCompareExpression(t.rarityValue, f.op, f.value);

    // Sets and Blocks
    case 's':
    case 'e':
    case 'set':
    case 'edition':
      return t.setCode.equals(f.value.toLowerCase());

    case 'cn':
    case 'number':
      return t.collectorNumber.equals(f.value.toLowerCase());

    case 'b':
    case 'block':
      return _blockAndGroupExpression(t, f.value, allSets, true);
    
    case 'g':
    case 'group':
      return _blockAndGroupExpression(t, f.value, allSets, false);
    
    case 'st':
    case 'set_type':
      return t.setType.equals(f.value.toLowerCase());

    // Format Legality
    case 'f':
    case 'format':
    case 'legality':
    case 'legal':
      return _legalityColumn(t, f.value).equals('legal');

    case 'banned':
      return _legalityColumn(t, f.value).equals('banned');
    
    case 'restricted':
      return _legalityColumn(t, f.value).equals('restricted');

    // USD/EUR/TIX Price
    case 'usd':
      return _numericStringExpression(t.pricesUsd, f.op, f.value);
    
    case 'eur':
      return _numericStringExpression(t.pricesEur, f.op, f.value);
    
    case 'tix':
      return _numericStringExpression(t.pricesTix, f.op, f.value);

    // Artist, Flavor Text and Watermark
    case 'a':
    case 'artist':
      return t.artist.like('%${f.value}%');

    case 'ft':
    case 'flavor':
      return t.flavorText.like('%${f.value}%');

    case 'wm':
    case 'watermark':
      return t.watermark.like('%${f.value}%');
      
    // Border, Frame, Foil & Resolution
    case 'border':
      return t.borderColor.equals(f.value.toLowerCase());

    case 'frame':
      return t.frame.equals(f.value.toLowerCase());
    
    case 'stamp':
      return t.securityStamp.equals(f.value.toLowerCase());

    // Year
    case 'year':
      int year = (f.value == 'now' || f.value == 'today') ? DateTime.now().year : int.tryParse(f.value) ?? 0;
      return _numericExpression(t.releasedAtYear.cast<double>(), f.op, year.toString());
    
    case 'date':
      DateTime date = (f.value == 'now' || f.value == 'today') ? DateTime.now() : DateTime.tryParse(f.value) ?? DateTime(0);
      return _dateCompareExpression(t.releasedAt, f.op, date);

    // Tagger Tags
    case 'art':
    case 'atag':
    case 'arttag':
      return _tagExpression(t, f.value, false, oracleTagIds, illustrationTagIds);

    case 'function':
    case 'tag':
    case 'otag':
    case 'oracletag':
      return _tagExpression(t, f.value, true, oracleTagIds, illustrationTagIds);

    // Languages
    case 'lang':
    case 'language':
      if (f.value.toLowerCase() == 'any') return const Constant(true);
      return t.lang.equals(f.value.toLowerCase());

    // Is and Not
    case 'is':
      return _isExpression(t, f.value, oracleTagIds, db);
    case 'not':
      return _isExpression(t, f.value, oracleTagIds, db).not();

    default:
      return throw FormatException('Unbekannter key: $t.key');
  }
}

Expression<bool> compileQueryToken($ScryfallCardsTable t, QueryToken token, Map<String, List<String>> oracleTagIds, Map<String, List<String>> illustrationTagIds, List<ScryfallSet> allSets, AppDatabase db) {
  if (token is ListToken) {
    if (token.tokens.isEmpty) return const Constant(true);
    final compiled = token.tokens.map((tok) => compileQueryToken(t, tok, oracleTagIds, illustrationTagIds, allSets, db)).toList();
    final combined = compiled.reduce((a, b) => token.isOR ? (a | b) : (a & b));
    return token.isNegated ? combined.not() : combined;
  }
  final f = token as FilterToken;
  final expr = _compileFilter(t, f, oracleTagIds, illustrationTagIds, allSets, db);
  return f.isNegated ? expr.not() : expr;
}