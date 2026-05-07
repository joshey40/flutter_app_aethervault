import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../services/localization_service.dart';

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
                              'and a certain color identity with id: or identity.'),
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

                        // ... rest of content unchanged ...
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
