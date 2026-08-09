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
      flush();
      buf.write(c);
      flush();
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

bool containsTokenFilter(List<QueryToken> tokens) {
  bool check(QueryToken t) {
    if (t is FilterToken) return (t.key == 't' || t.key == 'type') && t.value.toLowerCase() == 'token';
    if (t is ListToken) return t.tokens.any(check);
    return false;
  }
  return tokens.any(check);
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

void sortCards(List<ScryfallCard> cards, String orderBy, String orderDir) {
  int cmp(ScryfallCard a, ScryfallCard b) {
    final result = switch (orderBy) {
      'name' => a.name.compareTo(b.name),
      'released_at' => a.releasedAt.compareTo(b.releasedAt),
      'set' => a.setCode.compareTo(b.setCode),
      'rarity' => a.rarity.compareTo(b.rarity),
      'color' => a.colorMask.compareTo(b.colorMask),
      'cmc' => a.cmc.compareTo(b.cmc),
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

Expression<bool> _compileFilter($ScryfallCardsTable t, FilterToken f) {
  switch (f.key) {
    case 'name':
      return t.name.like('%${f.value}%') | t.printedName.like('%${f.value}%');

    case 'c':
    case 'color':
      return _colorMaskExpression(t.colorMask, f.op, f.value, false);

    case 'id':
    case 'identity':
      return _colorMaskExpression(t.colorIdentityMask, f.op, f.value, true);

    case 't':
    case 'type':
      return t.typeLine.like('%${f.value}%') | t.printedTypeLine.like('%${f.value}%');

    case 'o':
    case 'oracle':
      final pattern = _tildeToNamePattern(t.name, f.value);
      return FunctionCallExpression<bool>('LIKE', [pattern, t.oracleText]) | FunctionCallExpression<bool>('LIKE', [pattern, t.printedText]);

    case 'kw':
    case 'keyword':
      return t.keywordsJson.like('%"${f.value}"%');

    case 's':
    case 'e':
    case 'set':
    case 'edition':
      return t.setCode.equals(f.value.toLowerCase());

    case 'a':
    case 'artist':
      return t.artist.like('%${f.value}%');

    case 'ft':
    case 'flavor':
      return t.flavorText.like('%${f.value}%');

    case 'cmc':
    case 'mv':
      return _numericExpression(t.cmc, f.op, f.value);

    case 'f':
    case 'format':
    case 'legality':
    case 'legal':
      return _legalityColumn(t, f.value).equals('legal');

    case 'lang':
    case 'language':
      if (f.value.toLowerCase() == 'any') return const Constant(true);
      return t.lang.equals(f.value.toLowerCase());

    default:
      return const Constant(true);
  }
}

Expression<bool> compileQueryToken($ScryfallCardsTable t, QueryToken token) {
  if (token is ListToken) {
    if (token.tokens.isEmpty) return const Constant(true);
    final compiled = token.tokens.map((tok) => compileQueryToken(t, tok)).toList();
    final combined = compiled.reduce((a, b) => token.isOR ? (a | b) : (a & b));
    return token.isNegated ? combined.not() : combined;
  }
  final f = token as FilterToken;
  final expr = _compileFilter(t, f);
  return f.isNegated ? expr.not() : expr;
}