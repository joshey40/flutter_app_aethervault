import 'package:flutter/material.dart';

import '../../services/scryfall_search_engine.dart';
import '../../services/scryfall_service.dart';
import '../../services/localization_service.dart';

// ---------------------------------------------------------------------------
// Advanced filter modal – separate StatefulWidget so controllers are
// created once and disposed correctly.
// ---------------------------------------------------------------------------

class _AdvancedFilterModal extends StatefulWidget {
  const _AdvancedFilterModal();

  @override
  State<_AdvancedFilterModal> createState() => _AdvancedFilterModalState();
}

class _AdvancedFilterModalState extends State<_AdvancedFilterModal> {
  final _nameCtrl = TextEditingController();
  final _oracleCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  final _cmcValueCtrl = TextEditingController();
  final _powCtrl = TextEditingController();
  final _touCtrl = TextEditingController();
  final _setCtrl = TextEditingController();
  final _langCtrl = TextEditingController();
  final _formatCtrl = TextEditingController();

  String _cmcOp = '=';
  String _powOp = '=';
  String _touOp = '=';
  String? _rarity;

  final _colorMap = <String, bool>{'w': false, 'u': false, 'b': false, 'r': false, 'g': false};
  var _colorOp = ':';
  var _selMulticolor = false;
  var _selColorless = false;
  final _selectedIs = <String>{};

  @override
  void dispose() {
    _nameCtrl.dispose();
    _oracleCtrl.dispose();
    _typeCtrl.dispose();
    _idCtrl.dispose();
    _cmcValueCtrl.dispose();
    _powCtrl.dispose();
    _touCtrl.dispose();
    _setCtrl.dispose();
    _langCtrl.dispose();
    _formatCtrl.dispose();
    super.dispose();
  }

  // Build the Scryfall-syntax query string from current filter state.
  String _buildQuery() {
    final parts = <String>[];
    if (_nameCtrl.text.trim().isNotEmpty) {
      parts.add('name:${_quoteIfNeeded(_nameCtrl.text.trim())}');
    }
    if (_oracleCtrl.text.trim().isNotEmpty) {
      parts.add('o:${_quoteIfNeeded(_oracleCtrl.text.trim())}');
    }
    if (_typeCtrl.text.trim().isNotEmpty) {
      parts.add('t:${_quoteIfNeeded(_typeCtrl.text.trim())}');
    }
    final colorsSelected = _colorMap.entries.where((e) => e.value).map((e) => e.key).join();
    if (_selColorless) {
      parts.add('c:colorless');
    } else if (_selMulticolor) {
      parts.add('c:m');
    } else if (colorsSelected.isNotEmpty) {
      parts.add('c$_colorOp$colorsSelected');
    }
    if (_idCtrl.text.trim().isNotEmpty) {
      parts.add('id:${_idCtrl.text.trim()}');
    }
    if (_rarity != null) parts.add('r:$_rarity');
    if (_cmcValueCtrl.text.trim().isNotEmpty) {
      parts.add('mv$_cmcOp${_cmcValueCtrl.text.trim()}');
    }
    if (_powCtrl.text.trim().isNotEmpty) {
      parts.add('pow$_powOp${_powCtrl.text.trim()}');
    }
    if (_touCtrl.text.trim().isNotEmpty) {
      parts.add('tou$_touOp${_touCtrl.text.trim()}');
    }
    if (_setCtrl.text.trim().isNotEmpty) {
      parts.add('s:${_setCtrl.text.trim()}');
    }
    if (_langCtrl.text.trim().isNotEmpty) {
      parts.add('lang:${_langCtrl.text.trim()}');
    }
    if (_formatCtrl.text.trim().isNotEmpty) {
      parts.add('f:${_formatCtrl.text.trim()}');
    }
    for (final kw in _selectedIs) {
      parts.add('is:$kw');
    }
    return parts.join(' ');
  }

  String _quoteIfNeeded(String s) {
    if (s.contains(' ')) return '"${s.replaceAll('"', '')}"';
    return s;
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Text(text, style: Theme.of(context).textTheme.labelLarge),
      );

