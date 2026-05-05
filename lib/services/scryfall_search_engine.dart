// ---------------------------------------------------------------------------
// Scryfall-compatible local search engine.
//
// Supports the Scryfall search syntax documented at:
//   https://scryfall.com/docs/syntax
//
// Operators implemented:
//   name: (n:), oracle: (o:), fulloracle: (fo:), type: (t:), color: (c:),
//   identity: (id:), rarity: (r:), manavalue: (mv:/cmc:), mana: (m:),
//   pow:/power:, tou:/toughness:, loyalty: (loy:), pt:/powtou:,
//   set: (s:/e:), block: (b:) [basic], in: [basic], cn:/number:,
//   lang:/language:, format: (f:), banned:, restricted:,
//   artist: (a:), flavor: (ft:), keyword: (kw:), watermark: (wm:),
//   game:, border:, frame:, year:, date:, usd:, eur:, tix:,
//   st:/settype:, stamp:,
//   is:, has:, not:, !exactname
//
// Display / meta keywords (applied globally, do not filter individual cards):
//   unique:cards|prints|art, order:<field>, direction:asc|desc
//   prefer: and include: are parsed but currently ignored.
//   new:, cube:, b:/block: are parsed but return no results (insufficient data).
// ---------------------------------------------------------------------------

class ScryfallSearchEngine {
  // =========================================================================
  // Public API
  // =========================================================================

  /// Filters [cards] using a Scryfall-compatible [query] string.
  /// Display keywords (unique:, order:, direction:) are extracted and applied
  /// as post-processing steps.
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

    // Extract display/meta options from all groups; build filter-only groups.
    String uniqueMode = 'cards';
    String orderMode = 'name';
    String directionMode = 'asc';

    final filterGroups = <List<_SearchTerm>>[];
    for (final group in groups) {
      final filterTerms = <_SearchTerm>[];
      for (final term in group) {
        switch (term.kind) {
          case _SearchTermKind.uniqueDisplay:
            uniqueMode = term.value.toLowerCase();
          case _SearchTermKind.orderDisplay:
            orderMode = term.value.toLowerCase();
          case _SearchTermKind.directionDisplay:
            directionMode = term.value.toLowerCase();
          case _SearchTermKind.metaIgnored:
            break; // prefer:, include:, new:, cube:, block: – silently ignored
          default:
            filterTerms.add(term);
        }
      }
      if (filterTerms.isNotEmpty) filterGroups.add(filterTerms);
    }

    List<Map<String, dynamic>> result;
    if (filterGroups.isEmpty) {
      // Query consisted only of meta terms; return all cards.
      result = cards.cast<Map<String, dynamic>>().toList();
    } else {
      result = cards.cast<Map<String, dynamic>>().where((card) {
        return filterGroups.any((group) => _matchesGroup(card, group));
      }).toList();
    }

