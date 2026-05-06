import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/localization_service.dart';

// ---------------------------------------------------------------------------
// Search Syntax Reference Page
//
// Displays the full Scryfall search syntax reference.
// Features:
//   • Filter field to search sections by title or keyword.
//   • Table-of-contents modal bottom sheet (AppBar list icon).
//   • Copy-to-clipboard button on every example block.
//   • "Try this search" button that pops the page with the example query so
//     the caller can pre-populate the search field.
//   • SelectionArea wraps the content for cross-paragraph text selection.
// ---------------------------------------------------------------------------

class SearchSyntaxPage extends StatefulWidget {
  const SearchSyntaxPage({super.key});

  @override
  State<SearchSyntaxPage> createState() => _SearchSyntaxPageState();
}

class _SearchSyntaxPageState extends State<SearchSyntaxPage> {
  final _scrollController = ScrollController();
  final _filterController = TextEditingController();
  String _filter = '';

  // Section titles — must remain in the same order as the _buildSections list.
  static const List<String> _sectionTitles = [
    'Colors and Color Identity',
    'Card Types',
    'Card Text',
    'Mana Costs',
    'Power, Toughness, and Loyalty',
    'Multi-faced Cards',
    'Spells, Permanents, and Effects',
    'Extra Cards and Funny Cards',
    'Rarity',
    'Sets and Blocks',
    'Cubes',
    'Format Legality',
    'USD/EUR/TIX Prices',
    'Artist, Flavor Text and Watermark',
    'Border, Frame, Foil & Resolution',
    'Games, Promos, & Spotlights',
    'Year',
    'Tagger Tags',
    'Reprints',
    'Languages',
    'Shortcuts and Nicknames',
    'Negating Conditions',
    'Regular Expressions',
    'Exact Names',
    'Using "OR"',
    'Nesting Conditions',
    'Display Keywords',
  ];

  late final List<GlobalKey> _sectionKeys;

