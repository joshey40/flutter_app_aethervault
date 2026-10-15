import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../services/localization_service.dart';

/// One help section of the syntax guide.
///
/// The texts live in the l10n files under `search.syntax.sections.<id>`:
/// `title`, `description` and `ex1`..`exN` (one description per example,
/// in the same order as [examples]). The queries themselves are not localized.
class _SyntaxSection {
  const _SyntaxSection(this.id, this.examples);

  final String id;
  final List<String> examples;
}

/// Sections follow https://scryfall.com/docs/syntax, limited to what
/// `scryfall_query.dart` actually supports.
const List<_SyntaxSection> _sections = [
  _SyntaxSection('colors', ['c:rg', 'c:azorius', 'id<=wub', 'c:m', 'c=2']),
  _SyntaxSection('types', [
    't:legendary t:creature',
    't:merfolk',
    't:"basic land"',
    't:artifact -t:creature',
  ]),
  _SyntaxSection('text', [
    'o:"draw a card"',
    'o:"when ~ dies"',
    'kw:flying kw:lifelink',
  ]),
  _SyntaxSection('mana', [
    'm:{G}{U}',
    'm:2WW',
    'm>3WU',
    'm:{R/P}',
    'c:u mv=5',
    'produces=wu',
    'is:hybrid',
  ]),
  _SyntaxSection('pt', ['pow>=5', 'pow>tou t:creature', 'loy>=5']),
  _SyntaxSection('faces', [
    'is:transform',
    'is:mdfc',
    'is:split',
    'is:meld',
    'is:dfc',
  ]),
  _SyntaxSection('spells', [
    'is:spell',
    'is:vanilla',
    'is:bear',
    'is:modal',
    'is:manland',
    'is:party',
  ]),
  _SyntaxSection('extra', [
    't:scheme',
    't:plane',
    't:token t:goblin',
    't:vanguard',
  ]),
  _SyntaxSection('rarity', ['r:mythic', 'r>=rare', 'r:common t:creature']),
  _SyntaxSection('sets', [
    'e:war',
    'e:war is:booster',
    's:neo cn:100',
    'b:zen',
    'g:fin',
    'st:masters',
    't:legendary -is:booster',
  ]),
  _SyntaxSection('legality', [
    'f:modern',
    'banned:legacy',
    'restricted:vintage',
    'is:commander id:ur',
    'is:companion',
    'is:partner',
    'is:gamechanger',
    'is:reserved',
  ]),
  _SyntaxSection('prices', ['usd<1 f:commander', 'eur>=10', 'tix<0.05']),
  _SyntaxSection('artist', [
    'a:proce',
    'a:"rebecca guay"',
    'ft:mishra',
    'wm:orzhov',
  ]),
  _SyntaxSection('frame', [
    'border:white t:creature',
    'frame:2003',
    'stamp:oval',
    'is:full',
    'is:foil e:c16',
    'is:etched',
    'is:hires',
  ]),
  _SyntaxSection('year', ['year>=2020', 'year=1993', 'year=today']),
  _SyntaxSection('tags', ['otag:ramp', 'function:removal', 'art:squirrel']),
  _SyntaxSection('reprints', ['is:reprint e:m15', 'not:reprint e:m15']),
  _SyntaxSection('languages', [
    'lang:de',
    'lang:de t:goblin',
    'lang:any t:elf',
  ]),
  _SyntaxSection('shortcuts', [
    'is:fetchland',
    'is:shockland',
    'is:dual',
    'is:checkland',
    'is:triome',
    'is:creatureland',
    'is:masterpiece',
  ]),
  _SyntaxSection('logic', [
    't:creature -c:r',
    't:goblin OR t:elf',
    '(t:goblin OR t:elf) -c:g',
    '-(t:land OR t:artifact)',
    '"serra angel"',
  ]),
];

class ScryfallSyntaxPage extends StatelessWidget {
  const ScryfallSyntaxPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = appLocalizations;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('search.syntax.title'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            loc.translate('search.syntax.intro'),
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            loc.translate('search.syntax.tap_hint'),
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          for (final section in _sections)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SyntaxSectionCard(section: section),
            )
        ],
      ),
    );
  }
}

// =============================================================================
// Section cards
// =============================================================================

/// Shared expandable card shell for all sections.
class _ExpandableCard extends StatelessWidget {
  const _ExpandableCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        // Remove the default divider lines above and below the tile.
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _SyntaxSectionCard extends StatelessWidget {
  const _SyntaxSectionCard({required this.section});

  final _SyntaxSection section;

  @override
  Widget build(BuildContext context) {
    final loc = appLocalizations;
    final base = 'search.syntax.sections.${section.id}';

    return _ExpandableCard(
      title: loc.translate('$base.title'),
      children: [
        Text(
          loc.translate('$base.description'),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < section.examples.length; i++)
          _SyntaxExampleTile(
            query: section.examples[i],
            description: loc.translate('$base.ex${i + 1}'),
          ),
      ],
    );
  }
}

// =============================================================================
// Tappable example
// =============================================================================

/// Shows a query with a short description. Tapping it opens the search with
/// that query.
class _SyntaxExampleTile extends StatelessWidget {
  const _SyntaxExampleTile({required this.query, required this.description});

  final String query;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () =>
              context.go('/search?q=${Uri.encodeQueryComponent(query)}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        query,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontFamilyFallback: const ['Menlo', 'Courier New'],
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(description, style: textTheme.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.search, size: 18, color: colorScheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