  Widget _opDropdown(String value, ValueChanged<String?> onChanged) =>
      DropdownButton<String>(
        value: value,
        isDense: true,
        items: const ['=', '>', '<', '>=', '<=', '!=']
            .map((op) => DropdownMenuItem(value: op, child: Text(op)))
            .toList(),
        onChanged: onChanged,
      );

  @override
  Widget build(BuildContext context) {
    final loc = appLocalizations;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text(
                  loc.translate('search.advancedFilter'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(null),
              ),
            ]),

            // Name / Oracle / Type
            _sectionLabel(loc.translate('search.filterName')),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(isDense: true)),
            _sectionLabel(loc.translate('search.filterOracle')),
            TextField(controller: _oracleCtrl, decoration: const InputDecoration(isDense: true), minLines: 1, maxLines: 3),
            _sectionLabel(loc.translate('search.filterType')),
            TextField(controller: _typeCtrl, decoration: const InputDecoration(isDense: true)),

            // Colors
            _sectionLabel(loc.translate('search.filterColors')),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final entry in const {
                  'w': 'W',
                  'u': 'U',
                  'b': 'B',
                  'r': 'R',
                  'g': 'G',
                }.entries)
                  FilterChip(
                    label: Text(entry.value),
                    selected: _colorMap[entry.key]!,
                    onSelected: (v) => setState(() {
                      _colorMap[entry.key] = v;
                      if (v) {
                        _selMulticolor = false;
                        _selColorless = false;
                      }
                    }),
                  ),
                FilterChip(
                  label: const Text('Multicolor'),
                  selected: _selMulticolor,
                  onSelected: (v) => setState(() {
                    _selMulticolor = v;
                    if (v) {
                      _selColorless = false;
                      for (final k in _colorMap.keys) {
                        _colorMap[k] = false;
                      }
                    }
                  }),
                ),
                FilterChip(
                  label: const Text('Colorless'),
                  selected: _selColorless,
                  onSelected: (v) => setState(() {
                    _selColorless = v;
                    if (v) {
                      _selMulticolor = false;
                      for (final k in _colorMap.keys) {
                        _colorMap[k] = false;
                      }
                    }
                  }),
                ),
              ],
            ),
            // Color operator (only relevant when individual colors are selected)
            if (_colorMap.values.any((v) => v)) ...[
              const SizedBox(height: 4),
              Row(children: [
                const Text('Color match: ', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: ':', label: Text('≥ includes')),
                    ButtonSegment(value: '=', label: Text('= exactly')),
                    ButtonSegment(value: '<=', label: Text('≤ at most')),
                  ],
                  selected: {_colorOp},
                  onSelectionChanged: (s) => setState(() => _colorOp = s.first),
                  style: ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ]),
            ],

            // Color identity
            _sectionLabel(loc.translate('search.filterColorIdentity')),
            TextField(
              controller: _idCtrl,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'e.g. wr, bgu',
                hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ),

            // Rarity + CMC
            _sectionLabel(loc.translate('search.filterRarity')),
            DropdownButtonFormField<String>(
              value: _rarity,
              decoration: const InputDecoration(isDense: true),
              items: [
                DropdownMenuItem(value: null, child: Text(loc.translate('search.filterRarityAny'))),
                ...['common', 'uncommon', 'rare', 'mythic']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r[0].toUpperCase() + r.substring(1)))),
              ],
              onChanged: (v) => setState(() => _rarity = v),
            ),
            _sectionLabel(loc.translate('search.filterCmc')),
            Row(children: [
              _opDropdown(_cmcOp, (v) => setState(() => _cmcOp = v ?? '=')),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _cmcValueCtrl,
                  decoration: const InputDecoration(isDense: true, hintText: '0–20'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ]),

            // Power / Toughness
            _sectionLabel('${loc.translate('search.filterPower')} / ${loc.translate('search.filterToughness')}'),
            Row(children: [
              _opDropdown(_powOp, (v) => setState(() => _powOp = v ?? '=')),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: _powCtrl,
                  decoration: InputDecoration(isDense: true, labelText: loc.translate('search.filterPower')),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              _opDropdown(_touOp, (v) => setState(() => _touOp = v ?? '=')),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: _touCtrl,
                  decoration: InputDecoration(isDense: true, labelText: loc.translate('search.filterToughness')),
                  keyboardType: TextInputType.number,
                ),
              ),
            ]),

            // Set / Lang / Format
            _sectionLabel(loc.translate('search.filterSet')),
            TextField(
              controller: _setCtrl,
              decoration: InputDecoration(isDense: true, hintText: 'e.g. one, mkm'),
              maxLength: 10,
              buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
            ),
            _sectionLabel(loc.translate('search.filterLang')),
            TextField(
              controller: _langCtrl,
              decoration: const InputDecoration(isDense: true, hintText: 'en, de, ja, …'),
            ),
            _sectionLabel(loc.translate('search.filterFormat')),
            TextField(
              controller: _formatCtrl,
              decoration: const InputDecoration(isDense: true, hintText: 'standard, modern, commander, …'),
            ),

            // is: chips
            _sectionLabel(loc.translate('search.filterIs')),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final kw in const [
                  'legendary',
                  'creature',
                  'instant',
                  'sorcery',
                  'artifact',
                  'enchantment',
                  'land',
                  'planeswalker',
                  'spell',
                  'permanent',
                  'historic',
                  'vanilla',
                  'multicolor',
                  'colorless',
                  'monocolored',
                  'reprint',
                  'promo',
                  'fullart',
                  'commander',
                ])
                  FilterChip(
                    label: Text(kw),
                    selected: _selectedIs.contains(kw),
                    onSelected: (v) => setState(() => v ? _selectedIs.add(kw) : _selectedIs.remove(kw)),
                  ),
              ],
            ),

            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: Text(loc.translate('search.filterCancel')),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(_buildQuery()),
                child: Text(loc.translate('search.filterApply')),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search Page