    result = _applyUnique(result, uniqueMode);
    _applySort(result, orderMode, directionMode);
    return result;
  }

  // =========================================================================
  // Tokenizer
  // =========================================================================

  List<List<_SearchTerm>> _parseQueryGroups(String query) {
    final tokens = _tokenize(query);
    final parsed = _parseGroupsFromTokens(tokens, 0);
    return parsed['groups'] as List<List<_SearchTerm>>;
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
      // Treat parentheses as standalone tokens when not inside quotes
      if (!inQuotes && (character == '(' || character == ')')) {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }
        tokens.add(character);
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

  /// Parses tokens into groups (OR between groups, AND within a group).
  /// Supports parentheses by returning a map with 'groups' and 'nextIndex'.
  Map<String, dynamic> _parseGroupsFromTokens(List<String> tokens, int start) {
    final resultGroups = <List<_SearchTerm>>[];
    var currentGroups = <List<_SearchTerm>>[<_SearchTerm>[]];
    var index = start;

    while (index < tokens.length) {
      final token = tokens[index];

      if (token == ')') {
        break;
      }

      if (token.toLowerCase() == 'or') {
        for (final g in currentGroups) {
          resultGroups.add(g);
        }
        currentGroups = <List<_SearchTerm>>[<_SearchTerm>[]];
        index++;
        continue;
      }

      if (token == '(') {
        final inner = _parseGroupsFromTokens(tokens, index + 1);
        final innerGroups = inner['groups'] as List<List<_SearchTerm>>;
        final nextIndex = inner['nextIndex'] as int;

        final combined = <List<_SearchTerm>>[];
        for (final cg in currentGroups) {
          for (final ig in innerGroups) {
            final newGroup = List<_SearchTerm>.from(cg)..addAll(ig);
            combined.add(newGroup);
          }
        }
        currentGroups = combined;
        index = nextIndex + 1;
        continue;
      }

      // Regular token -> single-term groups
      final term = _parseToken(token);
      final combined = <List<_SearchTerm>>[];
      for (final cg in currentGroups) {
        final newGroup = List<_SearchTerm>.from(cg)..add(term);
        combined.add(newGroup);
      }
      currentGroups = combined;
      index++;
    }

    for (final g in currentGroups) {
      resultGroups.add(g);
    }

    return {'groups': resultGroups, 'nextIndex': index};
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

  // =========================================================================
  // Field → Kind mapping
  // =========================================================================

  _SearchTermKind _fieldToKind(String field) {
    switch (field) {
      // --- Name ---
      case 'name':
      case 'n':
        return _SearchTermKind.name;
      // --- Oracle text ---
      case 'o':
      case 'oracle':
        return _SearchTermKind.oracleText;
      case 'fo':
      case 'fulloracle':
        return _SearchTermKind.fullOracleText;
      // --- Type ---
      case 't':
      case 'type':
        return _SearchTermKind.type;
      // --- Color ---
      case 'c':
      case 'color':
        return _SearchTermKind.color;
      // --- Color identity ---
      case 'id':
      case 'identity':
        return _SearchTermKind.colorIdentity;
      // --- Rarity ---
      case 'r':
      case 'rarity':
        return _SearchTermKind.rarity;
      // --- Mana value ---
      case 'mv':
      case 'manavalue':
      case 'cmc':
        return _SearchTermKind.manaValue;
      // --- Mana cost ---
      case 'm':
      case 'mana':
        return _SearchTermKind.manaCost;
      // --- Power / toughness / loyalty ---
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
      case 'pt':
      case 'powtou':
        return _SearchTermKind.powTou;
      // --- Set ---
      case 's':
      case 'e':
      case 'set':
      case 'edition':
        return _SearchTermKind.set;
      // --- Collector number ---
      case 'cn':
      case 'number':
        return _SearchTermKind.collectorNumber;
      // --- Block (limited support) ---
      case 'b':
      case 'block':
        return _SearchTermKind.metaIgnored; // block_code absent from card bulk data
      // --- In (set/game/set-type appearance) ---
      case 'in':
        return _SearchTermKind.inKeyword;
      // --- Language ---
      case 'lang':
      case 'language':
        return _SearchTermKind.language;
      // --- Format / legality ---
      case 'f':
      case 'format':
      case 'legal':
        return _SearchTermKind.format;
      case 'banned':
        return _SearchTermKind.banned;
      case 'restricted':
        return _SearchTermKind.restricted;
      // --- is: / has: / not: ---
      case 'is':
        return _SearchTermKind.isKeyword;
      case 'has':
        return _SearchTermKind.hasKeyword;
      case 'not':
        return _SearchTermKind.notKeyword;
      // --- Artist / flavor / keyword / watermark ---
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
      case 'wm':
      case 'watermark':
        return _SearchTermKind.watermark;
      // --- Game availability ---
      case 'game':
        return _SearchTermKind.game;
      // --- Border / frame / stamp ---
      case 'border':
        return _SearchTermKind.border;
      case 'frame':
        return _SearchTermKind.frame;
      case 'stamp':
        return _SearchTermKind.stamp;
      // --- Release date ---
      case 'year':
      case 'date':
        return _SearchTermKind.releaseDate;
      // --- Prices ---
      case 'usd':
      case 'eur':
      case 'tix':
        return _SearchTermKind.price;
      // --- Set type ---
      case 'st':
      case 'settype':
        return _SearchTermKind.setType;
      // --- Display / meta keywords ---
      case 'unique':
        return _SearchTermKind.uniqueDisplay;
      case 'order':
        return _SearchTermKind.orderDisplay;
      case 'direction':
        return _SearchTermKind.directionDisplay;
      // --- Meta keywords parsed but not applied locally ---
      case 'prefer':
      case 'include':
      case 'new':
      case 'cube':
      case 'devotion':
      case 'produces':
      case 'cheapest':
      case 'atag':
      case 'arttag':
      case 'otag':
      case 'oracletag':
      case 'function':
      case 'illustrations':
      case 'prints':
      case 'sets':
        return _SearchTermKind.metaIgnored;
      default:
        return _SearchTermKind.looseText;
    }
  }

  // =========================================================================
  // Post-processing: unique deduplication + sorting
  // =========================================================================

  List<Map<String, dynamic>> _applyUnique(
    List<Map<String, dynamic>> cards,
    String mode,
  ) {
    final seen = <String>{};
    return cards.where((card) {
      final String key;
      switch (mode) {
        case 'prints':
          key = card['id']?.toString() ?? '';
        case 'art':
          key = card['illustration_id']?.toString() ??
              card['id']?.toString() ??
              '';
        default: // 'cards'
          key = card['oracle_id']?.toString() ??
              card['name']?.toString() ??
              '';
      }
      if (key.isEmpty) return true;
      return seen.add(key);
    }).toList();
  }

  void _applySort(
    List<Map<String, dynamic>> cards,
    String order,
    String direction,
  ) {
    const rarityOrder = {'common': 0, 'uncommon': 1, 'rare': 2, 'mythic': 3};

    int Function(Map<String, dynamic>, Map<String, dynamic>) comparator;
    switch (order) {
      case 'cmc':
      case 'mv':
        comparator = (a, b) =>
            _doubleValue(a['cmc']).compareTo(_doubleValue(b['cmc']));
      case 'color':
        comparator = (a, b) {
          final ac = (_stringList(a['color_identity'])..sort()).join();
          final bc = (_stringList(b['color_identity'])..sort()).join();
          return ac.compareTo(bc);
        };
      case 'power':
        comparator = (a, b) {
          final ap = double.tryParse(a['power']?.toString() ?? '') ?? -1;
          final bp = double.tryParse(b['power']?.toString() ?? '') ?? -1;
          return ap.compareTo(bp);
        };
      case 'toughness':
        comparator = (a, b) {
          final at = double.tryParse(a['toughness']?.toString() ?? '') ?? -1;
          final bt = double.tryParse(b['toughness']?.toString() ?? '') ?? -1;
          return at.compareTo(bt);
        };
      case 'rarity':
        comparator = (a, b) {
          final ar = rarityOrder[a['rarity']?.toString() ?? ''] ?? -1;
          final br = rarityOrder[b['rarity']?.toString() ?? ''] ?? -1;
          return ar.compareTo(br);
        };
      case 'usd':
        comparator = (a, b) {
          final ap =
              double.tryParse(a['prices']?['usd']?.toString() ?? '') ?? -1;
          final bp =
              double.tryParse(b['prices']?['usd']?.toString() ?? '') ?? -1;
          return ap.compareTo(bp);
        };
      case 'eur':
        comparator = (a, b) {
          final ap =
              double.tryParse(a['prices']?['eur']?.toString() ?? '') ?? -1;
          final bp =
              double.tryParse(b['prices']?['eur']?.toString() ?? '') ?? -1;
          return ap.compareTo(bp);
        };
      case 'tix':
        comparator = (a, b) {
          final ap =
              double.tryParse(a['prices']?['tix']?.toString() ?? '') ?? -1;
          final bp =
              double.tryParse(b['prices']?['tix']?.toString() ?? '') ?? -1;
          return ap.compareTo(bp);
        };
      case 'released':
      case 'date':
        comparator = (a, b) {
          final ad = a['released_at']?.toString() ?? '';
          final bd = b['released_at']?.toString() ?? '';
          return ad.compareTo(bd);
        };
      case 'set':
        comparator = (a, b) {
          final as_ = a['set']?.toString() ?? '';
          final bs = b['set']?.toString() ?? '';
          return as_.compareTo(bs);
        };
      case 'artist':
        comparator = (a, b) {
          final aa = a['artist']?.toString() ?? '';
          final ba = b['artist']?.toString() ?? '';
          return aa.compareTo(ba);
        };
      default: // 'name'
        comparator = (a, b) {
          final nameA = a['name']?.toString() ?? '';
          final nameB = b['name']?.toString() ?? '';
          return nameA.compareTo(nameB);
        };
    }

    if (direction == 'desc') {
      cards.sort((a, b) => comparator(b, a));
    } else {
      cards.sort(comparator);
    }
  }

  // =========================================================================
  // Core matching
  // =========================================================================

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
          .map((f) =>
              (f as Map<String, dynamic>)['oracle_text']?.toString() ?? '')
          .join('\n')
          .toLowerCase();
    }
    return '';
  }

  /// Full oracle text including reminder text.
  /// In Scryfall's bulk data, oracle_text already contains reminder text
  /// (in parentheses), so this is equivalent to [_oracleText].
  String _fullOracleText(Map<String, dynamic> card) => _oracleText(card);

  /// Returns type line from top-level field, falling back to card_faces.
  String _typeLine(Map<String, dynamic> card) {
    final direct = card['type_line']?.toString() ?? '';
    if (direct.isNotEmpty) return direct.toLowerCase();
    final faces = card['card_faces'];
    if (faces is List && faces.isNotEmpty) {
      return faces
          .map((f) =>
              (f as Map<String, dynamic>)['type_line']?.toString() ?? '')
          .join('\n')
          .toLowerCase();
    }
    return '';
  }

  // ignore: long-method
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
      // -----------------------------------------------------------------------
      // Name
      // -----------------------------------------------------------------------
      case _SearchTermKind.exactName:
        return name == term.value.toLowerCase();
      case _SearchTermKind.name:
        return name.contains(term.value.toLowerCase());

      // -----------------------------------------------------------------------
      // Type
      // -----------------------------------------------------------------------
      case _SearchTermKind.type:
        return typeLine.contains(term.value.toLowerCase());

      // -----------------------------------------------------------------------
      // Oracle text
      // -----------------------------------------------------------------------
      case _SearchTermKind.oracleText:
        return oracleText
            .contains(term.value.toLowerCase().replaceAll('~', name));
      case _SearchTermKind.fullOracleText:
        return _fullOracleText(card)
            .contains(term.value.toLowerCase().replaceAll('~', name));

      // -----------------------------------------------------------------------
      // Color / identity
      // -----------------------------------------------------------------------
      case _SearchTermKind.color:
        return _matchesColorQuery(cardColors, term.value, term.operator);
      case _SearchTermKind.colorIdentity:
        return _matchesColorQuery(colorIdentity, term.value, term.operator);

      // -----------------------------------------------------------------------
      // Rarity
      // -----------------------------------------------------------------------
      case _SearchTermKind.rarity:
        return _matchesRarity(rarity, term.value.toLowerCase(), term.operator);

      // -----------------------------------------------------------------------
      // Mana value (mv / cmc)
      // -----------------------------------------------------------------------
      case _SearchTermKind.manaValue:
        final qv = term.value.toLowerCase();
        if (qv == 'even') return manaValue % 2 == 0;
        if (qv == 'odd') return manaValue % 2 != 0;
        return _matchesNumericQuery(
            manaValue, _opValueQuery(term.operator, term.value));

      // -----------------------------------------------------------------------
      // Mana cost
      // -----------------------------------------------------------------------
      case _SearchTermKind.manaCost:
        return _matchesManaCost(card, term.value, term.operator);

      // -----------------------------------------------------------------------
      // Power / toughness / loyalty / combined pt
      // -----------------------------------------------------------------------
      case _SearchTermKind.power:
        return _matchesPowerToughness(
            card['power'], term.value, term.operator);
      case _SearchTermKind.toughness:
        return _matchesPowerToughness(
            card['toughness'], term.value, term.operator);
      case _SearchTermKind.loyalty:
        return _matchesPowerToughness(
            card['loyalty'], term.value, term.operator);
      case _SearchTermKind.powTou:
        final powRaw = card['power']?.toString().trim() ?? '';
        final touRaw = card['toughness']?.toString().trim() ?? '';
        if (powRaw.isEmpty || touRaw.isEmpty) return false;
        final pow = double.tryParse(powRaw);
        final tou = double.tryParse(touRaw);
        if (pow == null || tou == null) return false;
        return _matchesNumericQuery(
            pow + tou, _opValueQuery(term.operator, term.value));

      // -----------------------------------------------------------------------
      // Set / collector number / in: / block
      // -----------------------------------------------------------------------
      case _SearchTermKind.set:
        return setCode == term.value.toLowerCase() ||
            setName.contains(term.value.toLowerCase());
      case _SearchTermKind.collectorNumber:
        final cn = card['collector_number']?.toString() ?? '';
        if (term.operator == ':' || term.operator == '=') {
          return cn == term.value;
        }
        final cnNum = double.tryParse(cn);
        if (cnNum == null) return false;
        return _matchesNumericQuery(
            cnNum, _opValueQuery(term.operator, term.value));
      case _SearchTermKind.inKeyword:
        return _matchesInKeyword(card, term.value, typeLine);

      // -----------------------------------------------------------------------
      // Language
      // -----------------------------------------------------------------------
      case _SearchTermKind.language:
        if (term.value.toLowerCase() == 'any') return true;
        return language.contains(term.value.toLowerCase());

      // -----------------------------------------------------------------------
      // Format legality
      // -----------------------------------------------------------------------
      case _SearchTermKind.format:
        return _matchesFormat(card, term.value.toLowerCase(), 'legal');
      case _SearchTermKind.banned:
        return _matchesFormat(card, term.value.toLowerCase(), 'banned');
      case _SearchTermKind.restricted:
        return _matchesFormat(card, term.value.toLowerCase(), 'restricted');

      // -----------------------------------------------------------------------
      // is: / has: / not:
      // -----------------------------------------------------------------------
      case _SearchTermKind.isKeyword:
        return _matchesIsKeyword(
            card, term.value, typeLine, keywords, cardColors);
      case _SearchTermKind.hasKeyword:
        return _matchesHasKeyword(card, term.value);
      case _SearchTermKind.notKeyword:
        return !_matchesIsKeyword(
            card, term.value, typeLine, keywords, cardColors);

      // -----------------------------------------------------------------------
      // Text fields
      // -----------------------------------------------------------------------
      case _SearchTermKind.artist:
        return _lowerString(card['artist'])
            .contains(term.value.toLowerCase());
      case _SearchTermKind.flavorText:
        return _lowerString(card['flavor_text'])
            .contains(term.value.toLowerCase());
      case _SearchTermKind.keyword:
        return keywords.any((kw) => kw.contains(term.value.toLowerCase()));
      case _SearchTermKind.watermark:
        return _lowerString(card['watermark'])
            .contains(term.value.toLowerCase());

      // -----------------------------------------------------------------------
      // Game / printing metadata
      // -----------------------------------------------------------------------
      case _SearchTermKind.game:
        return _stringList(card['games']).contains(term.value.toLowerCase());
      case _SearchTermKind.border:
        return _lowerString(card['border_color']) == term.value.toLowerCase();
      case _SearchTermKind.frame:
        final fv = term.value.toLowerCase();
        return _lowerString(card['frame']) == fv ||
            _stringList(card['frame_effects']).contains(fv);
      case _SearchTermKind.stamp:
        return _lowerString(card['security_stamp']) ==
            term.value.toLowerCase();

      // -----------------------------------------------------------------------
      // Release date
      // -----------------------------------------------------------------------
      case _SearchTermKind.releaseDate:
        return _matchesReleaseDateQuery(
            card, term.field ?? 'date', term.value, term.operator);

      // -----------------------------------------------------------------------
      // Prices
      // -----------------------------------------------------------------------
      case _SearchTermKind.price:
        return _matchesPriceQuery(
            card, term.field ?? 'usd', term.value, term.operator);

      // -----------------------------------------------------------------------
      // Set type
      // -----------------------------------------------------------------------
      case _SearchTermKind.setType:
        return _lowerString(card['set_type']) == term.value.toLowerCase();

      // -----------------------------------------------------------------------
      // Loose text / meta / unknown
      // -----------------------------------------------------------------------
      case _SearchTermKind.looseText:
        final loose = term.value.toLowerCase();
        return name.contains(loose) ||
            oracleText.contains(loose) ||
            typeLine.contains(loose) ||
            keywords.any((kw) => kw.contains(loose));

      case _SearchTermKind.metaIgnored:
      case _SearchTermKind.uniqueDisplay:
      case _SearchTermKind.orderDisplay:
      case _SearchTermKind.directionDisplay:
        // Meta terms always "pass" – they are extracted before card filtering.
        return true;
    }
  }

  // =========================================================================
  // Color matching
  //
  // Scryfall semantics:
  //   c:wu  / c>=wu  – card includes at least W and U (requested ⊆ card)
  //   c=wu           – card is exactly WU
  //   c>wu           – card is a proper superset of WU
  //   c<=wu          – card uses only colors from {W,U} (card ⊆ requested)
  //   c<wu           – card uses a proper subset of {W,U}
  //   c!=wu          – card is not exactly WU
  //   c=2            – card has exactly 2 colors
  //
  // Supported color group nicknames:
  //   Guilds, Shards, Colleges (Strixhaven), Wedges, 4-color nephilim groups.
  // =========================================================================

  // Map of color group aliases to their component WUBRG letters.
  static const Map<String, String> _colorAliases = {
    // --- Guilds ---
    'azorius': 'wu',
    'dimir': 'ub',
    'rakdos': 'br',
    'gruul': 'rg',
    'selesnya': 'gw',
    'orzhov': 'wb',
    'izzet': 'ur',
    'golgari': 'bg',
    'boros': 'rw',
    'simic': 'gu',
    // --- Shards ---
    'bant': 'gwu',
    'esper': 'wub',
    'grixis': 'ubr',
    'jund': 'brg',
    'naya': 'rgw',
    // --- Wedges ---
    'abzan': 'wbg',
    'jeskai': 'urw',
    'sultai': 'bgu',
    'mardu': 'rwb',
    'temur': 'gur',
    // --- Strixhaven Colleges ---
    'silverquill': 'wb',
    'prismari': 'ur',
    'witherbloom': 'bg',
    'lorehold': 'rw',
    'quandrix': 'gu',
    // --- 4-color nephilim ---
    'chaos': 'ubrg',      // without W
    'aggression': 'brgw', // without U
    'altruism': 'rgwu',   // without B
    'growth': 'gwub',     // without R
    'artifice': 'wubr',   // without G
    // --- 5-color ---
    'all': 'wubrg',
    'rainbow': 'wubrg',
    'wubrg': 'wubrg',
  };

  bool _matchesColorQuery(
      List<String> cardColors, String value, String operator) {
    final normalized = value.toLowerCase().trim();

    // Special keywords
    if (normalized == 'colorless' || normalized == 'c') {
      return operator == '!=' ? cardColors.isNotEmpty : cardColors.isEmpty;
    }
    if (normalized == 'multicolor' || normalized == 'm') {
      return operator == '!='
          ? cardColors.length <= 1
          : cardColors.length > 1;
    }

    // Numeric color count: c=2 means exactly 2 colors, c>=3, etc.
    final numericCount = int.tryParse(normalized);
    if (numericCount != null) {
      final cardCount = cardColors.length;
      switch (operator) {
        case ':':
        case '=':
          return cardCount == numericCount;
        case '>':
          return cardCount > numericCount;
        case '>=':
          return cardCount >= numericCount;
        case '<':
          return cardCount < numericCount;
        case '<=':
          return cardCount <= numericCount;
        case '!=':
          return cardCount != numericCount;
        default:
          return cardCount == numericCount;
      }
    }

    // Resolve color group aliases.
    final resolvedLetters = _colorAliases[normalized] ?? normalized;

    // Extract individual WUBRG letters from the (possibly multi-char) value.
    final requested =
        resolvedLetters.split('').where((c) => 'wubrg'.contains(c)).toSet();
    if (requested.isEmpty) return false;

    final card = cardColors.map((c) => c.toLowerCase()).toSet();

    switch (operator) {
      case ':':
      case '>=':
        // card ⊇ requested
        return requested.every(card.contains);
      case '=':
        // card == requested (exactly)
        return card.length == requested.length &&
            requested.every(card.contains);
      case '>':
        // card ⊃ requested (proper superset)
        return card.length > requested.length &&
            requested.every(card.contains);
      case '<=':
        // card ⊆ requested
        return card.every(requested.contains);
      case '<':
        // card ⊂ requested (proper subset)
        return card.length < requested.length &&
            card.every(requested.contains);
      case '!=':
        return !(card.length == requested.length &&
            requested.every(card.contains));
      default:
        return requested.every(card.contains);
    }
  }

  // =========================================================================
  // Rarity matching  (common < uncommon < rare < mythic)
  // =========================================================================

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

  // =========================================================================
  // Power / toughness / loyalty matching
  // =========================================================================

  bool _matchesPowerToughness(
      dynamic rawValue, String queryValue, String operator) {
    final s = rawValue?.toString().trim() ?? '';
    if (s.isEmpty) return false;

    if (queryValue == '*') {
      return s.contains('*');
    }

    // Cards with variable P/T are excluded from numeric comparisons.
    if (s.contains('*') || s.contains('+') || s == '?') {
      return false;
    }

    final value = double.tryParse(s);
    if (value == null) return false;

    return _matchesNumericQuery(value, _opValueQuery(operator, queryValue));
  }

  // =========================================================================
  // Mana cost matching
  //
  // Supports:
  //   m:3WU   – cost contains those symbols (normalized, `:` = `>=` superset)
  //   m=2WW   – exact cost match
  //   m>3WU   – cost is a proper superset of 3WU
  //   m>=WU   – cost is a superset of WU
  //   m<WW    – cost is a proper subset of WW
  //   m<=WW   – cost is a subset of WW
  //   m!={R}  – cost is not exactly {R}
  // =========================================================================

  bool _matchesManaCost(
      Map<String, dynamic> card, String value, String operator) {
    final raw = card['mana_cost']?.toString() ?? '';
    if (raw.isEmpty) return false;

    final normalizedCost =
        raw.toLowerCase().replaceAll('{', '').replaceAll('}', '');
    final normalizedQuery =
        value.toLowerCase().replaceAll('{', '').replaceAll('}', '');

    switch (operator) {
      case '=':
        return normalizedCost == normalizedQuery;
      case '!=':
        return normalizedCost != normalizedQuery;
      case ':':
      case '>=':
        return _manaCostContainsAll(raw, value);
      case '>':
        return _manaCostContainsAll(raw, value) &&
            normalizedCost != normalizedQuery;
      case '<=':
        return _manaCostContainsAll(value, raw);
      case '<':
        return _manaCostContainsAll(value, raw) &&
            normalizedCost != normalizedQuery;
      default:
        return normalizedCost.contains(normalizedQuery);
    }
  }

  /// Returns true when every mana symbol in [queryMana] appears at least as
  /// many times in [cardMana] (multiset superset / "contains all" check).
  bool _manaCostContainsAll(String cardMana, String queryMana) {
    final cardSymbols = _parseManaSymbols(cardMana);
    final querySymbols = _parseManaSymbols(queryMana);
    for (final entry in querySymbols.entries) {
      if ((cardSymbols[entry.key] ?? 0) < entry.value) return false;
    }
    return true;
  }

  /// Parses a mana cost string into a multiset of normalized symbol strings.
  /// e.g. "{2}{W}{W}" → {'2': 1, 'W': 2}
  /// Non-braced shorthand (e.g. "2WW") is also supported.
  Map<String, int> _parseManaSymbols(String cost) {
    final upper = cost.toUpperCase();
    final symbols = <String, int>{};

    // Extract {X} style symbols.
    final bracketPattern = RegExp(r'\{([^}]+)\}');
    var remaining = upper;
    for (final match in bracketPattern.allMatches(upper)) {
      final sym = match.group(1)!;
      symbols[sym] = (symbols[sym] ?? 0) + 1;
    }
    remaining = upper.replaceAll(bracketPattern, '');

    // Handle non-braced remainder.
    for (var i = 0; i < remaining.length; i++) {
      final ch = remaining[i];
      if ('WUBRG'.contains(ch)) {
        symbols[ch] = (symbols[ch] ?? 0) + 1;
      } else if (RegExp(r'\d').hasMatch(ch)) {
        // Group consecutive digits as a single generic-mana value.
        var numStr = ch;
        while (i + 1 < remaining.length &&
            RegExp(r'\d').hasMatch(remaining[i + 1])) {
          numStr += remaining[++i];
        }
        // Represent generic mana as the numeric string.
        symbols[numStr] = (symbols[numStr] ?? 0) + 1;
      }
    }

    return symbols;
  }

  // =========================================================================
  // Release date matching  (year: and date:)
  // =========================================================================

  bool _matchesReleaseDateQuery(
    Map<String, dynamic> card,
    String fieldName,
    String value,
    String operator,
  ) {
    final releasedAt = card['released_at']?.toString() ?? '';
    if (releasedAt.isEmpty) return false;

    final lowerValue = value.toLowerCase();
    String cardDate;
    String queryDate;

    if (fieldName == 'year') {
      // Compare year portion only.
      cardDate = releasedAt.length >= 4 ? releasedAt.substring(0, 4) : releasedAt;
      queryDate = value;
    } else {
      // date: – full ISO date comparison.
      cardDate = releasedAt;
      if (lowerValue == 'now' || lowerValue == 'today') {
        final now = DateTime.now();
        queryDate =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      } else if (RegExp(r'^\d{4}$').hasMatch(value)) {
        // Year-only value inside date: – compare year portion.
        cardDate = releasedAt.length >= 4 ? releasedAt.substring(0, 4) : releasedAt;
        queryDate = value;
      } else {
        queryDate = value;
      }
    }

    final cmp = cardDate.compareTo(queryDate);
    switch (operator) {
      case ':':
      case '=':
        return cardDate.startsWith(queryDate);
      case '>':
        return cmp > 0;
      case '>=':
        return cmp >= 0;
      case '<':
        return cmp < 0;
      case '<=':
        return cmp <= 0;
      case '!=':
        return !cardDate.startsWith(queryDate);
      default:
        return cardDate.startsWith(queryDate);
    }
  }

  // =========================================================================
  // Price matching  (usd:, eur:, tix:)
  // =========================================================================

  bool _matchesPriceQuery(
    Map<String, dynamic> card,
    String currency,
    String value,
    String operator,
  ) {
    final prices = card['prices'];
    if (prices is! Map) return false;
    final priceStr = prices[currency]?.toString();
    if (priceStr == null) return false;
    final price = double.tryParse(priceStr);
    if (price == null) return false;
    return _matchesNumericQuery(price, _opValueQuery(operator, value));
  }

  // =========================================================================
  // in: keyword matching  (game, set-type, set code)
  // =========================================================================

  bool _matchesInKeyword(
    Map<String, dynamic> card,
    String value,
    String typeLine,
  ) {
    final v = value.toLowerCase();
    // Game availability
    if (const {'paper', 'mtgo', 'arena'}.contains(v)) {
      return _stringList(card['games']).contains(v);
    }
    // Set type (st: aliases)
    const setTypes = {
      'core', 'expansion', 'masters', 'commander', 'draftinnovation',
      'funny', 'memorabilia', 'promo', 'token', 'alchemy', 'starter',
      'planechase', 'archenemy', 'vanguard', 'masterpiece', 'spellbook',
      'premium_deck', 'from_the_vault', 'treasure_chest',
    };
    if (setTypes.contains(v)) {
      return _lowerString(card['set_type']) == v;
    }
    // Fall back to set code match.
    return _lowerString(card['set']) == v;
  }

  // =========================================================================
  // Format / legality matching
  // =========================================================================

  bool _matchesFormat(
      Map<String, dynamic> card, String format, String status) {
    final legalities = card['legalities'];
    if (legalities is! Map) return false;
    return legalities[format]?.toString() == status;
  }

  // =========================================================================
  // is: keyword matching
  // =========================================================================

  // Hardcoded canonical dual land names.
  static const Set<String> _dualLandNames = {
    'tundra', 'underground sea', 'badlands', 'taiga', 'savannah',
    'scrubland', 'volcanic island', 'bayou', 'plateau', 'tropical island',
  };

  // Hardcoded canonical fetchland names (Onslaught + Zendikar + MH3 reprints).
  static const Set<String> _fetchlandNames = {
    'flooded strand', 'polluted delta', 'bloodstained mire',
    'wooded foothills', 'windswept heath',
    'scalding tarn', 'verdant catacombs', 'arid mesa',
    'misty rainforest', 'marsh flats',
    'prismatic vista', 'fabled passage',
  };

  // ignore: long-method
  bool _matchesIsKeyword(
    Map<String, dynamic> card,
    String rawValue,
    String typeLine,
    List<String> keywords,
    List<String> colors,
  ) {
    final value = rawValue.toLowerCase();
    switch (value) {
      // -----------------------------------------------------------------------
      // Card types
      // -----------------------------------------------------------------------
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

      // -----------------------------------------------------------------------
      // Supertypes
      // -----------------------------------------------------------------------
      case 'legendary':
        return typeLine.contains('legendary');
      case 'basic':
        return typeLine.contains('basic');
      case 'snow':
        return typeLine.contains('snow');
      case 'world':
        return typeLine.contains('world');

      // -----------------------------------------------------------------------
      // Color properties
      // -----------------------------------------------------------------------
      case 'multicolor':
      case 'multi':
        return colors.length > 1;
      case 'colorless':
        return colors.isEmpty;
      case 'monocolored':
      case 'mono':
        return colors.length == 1;

      // -----------------------------------------------------------------------
      // Card categories
      // -----------------------------------------------------------------------
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

      // -----------------------------------------------------------------------
      // Vanilla / French vanilla / bear
      // -----------------------------------------------------------------------
      case 'vanilla':
        return typeLine.contains('creature') &&
            _oracleText(card).trim().isEmpty;
      case 'frenchvanilla':
        if (!typeLine.contains('creature')) return false;
        final oracle = _oracleText(card);
        if (oracle.trim().isEmpty) return true; // vanilla ⊆ french vanilla
        if (keywords.isEmpty) return false;
        // Remove all keyword names from oracle text; only whitespace/commas
        // should remain.
        var remaining = oracle;
        for (final kw in keywords) {
          remaining = remaining.replaceAll(
              RegExp(RegExp.escape(kw), caseSensitive: false), '');
        }
        return remaining.replaceAll(RegExp(r'[,\s\n]'), '').isEmpty;
      case 'bear':
        if (!typeLine.contains('creature')) return false;
        final oracle = _oracleText(card);
        return card['power']?.toString().trim() == '2' &&
            card['toughness']?.toString().trim() == '2' &&
            oracle.trim().isEmpty;

      // -----------------------------------------------------------------------
      // Card flags (boolean fields)
      // -----------------------------------------------------------------------
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
      case 'etched':
        return _stringList(card['finishes']).contains('etched');
      case 'glossy':
        return _stringList(card['finishes']).contains('glossy');
      case 'oversized':
        return card['oversized'] == true;
      case 'full':
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
      case 'reserved':
        return card['reserved'] == true;
      case 'hires':
        return card['highres_image'] == true;

      // -----------------------------------------------------------------------
      // Format-legality based
      // -----------------------------------------------------------------------
      case 'commander':
        // Can be your Commander: legendary creature or legendary planeswalker,
        // plus any card with "can be your commander" oracle text.
        if (typeLine.contains('legendary') &&
            typeLine.contains('creature')) return true;
        if (typeLine.contains('legendary') &&
            typeLine.contains('planeswalker')) return true;
        return _oracleText(card).contains('can be your commander');
      case 'brawler':
        // Eligible Brawl commander: legendary creature or planeswalker in brawl.
        if (!typeLine.contains('legendary')) return false;
        if (!typeLine.contains('creature') &&
            !typeLine.contains('planeswalker')) return false;
        final legalities = card['legalities'];
        if (legalities is! Map) return false;
        return legalities['standardbrawl'] == 'legal' ||
            legalities['brawl'] == 'legal';
      case 'duelcommander':
        if (typeLine.contains('legendary') &&
            typeLine.contains('creature')) return true;
        if (typeLine.contains('legendary') &&
            typeLine.contains('planeswalker')) return true;
        return _oracleText(card).contains('can be your commander');
      case 'oathbreaker':
        return typeLine.contains('planeswalker');
      case 'companion':
        return keywords.contains('companion');
      case 'partner':
        return keywords.contains('partner') ||
            _oracleText(card).contains('partner with');

      // -----------------------------------------------------------------------
      // Creature sub-archetypes
      // -----------------------------------------------------------------------
      case 'manland':
        if (!typeLine.contains('land')) return false;
        final oracle = _oracleText(card);
        return (oracle.contains('becomes a') || oracle.contains('become a')) &&
            oracle.contains('creature');
      case 'party':
        if (!typeLine.contains('creature')) return false;
        return typeLine.contains('cleric') ||
            typeLine.contains('rogue') ||
            typeLine.contains('warrior') ||
            typeLine.contains('wizard');
      case 'outlaw':
        if (!typeLine.contains('creature')) return false;
        return typeLine.contains('assassin') ||
            typeLine.contains('mercenary') ||
            typeLine.contains('pirate') ||
            typeLine.contains('rogue') ||
            typeLine.contains('warlock');

      // -----------------------------------------------------------------------
      // Effect types
      // -----------------------------------------------------------------------
      case 'modal':
        final oracle = _oracleText(card);
        return oracle.contains('choose one') ||
            oracle.contains('choose two') ||
            oracle.contains('choose three') ||
            oracle.contains('choose any number') ||
            oracle.contains('choose up to') ||
            oracle.contains('• ');

      // -----------------------------------------------------------------------
      // Mana symbol properties
      // -----------------------------------------------------------------------
      case 'hybrid':
        final mana = card['mana_cost']?.toString().toUpperCase() ?? '';
        return RegExp(r'\{[WUBRG2]/[WUBRG]\}').hasMatch(mana);
      case 'phyrexian':
        final mana = card['mana_cost']?.toString().toUpperCase() ?? '';
        return mana.contains('/P}');

      // -----------------------------------------------------------------------
      // Card layout
      // -----------------------------------------------------------------------
      case 'split':
        return card['layout']?.toString() == 'split';
      case 'flip':
        return card['layout']?.toString() == 'flip';
      case 'transform':
      case 'tdfc':
        return card['layout']?.toString() == 'transform';
      case 'meld':
        return card['layout']?.toString() == 'meld';
      case 'leveler':
        return card['layout']?.toString() == 'leveler';
      case 'dfc':
        final layout = card['layout']?.toString() ?? '';
        return layout == 'transform' ||
            layout == 'modal_dfc' ||
            layout == 'meld';
      case 'mdfc':
        return card['layout']?.toString() == 'modal_dfc';
      case 'meldpart':
        return card['layout']?.toString() == 'meld' &&
            _oracleText(card).contains('melds with');
      case 'meldresult':
        return card['layout']?.toString() == 'meld' &&
            !_oracleText(card).contains('melds with');

      // -----------------------------------------------------------------------
      // Set / printing type
      // -----------------------------------------------------------------------
      case 'funny':
        return card['set_type']?.toString() == 'funny';
      case 'masterpiece':
        return card['set_type']?.toString() == 'masterpiece';
      case 'alchemy':
        return card['set_type']?.toString() == 'alchemy';
      case 'rebalanced':
        return _stringList(card['frame_effects']).contains('rebalanced');
      case 'universesbeyond':
        // Universes Beyond cards carry a 'universesbeyond' frame effect in
        // Scryfall's bulk data. This is the most reliable local indicator.
        return _stringList(card['frame_effects']).contains('universesbeyond');

      // -----------------------------------------------------------------------
      // Frame era / visual
      // -----------------------------------------------------------------------
      case 'old':
        final frame = card['frame']?.toString() ?? '';
        return frame == '1993' || frame == '1997';
      case 'new':
        final frame = card['frame']?.toString() ?? '';
        return frame == '2003' || frame == '2015' || frame == 'future';
      case 'colorshifted':
        return _stringList(card['frame_effects']).contains('colorshifted');

      // -----------------------------------------------------------------------
      // Convenience shortcuts / named card groups
      // -----------------------------------------------------------------------
      case 'dual':
        return _dualLandNames.contains(_lowerString(card['name']));
      case 'fetchland':
        return _fetchlandNames.contains(_lowerString(card['name']));
      case 'scryfallpreview':
        final preview = card['preview'];
        return preview is Map && preview.isNotEmpty;

      // -----------------------------------------------------------------------
      // Unsupported (require tagger, cross-print, or external data)
      // -----------------------------------------------------------------------
      case 'gamechanger':
      case 'newinpauper':
      case 'unique':
        return false;

      // -----------------------------------------------------------------------
      // Default: check keyword abilities list
      // -----------------------------------------------------------------------
      default:
        return keywords.contains(value);
    }
  }

  // =========================================================================
  // has: keyword matching
  // =========================================================================

  bool _matchesHasKeyword(Map<String, dynamic> card, String value) {
    switch (value.toLowerCase()) {
      case 'watermark':
        return (card['watermark']?.toString() ?? '').isNotEmpty;
      case 'indicator':
        final ci = card['color_indicator'];
        return ci is List && ci.isNotEmpty;
      case 'foil':
        return _stringList(card['finishes']).contains('foil');
      case 'nonfoil':
        return _stringList(card['finishes']).contains('nonfoil');
      case 'etched':
        return _stringList(card['finishes']).contains('etched');
      case 'flavor':
      case 'flavortext':
        return (card['flavor_text']?.toString() ?? '').isNotEmpty;
      case 'artist':
        return (card['artist']?.toString() ?? '').isNotEmpty;
      case 'reminder':
        // Check for parenthesized reminder text in oracle.
        return RegExp(r'\([^)]+\)').hasMatch(_oracleText(card));
      default:
        return false;
    }
  }

  // =========================================================================
  // Numeric query helpers
  // =========================================================================

  /// Combine operator and value into a single string for [_matchesNumericQuery].
  /// ':' is treated as '=' for numeric fields.
  String _opValueQuery(String operator, String value) {
    final op = operator == ':' ? '=' : operator;
    return '$op$value';
  }

  bool _matchesNumericQuery(double value, String rawQuery) {
    final comparison =
        RegExp(r'^(>=|<=|!=|>|<|=)?\s*([0-9]+(?:\.[0-9]+)?)$')
            .firstMatch(rawQuery.trim());
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

  // =========================================================================
  // Utility helpers
  // =========================================================================

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
    if (sanitized.length >= 2 &&
        sanitized.startsWith('"') &&
        sanitized.endsWith('"')) {
      return sanitized.substring(1, sanitized.length - 1);
    }
    return sanitized;
  }
}

// =============================================================================
// Internal data model
// =============================================================================

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
  // --- Text matching ---
  looseText,
  exactName,
  name,
  type,
  oracleText,
  fullOracleText,
  // --- Color ---
  color,
  colorIdentity,
  // --- Numeric card stats ---
  rarity,
  manaValue,
  manaCost,
  power,
  toughness,
  loyalty,
  powTou,
  // --- Set / printing ---
  set,
  collectorNumber,
  inKeyword,
  language,
  // --- Legality ---
  format,
  banned,
  restricted,
  // --- is: / has: / not: ---
  isKeyword,
  hasKeyword,
  notKeyword,
  // --- Text fields ---
  artist,
  flavorText,
  keyword,
  watermark,
  // --- Printing metadata ---
  game,
  border,
  frame,
  stamp,
  releaseDate,
  price,
  setType,
  // --- Display / meta keywords ---
  uniqueDisplay,
  orderDisplay,
  directionDisplay,
  metaIgnored,
}
