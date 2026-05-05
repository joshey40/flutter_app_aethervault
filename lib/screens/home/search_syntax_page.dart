import 'package:flutter/material.dart';

// A long, scrollable page that reproduces the Scryfall search syntax
// documentation text as plain Flutter widgets. The text is taken from the
// user's attached HTML and reproduced verbatim in sections.

class SearchSyntaxPage extends StatelessWidget {
    const SearchSyntaxPage({super.key});

    Widget _sectionTitle(BuildContext context, String text) => Padding(
                padding: const EdgeInsets.only(top: 18.0, bottom: 6.0),
                child: Text(text, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            );

    Widget _para(BuildContext context, String text) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: SelectableText(text, style: Theme.of(context).textTheme.bodyMedium),
            );

    Widget _example(BuildContext context, String text) => Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace')),
            );

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);
        return Scaffold(
            appBar: AppBar(title: const Text('Scryfall Search Reference')),
            body: SafeArea(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: SingleChildScrollView(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(
                                'Scryfall includes a large set of keywords and expressions\nyou can use to find Magic: The Gathering cards',
                                style: theme.textTheme.bodySmall,
                            ),

                            _sectionTitle(context, 'Colors and Color Identity'),
                            _para(context, 'You can find cards that are a certain color using the c: or color: keyword,\nand cards that are a certain color identity using the id: or identity: keywords.'),

                            _para(context, 'Both sets of keywords accepts full color names like blue\nor the abbreviated color letters w, u, r, b and g.'),

                            _para(context, 'You can use many nicknames for color sets:\nall guild names (e.g. azorius), all shard names (e.g. bant),\nall college names (e.g., quandrix),\nall wedge names (e.g. abzan),\nand the four-color nicknames chaos, aggression, altruism, growth, artifice are supported.'),

                            _para(context, 'Use c or colorless to match colorless cards, and m or multicolor to match multicolor cards.'),

                            _para(context, 'You can use comparison expressions (>, <, >=, <=, and !=)\nto check against ranges of colors. You can also use numbers instead to find cards that have that many colors.'),

                            _para(context, 'Find cards that have a color indicator with has:indicator.'),

                            _example(context, 'c:rg'),
                            _example(context, 'color>=uw -c:red'),
                            _example(context, 'id<=esper t:instant'),
                            _example(context, 'id:c t:land'),
                            _example(context, 'c=2 is:bear'),

                            _sectionTitle(context, 'Card Types'),
                            _para(context, 'Find cards of a certain card type with the t: or type: keywords.\nYou can search for any supertype, card type, or subtype.'),
                            _para(context, 'Using only partial words is allowed.'),
                            _example(context, 't:merfolk t:legend'),
                            _example(context, 't:goblin -t:creature'),

                            _sectionTitle(context, 'Card Text'),
                            _para(context, 'Use the o: or oracle: keywords to find cards that have specific\nphrases in their text box.'),
                            _para(context, 'You can put quotes " " around text with punctuation or spaces.'),
                            _para(context, 'You can use ~ in your text as a placeholder for the card’s name.'),
                            _para(context, 'This keyword usually checks the current Oracle text for cards,\nso it uses the most up-to-date phrasing available.\nFor example, “dies” instead of “is put into a graveyard”.'),
                            _para(context, 'Use the fo: or fulloracle: operator to search the full Oracle text,\nwhich includes reminder text.'),
                            _para(context, 'You can also use keyword: or kw: to search for cards with a\nspecific keyword ability.'),
                            _example(context, 'o:draw t:creature'),
                            _example(context, 'o:"~ enters tapped"'),
                            _example(context, 'kw:flying -t:creature'),

                            _sectionTitle(context, 'Mana Costs'),
                            _para(context, 'Use the m: or mana: keyword to search for cards that have\ncertain symbols in their mana costs.'),
                            _para(context, 'This keyword uses the official text version of mana costs set\nforth in the Comprehensive Rules. For example, {G} represents a green mana.'),
                            _para(context, 'Shorthand is allowed for symbols that aren’t split: G is the same as {G}'),
                            _para(context, 'However, you must always wrap complex/split symbols like {2/G} in braces.'),
                            _para(context, 'You can search for mana costs using comparison operators; a mana cost is greater than another if it includes\nall the same symbols and more, and it’s less if it includes only a subset of symbols.'),
                            _para(context, 'You can find cards of a specific mana value with manavalue or mv,\ncomparing with a numeric expression (>, <, =, >=, <=, and !=). You can also find even or odd mana costs with manavalue:even or manavalue:odd'),
                            _para(context, 'You can filter cards that contain hybrid mana symbols with is:hybrid\nor Phyrexian mana symbols with is:phyrexian.'),
                            _para(context, 'You can find permanents that provide specific levels of devotion, using either single-color\nmana symbols for devotion to one color, or hybrid symbols for devotion to two, with devotion:\nor a comparison operator.'),
                            _para(context, 'You can also find cards that produce specific types of mana, with produces:'),
                            _example(context, 'mana:{G}{U}'),
                            _example(context, 'm:2WW'),
                            _example(context, 'm>3WU'),
                            _example(context, 'm:{R/P}'),
                            _example(context, 'c:u mv=5'),
                            _example(context, 'devotion:{u/b}{u/b}{u/b}'),

                            _sectionTitle(context, 'Power, Toughness, and Loyalty'),
                            _para(context, 'You can use numeric expressions (>, <, =, >=, <=, and !=)\nto find cards with certain\npower, power/pow, toughness, toughness/tou,\ntotal power and toughness, pt/powtou,\nor starting loyalty, loyalty/loy.'),
                            _para(context, 'You can compare the values with each other or with a provided number.'),
                            _example(context, 'pow>=8'),
                            _example(context, 'pow>tou c:w t:creature'),
                            _example(context, 't:planeswalker loy=3'),

                            _sectionTitle(context, 'Multi-faced Cards'),
                            _para(context, 'You can find cards that have more than one face with\n is:split (split cards), is:flip (flip cards),\nis:transform (cards that transform, alias tdfc),\nis:meld (cards that meld), is:leveler (cards with Level Up),\nis:dfc (double-faced cards), and is:mdfc (modal double-faced cards).'),
                            _para(context, 'You can find meld parts specifically with is:meldpart and their results with is:meldresult.'),
                            _example(context, 'is:meld'),
                            _example(context, 'is:split'),

                            _sectionTitle(context, 'Spells, Permanents, and Effects'),
                            _para(context, 'Find cards that are cast as spells with is:spell.'),
                            _para(context, 'Find permanent cards with is:permanent, historic cards with is:historic,\ncreatures that can be in your party with is:party, creatures that are outlaws with is:outlaw,\nmodal effects with is:modal, vanilla creatures with is:vanilla,\nFrench vanilla cards with is:frenchvanilla,\n2/2/2 “bear” creatures with is:bear,\nor lands that can turn into creatures with is:manland.'),
                            _example(context, 'c>=br is:spell f:duel'),
                            _example(context, 'is:permanent t:rebel'),
                            _example(context, 'is:vanilla'),

                            _sectionTitle(context, 'Extra Cards and Funny Cards'),
                            _para(context, 'Vanguard, plane, scheme, and phenomenon cards are hidden by default, as are\ncards from “memorabilia” sets. You must either search for their type\n(using the type: keyword) or a set that contains them (the set: keyword).'),
                            _para(context, 'Un-cards, holiday cards, and other funny cards are findable with is:funny\nor mentioning their set.'),
                            _para(context, 'You may also use include:extras to\nreveal absolutely every card when you search.'),
                            _example(context, 'is:funny'),
                            _example(context, 't:scheme'),
                            _example(context, 'power include:extras'),

                            _sectionTitle(context, 'Rarity'),
                            _para(context, 'Use r: or rarity: to find cards by their print rarity.\nYou can search for common, uncommon, rare, special, mythic, and bonus.'),
                            _para(context, 'You can also use comparison operators like < and >=.'),
                            _para(context, 'Use new:rarity to find reprint cards printed at a new\nrarity for the first time. You can find cards that have\never been printed in a given rarity using in: (for example, in:rare to find cards that have ever been printed at rare.)'),
                            _para(context, 'Cards new to pauper in particular can be found using is:newinpauper.'),
                            _example(context, 'r:common t:artifact'),
                            _example(context, 'r>=r'),
                            _example(context, 'rarity:common e:ima new:rarity'),
                            _example(context, 'in:rare -rarity:rare'),

                            _sectionTitle(context, 'Sets and Blocks'),
                            _para(context, 'Use s:, e:, set:, or edition: to find cards using their Magic set code.'),
                            _para(context, 'Use cn: or number: to find cards by collector number within a set. Combine this with s: to find specific card editions. Searching by ranges with a syntax like cn>50 is also possible.'),
                            _para(context, 'Use b: or block: to find cards in a Magic block by providing the three-letter code for any set in that block.'),
                            _para(context, 'The in: keyword finds cards that once “passed through”\nthe given set code. For example in:lea would only match cards\nthat once appeared in Alpha.'),
                            _para(context, 'You can search for cards based on the type of product they appear in. This includes the primary product types (st:core, st:expansion, or st:draftinnovation), as well as series of products (st:masters, st:funny, st:commander, st:duel_deck, st:from_the_vault, st:spellbook, or st:premium_deck) and more specialized types (st:alchemy, st:archenemy, st:masterpiece, st:memorabilia, st:planechase, st:promo, st:starter, st:token, st:treasure_chest, or st:vanguard.)'),
                            _para(context, 'The in: keyword also supports these set types, so you can search for cards with no printings in a set type with a query like -in:core.'),
                            _para(context, 'You can also search for individual cards that were sold in certain places with is:booster or is:planeswalker_deck, or specific types of promo cards with is: queries like is:league, is:buyabox, is:giftbox, is:intro_pack, is:gameday, is:prerelease, is:release, is:fnm, is:judge_gift, is:arena_league, is:player_rewards, is:media_insert, is:instore, is:convention, or is:set_promo, among others.'),
                            _example(context, 'e:war'),
                            _example(context, 'e:war is:booster'),
                            _example(context, 'b:wwk'),
                            _example(context, 'in:lea in:m15'),
                            _example(context, 't:legendary -in:booster'),
                            _example(context, 'is:datestamped is:prerelease'),

                            _sectionTitle(context, 'Cubes'),
                            _para(context, 'Find cards that are part of cube lists using the cube: keyword. The currently supported cubes are arena, grixis, legacy, chuck, twisted, april, protour, uncommon, modern, amaz, tinkerer, livethedream, chromatic, vintage, and apcube.'),
                            _example(context, 'cube:vintage'),
                            _example(context, 'cube:modern t:planeswalker'),

                            _sectionTitle(context, 'Format Legality'),
                            _para(context, 'Use the f: or format: keywords to find cards that are legal in a given format.'),
                            _para(context, 'You can also find cards that are explicitly banned in a format with the banned: keyword and restricted with the restricted: keyword.'),
                            _para(context, 'The current supported formats are: standard, future (Future Standard), historic, timeless, gladiator, pioneer, modern, legacy, pauper, vintage, penny (Penny Dreadful), commander, oathbreaker, standardbrawl, brawl, alchemy, paupercommander, duel (Duel Commander), oldschool (Old School 93/94), premodern, predh, and tlr (Tiny Leaders: Reborn).'),
                            _para(context, 'You can use is:commander to find cards that can be your commander, is:brawler to find cards that can be your Brawl Commander, is:companion to find Companion cards, is:duelcommander to find cards that can be your Duel Commander, and is:oathbreaker to find cards that can be your Oathbreaker.'),
                            _para(context, 'You can find Commander Partner cards with is:partner.'),
                            _para(context, 'Cards that are Commander Gamechangers can be found using is:gamechanger.'),
                            _para(context, 'You can find cards on the Reserved List with is:reserved.'),
                            _example(context, 'c:g t:creature f:pauper'),
                            _example(context, 'banned:legacy'),
                            _example(context, 'is:commander'),
                            _example(context, 'is:reserved'),

                            _sectionTitle(context, 'USD/EUR/TIX prices'),
                            _para(context, 'You can find prints within certain usd, eur, tix price ranges by comparing them with a numeric expression (>, <, =, >=, <=, and !=).'),
                            _para(context, 'You can find the cheapest print of each card with cheapest:usd, cheapest:eur, and cheapest:tix.'),
                            _example(context, 'tix>15.00'),
                            _example(context, 'usd>=0.50 e:ema'),

                            _sectionTitle(context, 'Artist, Flavor Text and Watermark'),
                            _para(context, 'Search for cards illustrated by a certain artist with the a:, or artist: keywords. And you can search for cards with more than one artist using artists>1.'),
                            _para(context, 'Search for words in a card’s flavor text using the ft: or flavor: keywords.'),
                            _para(context, 'Search for a card’s affiliation watermark using the wm: or watermark: keywords, or match all cards with watermarks using has:watermark.'),
                            _para(context, 'For any of these, you can wrap statements with spaces or punctuation in quotes " ".'),
                            _para(context, 'You can find cards being printed with new illustrations using new:art, being illustrated by a particular artist for the first time with new:artist, and with brand-new flavor text using new:flavor.'),
                            _para(context, 'You can compare how many different illustrations a give card has with things like illustrations>1.'),
                            _example(context, 'a:"proce"'),
                            _example(context, 'ft:mishra'),
                            _example(context, 'ft:designed e:m15'),
                            _example(context, 'wm:orzhov'),
                            _example(context, 'e:m10 new:art is:reprint'),
                            _example(context, 'new:art -new:artist st:masters game:paper'),
                            _example(context, 'new:flavor e:m15 is:reprint'),

                            _sectionTitle(context, 'Border, Frame, Foil & Resolution'),
                            _para(context, 'Use the border: keyword to find cards with a black, white, silver, or borderless border.'),
                            _para(context, 'You can find cards with a specific frame edition using frame:1993, frame:1997, frame:2003, frame:2015, and frame:future. You can also search for particular frame-effects, such as frame:legendary, frame:colorshifted, frame:tombstone, frame:enchantment.'),
                            _para(context, 'You can find cards with full art using is:full.'),
                            _para(context, 'new:frame will find cards printed in a specific frame for the first time.'),
                            _para(context, 'Each card is available in non-foil, in foil, or in both. You can find prints available in each with is:nonfoil and is:foil, or is:foil is:nonfoil to find prints (like most booster cards) available in both. You can also find cards available in etched foil and glossy finishes with is:etched and is:glossy.'),
                            _para(context, 'You can find cards in our database with high-resolution images using is:hires.'),
                            _para(context, 'Search for a card’s security stamp with stamp:oval, stamp:acorn, stamp:triangle, or stamp:arena'),
                            _para(context, 'You can search for or exclude Universes Beyond cards with is:universesbeyond or not:universesbeyond. You can search for cards with the default Magic frame with is:default, or for atypical frame treatments with is:atypical.'),
                            _example(context, 'border:white t:creature'),
                            _example(context, 'is:new r:mythic'),
                            _example(context, 'is:old t:artifact'),
                            _example(context, 'is:hires'),
                            _example(context, 'is:foil e:c16'),
                            _example(context, 'frame:2003 new:frame in:fut is:reprint'),

                            _sectionTitle(context, 'Games, Promos, & Spotlights'),
                            _para(context, 'You can find specific prints available in different Magic game environments with the game: keyword. The games paper, mtgo, and arena are supported.'),
                            _para(context, 'You can filter by a card’s availability in a game with the in: keyword. The games paper, mtgo, and arena are supported.'),
                            _para(context, 'Find prints that are only available digitally (MTGO and Arena) with is:digital.'),
                            _para(context, 'You can find Arena Alchemy cards with is:alchemy, and Arena Rebalanced cards with is:rebalanced.'),
                            _para(context, 'Find promotional cards (in any environment) with is:promo.'),
                            _para(context, 'Find cards that are Story Spotlights with is:spotlight.'),
                            _para(context, 'Find cards that Scryfall has had the honor of previewing with is:scryfallpreview.'),
                            _example(context, 'game:arena'),
                            _example(context, '-in:mtgo f:legacy'),
                            _example(context, 'is:promo'),
                            _example(context, 'is:spotlight'),
                            _example(context, 'is:scryfallpreview'),

                            _sectionTitle(context, 'Year'),
                            _para(context, 'You can use numeric expressions (>, <, =, >=, <=, and !=)\nto find cards that were released relative to a certain year or a yyyy-mm-dd date.\nYou can also use any set code to stand in for the set’s release date, or use now/today to stand in for today’s date.'),
                            _example(context, 'year<=1994'),
                            _example(context, 'year=2026'),
                            _example(context, 'date>=2015-08-18'),
                            _example(context, 'date>ori'),
                            _example(context, 'date>now'),

                            _sectionTitle(context, 'Tagger Tags'),
                            _para(context, 'You can use art:, atag:, or arttag: to find things in a card’s illustration.'),
                            _para(context, 'You can use function:, otag:, or oracletag: to find “Oracle” tags which\ndescribe the function of the card.'),
                            _para(context, 'Data for these two features comes from the Tagger project.'),
                            _example(context, 'art:squirrel'),
                            _example(context, 'function:removal'),

                            _sectionTitle(context, 'Reprints'),
                            _para(context, 'You can find reprints with is:reprint, cards that were new in their set with not:reprint, and cards that have only been in a single set with is:unique.'),
                            _para(context, 'You can also compare the number of times a card has been printed with syntax like prints=1, or the number of sets a card has been in with sets=1.'),
                            _example(context, 'e:c16 not:reprint'),
                            _example(context, 'e:ktk is:unique'),
                            _example(context, 'sets>=20'),
                            _example(context, 'e:arn papersets=1'),

                            _sectionTitle(context, 'Languages'),
                            _para(context, 'You can request cards in certain languages with the lang:/language: keywords.'),
                            _para(context, 'You can widen your search to any language with the special lang:any keyword.'),
                            _para(context, 'You can also find the first printing of a card in each language using new:language and all printings of a card that’s been printed in a language at least once with in: (e.g. in:ru will find cards that have ever been printed in Russian.)'),
                            _example(context, 'lang:japanese'),
                            _example(context, 'lang:any t:planeswalker unique:prints'),
                            _example(context, 'lang:ko new:language t:goblin'),
                            _example(context, 'in:ru in:zhs'),

                            _sectionTitle(context, 'Shortcuts and Nicknames'),
                            _para(context, 'The search system includes a few convenience shortcuts for common card sets:'),
                            _para(context, 'You can find all Masterpiece Series cards with is:masterpiece'),
                            _example(context, 'is:dual'),
                            _example(context, 'is:fetchland'),
                            _example(context, 'is:colorshifted'),

                            _sectionTitle(context, 'Negating Conditions'),
                            _para(context, 'All keywords except for include can be negated by prefixing them with a hyphen (-). This inverts the meaning of the keyword to reject cards that matched what you’ve searched for.'),
                            _para(context, 'The is: keyword has a convenient inverted mode not: which is the same as -is:. Conversely, -not: is the same as is:.'),
                            _example(context, '-fire c:r t:instant'),
                            _example(context, 'o:changeling -t:creature'),
                            _example(context, 'not:reprint e:c16'),

                            _sectionTitle(context, 'Regular Expressions'),
                            _para(context, 'You can use forward slashes `//` instead of quotes with the `type:`, `t:`, `oracle:`, `o:`, `flavor:`, `ft:`, and `name:` keywords to match those parts of a card with a regular expression.'),
                            _para(context, r'Scryfall supports many regex features such as `.*?`, option groups `(a|b)`, brackets `[ab]`, character classes \d, \w, and anchors (?!), \b, ^, and $.'),
                            _para(context, r'Forward slashes inside your regex must be escaped with `\/`.'),
                            _para(context, r'Full documentation for this keyword is available on our Regular Expressions help page.'),
                            _example(context, 't:creature o:/^{T}:/'),
                            _example(context, 't:instant o:/\\spp/'),
                            _example(context, 'name:/\\bizzet\\b/'),

                            _sectionTitle(context, 'Exact Names'),
                            _para(context, 'If you prefix words or quoted phrases with `!` you will find cards with that exact name only.'),
                            _para(context, 'This is still case-insensitive.'),
                            _example(context, '!fire'),
                            _example(context, '!"sift through sands"'),

                            _sectionTitle(context, 'Using "OR"'),
                            _para(context, 'By default every search term you enter is combined. All of them must match to\nfind a card.'),
                            _para(context, 'If you want to search over a set of options or choices, you can put the special word `or`/`OR` between terms.'),
                            _example(context, 't:fish or t:bird'),
                            _example(context, 't:land (a:titus or a:avon)'),

                            _sectionTitle(context, 'Nesting Conditions'),
                            _para(context, 'You may nest conditions inside parentheses `( )` to group them together. This is most useful when combined with the `OR` keyword.'),
                            _para(context, 'Remember that terms that are not separated by `OR` are still combined.'),
                            _example(context, 't:legendary (t:goblin or t:elf)'),
                            _example(context, 'through (depths or sands or mists)'),

                            _sectionTitle(context, 'Display Keywords'),
                            _para(context, 'You can enter your display options for searches as keywords rather than using the controls on the page.'),
                            _para(context, 'Select how duplicate results are eliminated with `unique:cards`, `unique:prints` (previously `++`), or `unique:art` (also `@@`).'),
                            _para(context, 'Change how results are shown with `display:grid`, `display:checklist`, `display:full`, or `display:text`.'),
                            _para(context, 'Change how results are sorted with `order:artist`, `order:cmc`, `order:power`, `order:toughness`, `order:set`, `order:name`, `order:usd`, `order:tix`, `order:eur`, `order:rarity`, `order:color`, `order:released`, `order:spoiled`, `order:edhrec`, `order:penny`, or `order:review`.'),
                            _para(context, 'Select what printings of cards to preferentially show with `prefer:oldest`, `prefer:newest`, `prefer:usd-low` or `prefer:usd-high` (and the equivalents for `tix` and `eur`), `prefer:promo` (promos), `prefer:default` (default Magic frame), `prefer:atypical` (atypical Magic frames), `prefer:universesbeyond` / `prefer:ub` (Universes Beyond prints), or `prefer:notuniversesbeyond` / `prefer:notub` (non-Universes Beyond prints).'),
                            _para(context, 'Change the order of the sorted data with `direction:asc` or `direction:desc`.'),
                            _example(context, '!"Lightning Bolt" unique:prints'),
                            _example(context, 't:forest a:avon unique:art'),
                            _example(context, 'f:modern order:rarity direction:asc'),
                            _example(context, 't:human display:text'),
                            _example(context, 'in:leb game:paper prefer:newest'),
                            _example(context, 'year=2025 prefer:atypical'),

                            const SizedBox(height: 24),
                        ]),
                    ),
                ),
            ),
        );
    }
}