// ---------------------------------------------------------------------------

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final ScryfallService _scry = ScryfallService();
  final ScryfallSearchEngine _searchEngine = ScryfallSearchEngine();
  List<dynamic>? _data;
  List<dynamic>? _results;
  int _totalResultCount = 0;
  static const int _maxDisplayed = 250;

  final _controller = TextEditingController();
  bool _loadingData = false;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    setState(() => _loadingData = true);
    final oracle = await _scry.loadLocalData(bulkType: ScryfallBulkType.oracleCards) ?? [];
    final defaults = await _scry.loadLocalData(bulkType: ScryfallBulkType.defaultCards) ?? [];
    final all = await _scry.loadLocalData(bulkType: ScryfallBulkType.allCards) ?? [];
    final merged = _mergeBulk([oracle, defaults, all]);
    if (!mounted) return;
    setState(() {
      _data = merged;
      _results = null;
      _loadingData = false;
    });
  }

  Future<void> _checkAndLoad({bool forceDownload = false}) async {
    setState(() => _loadingData = true);
    final types = [
      ScryfallBulkType.oracleCards,
      ScryfallBulkType.defaultCards,
      ScryfallBulkType.allCards,
    ];
    for (final type in types) {
      final hasLocalCache = await _scry.hasLocalCache(bulkType: type);
      final stale = await _scry.isCacheStale(bulkType: type);
      if (forceDownload || !hasLocalCache || stale) {
        final uri = await _scry.fetchBulkIndexAndChooseUri(bulkType: type);
        if (uri != null) {
          try {
            await _scry.downloadBulk(uri, bulkType: type, onProgress: (_) {});
          } catch (_) {
            if (!mounted) return;
            setState(() => _loadingData = false);
            return;
          }
        }
      }
    }

    final oracle = await _scry.loadLocalData(bulkType: ScryfallBulkType.oracleCards) ?? [];
    final defaults = await _scry.loadLocalData(bulkType: ScryfallBulkType.defaultCards) ?? [];
    final all = await _scry.loadLocalData(bulkType: ScryfallBulkType.allCards) ?? [];
    final merged = _mergeBulk([oracle, defaults, all]);
    if (!mounted) return;
    setState(() {
      _data = merged;
      _results = null;
      _loadingData = false;
    });
  }

  List<Map<String, dynamic>> _mergeBulk(List<List<dynamic>> sources) {
    final merged = <Map<String, dynamic>>[];
    final seen = <String>{};
    for (final src in sources) {
      for (final item in src.cast<Map<String, dynamic>>()) {
        final id = item['id']?.toString() ??
            item['oracle_id']?.toString() ??
            item['name']?.toString();
        if (id == null) continue;
        if (seen.add(id)) merged.add(item);
      }
    }
    return merged;
  }

  void _executeSearch() {
    final q = _controller.text.trim();
    if (_data == null || q.isEmpty) {
      setState(() {
        _results = null;
        _totalResultCount = 0;
      });
      return;
    }
    final matches = _searchEngine.filterCards(_data!, q);
    setState(() {
      _totalResultCount = matches.length;
      _results = matches.length > _maxDisplayed ? matches.sublist(0, _maxDisplayed) : matches;
    });
  }

  Future<void> _openFilterMenu() async {
    final built = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AdvancedFilterModal(),
    );

    if (built != null && built.isNotEmpty) {
      _controller.text = built;
      _executeSearch();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Result card tile
  // ---------------------------------------------------------------------------

  Color _rarityColor(String rarity) {
    switch (rarity) {
      case 'mythic':
        return const Color(0xFFE8762D);
      case 'rare':
        return const Color(0xFFC69C6D);
      case 'uncommon':
        return const Color(0xFF8EA3B5);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String _formatManaCost(String cost) {
    return cost.replaceAll('{', '').replaceAll('}', '');
  }

  Widget _buildCardTile(BuildContext context, Map<String, dynamic> item) {
    final theme = Theme.of(context);
    final name = item['name']?.toString() ?? '';
    final typeLine = item['type_line']?.toString() ?? '';
    final setCode = (item['set']?.toString() ?? '').toUpperCase();
    final rarity = item['rarity']?.toString() ?? '';
    final manaCost = item['mana_cost']?.toString() ?? '';
    final rarityColor = _rarityColor(rarity);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Rarity colour bar
            Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(
                color: rarityColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            // Name + type
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    typeLine,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Mana cost + set code
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (manaCost.isNotEmpty)
                  Text(
                    _formatManaCost(manaCost),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                Text(
                  setCode,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
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
        title: Text(loc.translate('nav.search')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: loc.translate('search.downloadAction'),
            onPressed: _loadingData ? null : () => _checkAndLoad(forceDownload: true),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Data status card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.translate('search.metaTitle'),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loc.translate('search.syntaxHint'),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      loc.translate('search.defaultCardsSource'),
                      style: theme.textTheme.bodySmall,
                    ),
                    if (_data != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        loc
                            .translate('search.metaCardsLoaded')
                            .replaceAll('{count}', _data!.length.toString()),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Search bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: _data != null,
                    decoration: InputDecoration(
                      hintText: loc.translate('search.placeholder'),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _controller.clear();
                                setState(() {
                                  _results = null;
                                  _totalResultCount = 0;
                                });
                              },
                            )
                          : null,
                    ),
                    onSubmitted: (_) => _executeSearch(),
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.search,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(72, 50),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    onPressed: _data == null ? null : _executeSearch,
                    child: const Text('Search'),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.tune),
                  tooltip: loc.translate('search.advancedFilter'),
                  onPressed: _data == null ? null : _openFilterMenu,
                ),
              ],
            ),

            // Result count header
            if (_results != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _totalResultCount == 0
                      ? loc.translate('search.noResults')
                      : _totalResultCount <= _maxDisplayed
                          ? loc
                              .translate('search.resultsAll')
                              .replaceAll('{total}', _totalResultCount.toString())
                          : loc
                              .translate('search.resultsShowing')
                              .replaceAll('{shown}', _results!.length.toString())
                              .replaceAll('{total}', _totalResultCount.toString()),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 8),

            // Results / placeholder
            Expanded(
              child: _results == null
                  ? Center(
                      child: _loadingData
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 12),
                                Text(loc.translate('search.statusPreparing')),
                              ],
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.manage_search,
                                  size: 48,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  loc.translate('search.hint'),
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  loc.translate('search.syntaxExamples'),
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                  ),
                                ),
                              ],
                            ),
                    )
                  : _results!.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                loc.translate('search.noResults'),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _results!.length,
                          itemBuilder: (context, index) {
                            final item = _results![index] as Map<String, dynamic>;
                            return _buildCardTile(context, item);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