  @override
  void initState() {
    super.initState();
    _sectionKeys = List.generate(_sectionTitles.length, (_) => GlobalKey());
    _filterController.addListener(() {
      setState(() => _filter = _filterController.text.toLowerCase().trim());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _filterController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Table of contents
  // ---------------------------------------------------------------------------

  void _showToC() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        final theme = Theme.of(context);
        final visible = <int>[
          for (var i = 0; i < _sectionTitles.length; i++)
            if (_filter.isEmpty ||
                _sectionTitles[i].toLowerCase().contains(_filter))
              i,
        ];
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          expand: false,
          builder: (_, sheetScroll) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  appLocalizations.translate('search.tocTitle'),
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  controller: sheetScroll,
                  itemCount: visible.length,
                  itemBuilder: (_, i) {
                    final idx = visible[i];
                    return ListTile(
                      dense: true,
                      title: Text(_sectionTitles[idx]),
                      onTap: () {
                        Navigator.of(sheetCtx).pop();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          final ctx = _sectionKeys[idx].currentContext;
                          if (ctx != null) {
                            Scrollable.ensureVisible(
                              ctx,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Widget helpers
  // ---------------------------------------------------------------------------

  /// Wraps a group of content widgets into a named section.
  /// The section is hidden when [_filter] is non-empty and does not match
  /// [title] (case-insensitive).
  Widget _section(int index, String title, List<Widget> children) {
    if (_filter.isNotEmpty && !title.toLowerCase().contains(_filter)) {
      return const SizedBox.shrink();
    }
    return KeyedSubtree(
      key: _sectionKeys[index],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 28),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _para(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
      );

  Widget _example(String text) {
    final theme = Theme.of(context);
    final loc = appLocalizations;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                text,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_outlined, size: 17),
            tooltip: loc.translate('search.copiedToClipboard'),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loc.translate('search.copiedToClipboard')),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search, size: 17),
            tooltip: loc.translate('search.tryThisSearch'),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
            onPressed: () => Navigator.of(context).pop(text),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = appLocalizations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scryfall Search Reference'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt_outlined),
            tooltip: loc.translate('search.tocTitle'),
            onPressed: _showToC,
          ),
        ],
      ),
      body: SafeArea(
        child: SelectionArea(
          child: Column(
            children: [
              // ---- Filter field ----
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _filterController,
                  decoration: InputDecoration(
                    hintText: loc.translate('search.syntaxFilterHint'),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _filter.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: _filterController.clear,
                          )
                        : null,
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),

              // ---- Content ----
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Introductory hero card (only shown without a filter)
                        if (_filter.isEmpty)
                          Card(
                            margin:
                                const EdgeInsets.only(top: 4, bottom: 4),
                            child: ListTile(
                              leading: Icon(Icons.info_outline,
                                  color: theme.colorScheme.primary),
                              title: const Text('Scryfall Search Reference'),
                              subtitle: const Text(
                                'These keywords are supported by the local offline '
                                'search engine. Tap the search icon on any example '
                                'to try it immediately.',
                              ),
                              isThreeLine: true,
                            ),
                          ),

                        // ---- 0: Colors and Color Identity ----
                        _section(0, _sectionTitles[0], [
                          _para(
                              'Find cards of a certain color with c: or color:, '
                              'and a certain color identity with id: or identity:.'),
                          _para(
                              'Accepts full color names (blue) or letters (w u b r g). '
                              'Nicknames for guilds (azorius), shards (bant), wedges (abzan), '
                              'colleges (quandrix), and four-color groups (chaos) are all supported.'),
                          _para(
                              'Use colorless / c for colorless cards, and multicolor / m for multi-color cards. '
                              'Comparison operators (>, <, >=, <=, !=) and numeric counts (c=2) are supported.'),
                          _example('c:rg'),
                          _example('color>=uw -c:red'),
                          _example('id<=esper t:instant'),
                          _example('c=2 is:bear'),
                          _example('id:c t:land'),
                        ]),

                        // ---- 1: Card Types ----
                        _section(1, _sectionTitles[1], [
                          _para(
                              'Find cards of a certain type with t: or type:. '
                              'Searches supertypes, card types, and subtypes. Partial words are allowed.'),
                          _example('t:merfolk t:legend'),
                          _example('t:goblin -t:creature'),
                        ]),

                        // ---- 2: Card Text ----
                        _section(2, _sectionTitles[2], [
                          _para(
                              'Use o: or oracle: to find cards with specific phrases in their text box. '
                              'Wrap multi-word phrases in quotes.'),
                          _para(
                              'Use ~ as a placeholder for the card\'s own name. '
                              'fo: / fulloracle: also searches reminder text inside parentheses.'),
                          _para('Use kw: or keyword: to search for keyword abilities.'),
                          _example('o:draw t:creature'),
                          _example('o:"~ enters tapped"'),
                          _example('fo:reminder kw:flying'),
                          _example('kw:flying -t:creature'),
                        ]),

                        // ---- 3: Mana Costs ----
                        _section(3, _sectionTitles[3], [
                          _para(
                              'Use m: or mana: to search for cards with certain symbols in their mana cost. '
                              'Shorthand like G is allowed; complex symbols like {2/G} must be in braces.'),
                          _para(
                              'Comparison operators apply set-subset logic: m>=WU finds cards whose cost '
                              'is a superset of {W}{U}.'),
                          _para(
                              'Use mv: or manavalue: (or cmc:) to find cards by mana value. '
                              'manavalue:even and manavalue:odd are also supported.'),
                          _para(
                              'is:hybrid and is:phyrexian filter by mana symbol type.'),
                          _example('mana:{G}{U}'),
                          _example('m:2WW'),
                          _example('m>{R}'),
                          _example('c:u mv=5'),
                          _example('mv<=2 is:instant'),
                          _example('manavalue:even c:r'),
                        ]),

                        // ---- 4: Power, Toughness, and Loyalty ----
                        _section(4, _sectionTitles[4], [
                          _para(
                              'Use pow: / power:, tou: / toughness:, loy: / loyalty:, or pt: / powtou: '
                              'with numeric expressions (>, <, =, >=, <=, !=) or the wildcard * for variable stats.'),
                          _para(
                              'Cross-field comparisons are supported: pow>tou finds creatures '
                              'whose power exceeds their toughness.'),
                          _example('pow>=8'),
                          _example('pow>tou c:w t:creature'),
                          _example('pow=* t:creature'),
                          _example('t:planeswalker loy=3'),
                          _example('pt>=10'),
                        ]),

                        // ---- 5: Multi-faced Cards ----
                        _section(5, _sectionTitles[5], [
                          _para(
                              'is:split · is:flip · is:transform (alias tdfc) · is:meld · '
                              'is:leveler · is:dfc (all double-faced) · is:mdfc (modal double-faced).'),
                          _para(
                              'is:meldpart and is:meldresult distinguish the parts from the result.'),
                          _example('is:meld'),
                          _example('is:mdfc c:u'),
                          _example('is:transform t:land'),
                        ]),

                        // ---- 6: Spells, Permanents, and Effects ----
                        _section(6, _sectionTitles[6], [
                          _para(
                              'is:spell · is:permanent · is:historic · is:party · is:outlaw · '
                              'is:modal · is:vanilla · is:frenchvanilla · is:bear · is:manland.'),
                          _example('c>=br is:spell f:duel'),
                          _example('is:permanent t:rebel'),
                          _example('is:vanilla'),
                          _example('is:bear c:g'),
                        ]),

                        // ---- 7: Extra Cards and Funny Cards ----
                        _section(7, _sectionTitles[7], [
                          _para(
                              'Vanguard, plane, scheme, and phenomenon cards are hidden by default. '
                              'Search by type or set to find them.'),
                          _para(
                              'Un-cards and holiday cards: is:funny. '
                              'include:extras reveals all cards.'),
                          _example('is:funny'),
                          _example('t:scheme'),
                          _example('power include:extras'),
                        ]),

                        // ---- 8: Rarity ----
                        _section(8, _sectionTitles[8], [
                          _para(
                              'Use r: or rarity: to search for common, uncommon, rare, mythic. '
                              'Comparison operators (r>=uncommon) are supported.'),
                          _para(
                              'new:rarity finds reprints at a new rarity. '
                              'in:rare finds cards ever printed at rare.'),
                          _example('r:common t:artifact'),
                          _example('r>=rare c:u'),
                          _example('rarity:common e:ima new:rarity'),
                          _example('in:rare -rarity:rare'),
                        ]),

                        // ---- 9: Sets and Blocks ----
                        _section(9, _sectionTitles[9], [
                          _para(
                              'Use s:, e:, set:, or edition: with a Magic set code.'),
                          _para(
                              'cn: or number: for collector number within a set; ranges supported (cn>50).'),
                          _para(
                              'b: or block: for all sets within a block (uses the three-letter set code). '
                              'Note: block search is not supported in offline mode.'),
                          _para(
                              'st: or settype: for product type: core, expansion, masters, commander, etc.'),
                          _para(
                              'in: checks whether a card has ever appeared in a given set code or set type.'),
                          _example('e:war'),
                          _example('s:m21 is:booster'),
                          _example('st:masters r:mythic'),
                          _example('in:lea in:m15'),
                          _example('t:legendary -in:booster'),
                          _example('cn<=50 e:war'),
                        ]),

                        // ---- 10: Cubes ----
                        _section(10, _sectionTitles[10], [
                          _para(
                              'cube: finds cards in named cube lists (vintage, legacy, modern, etc.). '
                              'Note: cube data requires the Scryfall API; not available offline.'),
                          _example('cube:vintage'),
                          _example('cube:modern t:planeswalker'),
                        ]),

                        // ---- 11: Format Legality ----
                        _section(11, _sectionTitles[11], [
                          _para(
                              'f: or format: finds cards legal in a format. '
                              'banned: and restricted: find banned/restricted cards.'),
                          _para(
                              'Supported formats: standard, future, historic, timeless, gladiator, pioneer, '
                              'modern, legacy, pauper, vintage, penny, commander, oathbreaker, '
                              'standardbrawl, brawl, alchemy, paupercommander, duel, oldschool, premodern.'),
                          _para(
                              'is:commander · is:brawler · is:companion · is:partner · is:reserved · is:gamechanger'),
                          _example('c:g t:creature f:pauper'),
                          _example('banned:legacy'),
                          _example('restricted:vintage'),
                          _example('is:commander c:w'),
                          _example('is:reserved'),
                        ]),

                        // ---- 12: USD/EUR/TIX Prices ----
                        _section(12, _sectionTitles[12], [
                          _para(
                              'Compare card prices with usd:, eur:, tix: and a numeric expression.'),
                          _para(
                              'cheapest:usd/eur/tix finds the cheapest print per card '
                              '(requires Scryfall API; not available offline).'),
                          _example('usd<0.10 r:rare'),
                          _example('tix>15.00'),
                          _example('usd>=0.50 e:ema'),
                        ]),

                        // ---- 13: Artist, Flavor Text and Watermark ----
                        _section(13, _sectionTitles[13], [
                          _para(
                              'a:, art:, or artist: searches the illustrator\'s name. '
                              'ft: or flavor: searches flavor text. '
                              'wm: or watermark: searches card watermarks.'),
                          _para(
                              'has:watermark, has:flavortext, has:artist match cards with those fields present.'),
                          _para(
                              'new:art, new:artist, new:flavor find new illustrations, new artists, or new flavor text.'),
                          _example('a:"proce"'),
                          _example('ft:mishra'),
                          _example('wm:orzhov'),
                          _example('e:m10 new:art is:reprint'),
                        ]),

                        // ---- 14: Border, Frame, Foil & Resolution ----
                        _section(14, _sectionTitles[14], [
                          _para(
                              'border: accepts black, white, silver, or borderless.'),
                          _para(
                              'frame: accepts 1993, 1997, 2003, 2015, future, or frame effects '
                              'like legendary, colorshifted, tombstone, enchantment.'),
                          _para(
                              'is:full / is:fullart — full-art cards. '
                              'is:nonfoil / is:foil / is:etched / is:glossy — finish types. '
                              'is:hires — high-resolution image available. '
                              'stamp: accepts oval, acorn, triangle, arena.'),
                          _para(
                              'is:universesbeyond / not:universesbeyond · is:old · is:new · is:colorshifted'),
                          _example('border:white t:creature'),
                          _example('is:old r:mythic'),
                          _example('is:foil e:c16'),
                          _example('frame:colorshifted'),
                          _example('is:hires is:universesbeyond'),
                        ]),

                        // ---- 15: Games, Promos, & Spotlights ----
                        _section(15, _sectionTitles[15], [
                          _para(
                              'game: / in: accept paper, mtgo, or arena.'),
                          _para(
                              'is:digital — digital-only. '
                              'is:alchemy / is:rebalanced — Arena Alchemy cards. '
                              'is:promo — promotional prints. '
                              'is:spotlight — Story Spotlight cards. '
                              'is:scryfallpreview — Scryfall-previewed cards.'),
                          _example('game:arena'),
                          _example('-in:mtgo f:legacy'),
                          _example('is:promo e:war'),
                          _example('is:spotlight'),
                        ]),

                        // ---- 16: Year ----
                        _section(16, _sectionTitles[16], [
                          _para(
                              'year: compares by release year. '
                              'date: compares by full ISO date (yyyy-mm-dd), '
                              'accepts a set code as a date shorthand, and now/today for today.'),
                          _example('year<=1994'),
                          _example('year=2026'),
                          _example('date>=2015-08-18'),
                          _example('date>ori'),
                          _example('date<=now'),
                        ]),

                        // ---- 17: Tagger Tags ----
                        _section(17, _sectionTitles[17], [
                          _para(
                              'art: / atag: / arttag: search illustration tags. '
                              'function: / otag: / oracletag: search Oracle function tags. '
                              'These require the Scryfall API and are not available offline.'),
                          _example('art:squirrel'),
                          _example('function:removal'),
                        ]),

                        // ---- 18: Reprints ----
                        _section(18, _sectionTitles[18], [
                          _para(
                              'is:reprint — card has been printed before. '
                              'not:reprint — new in this set. '
                              'is:unique — only one printing ever.'),
                          _para(
                              'prints= and sets= compare print/set counts. '
                              'These require Scryfall API data not available offline.'),
                          _example('e:c16 not:reprint'),
                          _example('e:ktk is:unique'),
                        ]),

                        // ---- 19: Languages ----
                        _section(19, _sectionTitles[19], [
                          _para(
                              'lang: / language: finds cards in a specific language (en, de, fr, it, '
                              'es, pt, ja, ko, ru, zhs, zht, he, la, grc, ar, sa, ph). '
                              'lang:any matches any language.'),
                          _para(
                              'new:language finds the first printing in each language. '
                              'in: finds cards ever printed in a language.'),
                          _example('lang:japanese'),
                          _example('lang:any t:planeswalker unique:prints'),
                          _example('lang:ko new:language t:goblin'),
                          _example('in:ru in:zhs'),
                        ]),

                        // ---- 20: Shortcuts and Nicknames ----
                        _section(20, _sectionTitles[20], [
                          _para(
                              'Convenience shortcuts for well-known card groups:'),
                          _example('is:dual'),
                          _example('is:fetchland'),
                          _example('is:masterpiece'),
                          _example('is:colorshifted'),
                        ]),

                        // ---- 21: Negating Conditions ----
                        _section(21, _sectionTitles[21], [
                          _para(
                              'Prefix any keyword with - to negate it. '
                              'not: is an alias for -is: (and vice versa).'),
                          _example('-fire c:r t:instant'),
                          _example('o:changeling -t:creature'),
                          _example('not:reprint e:c16'),
                        ]),

                        // ---- 22: Regular Expressions ----
                        _section(22, _sectionTitles[22], [
                          _para(
                              'Wrap a value in /…/ to use it as a regular expression with '
                              't:, o:, fo:, ft:, and name:. '
                              r'Supports .*?, (a|b), [ab], \d, \w, ^, $, \b, and (?!).'),
                          _para(r'Escape forward slashes inside the pattern with \/.'),
                          _example('t:creature o:/^{T}:/'),
                          _example(r't:instant o:/\spp/'),
                          _example(r'name:/\bizzet\b/'),
                        ]),

                        // ---- 23: Exact Names ----
                        _section(23, _sectionTitles[23], [
                          _para(
                              'Prefix a word or quoted phrase with ! to match the exact card name. '
                              'Case-insensitive.'),
                          _example('!fire'),
                          _example('!"sift through sands"'),
                        ]),

                        // ---- 24: Using "OR" ----
                        _section(24, _sectionTitles[24], [
                          _para(
                              'By default all terms are ANDed. '
                              'Put OR between terms to search over a set of alternatives.'),
                          _example('t:fish or t:bird'),
                          _example('t:land (a:titus or a:avon)'),
                        ]),

                        // ---- 25: Nesting Conditions ----
                        _section(25, _sectionTitles[25], [
                          _para(
                              'Use ( ) to group terms. Most useful with OR.'),
                          _example('t:legendary (t:goblin or t:elf)'),
                          _example('through (depths or sands or mists)'),
                        ]),

                        // ---- 26: Display Keywords ----
                        _section(26, _sectionTitles[26], [
                          _para(
                              'These keywords control how results are displayed and sorted; '
                              'they do not filter cards.'),
                          _para(
                              'unique:cards (default) · unique:prints · unique:art — '
                              'deduplication mode.'),
                          _para(
                              'order:name · order:cmc · order:color · order:rarity · '
                              'order:power · order:toughness · order:set · order:artist · '
                              'order:usd · order:eur · order:tix · order:released — sort field.'),
                          _para(
                              'direction:asc (default) · direction:desc — sort direction.'),
                          _example('!"Lightning Bolt" unique:prints'),
                          _example('t:forest a:avon unique:art'),
                          _example('f:modern order:rarity direction:asc'),
                        ]),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
