import 'package:flutter/material.dart';

import '../../services/scryfall_search_engine.dart';
import '../../services/scryfall_service.dart';
import '../../services/localization_service.dart';

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
  final _controller = TextEditingController();
  bool _loadingData = false;
  // filter state
  String? _filterColor;
  String? _filterType;
  String? _filterRarity;
  String? _filterSet;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    setState(() => _loadingData = true);
    // Load all available bulks and merge
    final oracle = await _scry.loadLocalData(bulkType: ScryfallBulkType.oracleCards) ?? [];
    final defaults = await _scry.loadLocalData(bulkType: ScryfallBulkType.defaultCards) ?? [];
    final all = await _scry.loadLocalData(bulkType: ScryfallBulkType.allCards) ?? [];
    final merged = <Map<String, dynamic>>[];
    final seen = <String>{};
    for (final src in [oracle, defaults, all]) {
      for (final item in src.cast<Map<String, dynamic>>()) {
        final id = item['id']?.toString() ?? item['oracle_id']?.toString() ?? item['name']?.toString();
        if (id == null) continue;
        if (seen.add(id)) merged.add(item);
      }
    }
    final loaded = merged;
    if (!mounted) return;
    setState(() {
      _data = loaded;
      _results = null;
      _loadingData = false;
    });
  }

  Future<void> _checkAndLoad({bool forceDownload = false}) async {
    setState(() => _loadingData = true);
    // check and download each required bulk if necessary
    final types = [
      ScryfallBulkType.oracleCards,
      ScryfallBulkType.defaultCards,
      ScryfallBulkType.allCards,
    ];
    for (final type in types) {
      final hasLocalCache = await _scry.hasLocalCache(bulkType: type);
      final stale = await _scry.isCacheStale(bulkType: type);
      final shouldDownload = forceDownload || !hasLocalCache || stale;
      if (shouldDownload) {
        final uri = await _scry.fetchBulkIndexAndChooseUri(bulkType: type);
        if (uri != null) {
          try {
            await _scry.downloadBulk(uri, bulkType: type, onProgress: (_) {});
          } catch (error) {
            if (!mounted) return;
            setState(() => _loadingData = false);
            return;
          }
        }
      }
    }

    final loaded = await _scry.loadLocalData(bulkType: ScryfallBulkType.oracleCards) ?? [];
    final defaults = await _scry.loadLocalData(bulkType: ScryfallBulkType.defaultCards) ?? [];
    final all = await _scry.loadLocalData(bulkType: ScryfallBulkType.allCards) ?? [];
    final merged = <Map<String, dynamic>>[];
    final seen = <String>{};
    for (final src in [loaded, defaults, all]) {
      for (final item in src.cast<Map<String, dynamic>>()) {
        final id = item['id']?.toString() ?? item['oracle_id']?.toString() ?? item['name']?.toString();
        if (id == null) continue;
        if (seen.add(id)) merged.add(item);
      }
    }
    final allLoaded = merged;
    if (!mounted) return;
    setState(() {
      _data = allLoaded;
      _results = null;
      _loadingData = false;
    });
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) {
      return appLocalizations.translate('search.metaUnknown');
    }

    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day.$month.$year $hour:$minute';
  }

  String _formatBytes(int? value) {
    if (value == null) {
      return appLocalizations.translate('search.metaUnknown');
    }

    final mb = value / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  void _executeSearch() {
    final q = _controller.text.trim();
    if (_data == null || q.isEmpty && _filterColor == null && _filterType == null && _filterRarity == null && _filterSet == null) {
      setState(() => _results = null);
      return;
    }
    // build full query including filters using Scryfall syntax
    final parts = <String>[];
    if (q.isNotEmpty) parts.add(q);
    if (_filterColor != null && _filterColor!.isNotEmpty) parts.add('c:${_filterColor!}');
    if (_filterType != null && _filterType!.isNotEmpty) parts.add('t:${_filterType!}');
    if (_filterRarity != null && _filterRarity!.isNotEmpty) parts.add('r:${_filterRarity!}');
    if (_filterSet != null && _filterSet!.isNotEmpty) parts.add('s:${_filterSet!}');
    final fullQuery = parts.join(' ');
    final matches = _searchEngine.filterCards(_data!, fullQuery);
    setState(() => _results = matches.length > 50 ? matches.sublist(0, 50) : matches);
  }

  void _openFilterMenu() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(context: context, isScrollControlled: true, builder: (ctx) {
      // Advanced filter modal: name, oracle, type, colors, color identity, rarity, cmc, set, lang, is:
      String? selId;
      String? selType = _filterType;
      String? selRarity = _filterRarity;
      String? selSet = _filterSet;
      String? selName;
      String? selOracle;
      String? selLang;
      String cmcOp = '=';
      String? cmcValue;
      final colorMap = <String, bool>{'w': false, 'u': false, 'b': false, 'r': false, 'g': false};
      var selMulticolor = false;
      var selColorless = false;
      final selectedIs = <String>{};

      return StatefulBuilder(builder: (context, setModalState) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Advanced Filter', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Name (name:)'),
                    onChanged: (v) => setModalState(() => selName = v.trim()),
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Oracle Text (o:)'),
                    onChanged: (v) => setModalState(() => selOracle = v.trim()),
                    minLines: 1,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Type (t:)'),
                    controller: TextEditingController(text: selType),
                    onChanged: (v) => setModalState(() => selType = v.trim()),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      const Text('Colors:'),
                      for (final k in ['w', 'u', 'b', 'r', 'g'])
                        FilterChip(
                          label: Text(k.toUpperCase()),
                          selected: colorMap[k]!,
                          onSelected: (v) => setModalState(() => colorMap[k] = v),
                        ),
                      FilterChip(label: const Text('Multicolor'), selected: selMulticolor, onSelected: (v) => setModalState(() => selMulticolor = v)),
                      FilterChip(label: const Text('Colorless'), selected: selColorless, onSelected: (v) => setModalState(() => selColorless = v)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Color Identity (id:) e.g. wr'),
                    onChanged: (v) => setModalState(() => selId = v.trim()),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selRarity,
                        items: const [null, 'common', 'uncommon', 'rare', 'mythic'].map((e) => DropdownMenuItem(value: e, child: Text(e == null ? 'Rarity' : e))).toList(),
                        onChanged: (v) => setModalState(() => selRarity = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(children: [
                        DropdownButton<String>(value: cmcOp, items: const ['=', '>', '<', '>=', '<=', '!='].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setModalState(() => cmcOp = v ?? '=')),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(decoration: const InputDecoration(labelText: 'CMC'), keyboardType: TextInputType.number, onChanged: (v) => setModalState(() => cmcValue = v.trim()))),
                      ]),
                    )
                  ]),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Set (s:)'),
                    controller: TextEditingController(text: selSet),
                    onChanged: (v) => setModalState(() => selSet = v.trim()),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Language (lang:) e.g. en, de'),
                    onChanged: (v) => setModalState(() => selLang = v.trim()),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      const Text('is:'),
                      for (final kw in ['creature', 'instant', 'sorcery', 'artifact', 'enchantment', 'land', 'planeswalker', 'legendary', 'multicolor', 'colorless', 'spell'])
                        ChoiceChip(label: Text(kw), selected: selectedIs.contains(kw), onSelected: (v) => setModalState(() => v ? selectedIs.add(kw) : selectedIs.remove(kw))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancel')),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(minimumSize: const Size(88, 40)),
                        onPressed: () {
                          // build final query map
                          final colorsSelected = colorMap.entries.where((e) => e.value).map((e) => e.key).join();
                          final parts = <String, dynamic>{};
                          if (selName?.isNotEmpty == true) parts['name'] = selName;
                          if (selOracle?.isNotEmpty == true) parts['oracle'] = selOracle;
                          if (selType?.isNotEmpty == true) parts['type'] = selType;
                          if (colorsSelected.isNotEmpty) parts['color'] = colorsSelected;
                          if (selId?.isNotEmpty == true) parts['id'] = selId;
                          if (selMulticolor) parts['is_multicolor'] = true;
                          if (selColorless) parts['is_colorless'] = true;
                          if (selRarity?.isNotEmpty == true) parts['rarity'] = selRarity;
                          if (cmcValue?.isNotEmpty == true) parts['cmc'] = {'op': cmcOp, 'val': cmcValue};
                          if (selSet?.isNotEmpty == true) parts['set'] = selSet;
                          if (selLang?.isNotEmpty == true) parts['lang'] = selLang;
                          if (selectedIs.isNotEmpty) parts['is'] = selectedIs.toList();
                          Navigator.of(context).pop(parts);
                        },
                        child: const Text('Apply'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      });
    });

    if (result != null) {
      // translate the map into saved filter fields and run a search
      setState(() {
        _filterType = result['type'] as String?;
        _filterRarity = result['rarity'] as String?;
        _filterSet = result['set'] as String?;
        _filterColor = result['color'] as String?;
      });

      // construct scryfall-style query
      final parts = <String>[];
      if (result['name'] != null) parts.add('name:${_quoteIfNeeded(result['name'])}');
      if (result['oracle'] != null) parts.add('o:${_quoteIfNeeded(result['oracle'])}');
      if (_filterType != null && _filterType!.isNotEmpty) parts.add('t:${_filterType}');
      if (_filterColor != null && _filterColor!.isNotEmpty) parts.add('c:${_filterColor}');
      if (result['id'] != null) parts.add('id:${result['id']}');
      if (result['is_multicolor'] == true) parts.add('is:multicolor');
      if (result['is_colorless'] == true) parts.add('is:colorless');
      if (_filterRarity != null && _filterRarity!.isNotEmpty) parts.add('r:${_filterRarity}');
      if (result['cmc'] != null) {
        final cmc = result['cmc'] as Map<String, dynamic>;
        parts.add('mv:${cmc['op']}${cmc['val']}');
      }
      if (_filterSet != null && _filterSet!.isNotEmpty) parts.add('s:${_filterSet}');
      if (result['lang'] != null) parts.add('lang:${result['lang']}');
      if (result['is'] != null) {
        for (final v in (result['is'] as List)) {
          parts.add('is:$v');
        }
      }

      final built = parts.join(' ');
      _controller.text = built;
      _executeSearch();
    }
  }

  String _quoteIfNeeded(String? s) {
    if (s == null) return '';
    if (s.contains(' ')) return '"${s.replaceAll('"', '')}"';
    return s;
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.translate('nav.search')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadingData ? null : () => _checkAndLoad(forceDownload: true),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appLocalizations.translate('search.metaTitle'),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appLocalizations.translate('search.syntaxHint'),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appLocalizations.translate('search.defaultCardsSource'),
                      style: theme.textTheme.bodySmall,
                    ),
                    if (_data != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        appLocalizations
                            .translate('search.metaCardsLoaded')
                            .replaceAll('{count}', _data!.length.toString()),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: _data != null,
                    decoration: InputDecoration(
                      labelText: appLocalizations.translate('search.placeholder'),
                      helperText: appLocalizations.translate('search.syntaxExamples'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 96,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(minimumSize: const Size(88, 48)),
                    onPressed: _data == null ? null : _executeSearch,
                    icon: const Icon(Icons.search),
                    label: const Text('Search'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _data == null ? null : _openFilterMenu,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _results == null
                  ? Center(
                      child: _loadingData
                          ? Text(appLocalizations.translate('search.statusPreparing'))
                          : Text(appLocalizations.translate('search.hint')),
                    )
                  : ListView.builder(
                      itemCount: _results!.length,
                      itemBuilder: (context, index) {
                        final item = _results![index] as Map<String, dynamic>;
                        return ListTile(
                          title: Text(item['name'] ?? ''),
                          subtitle: Text(item['set_name'] ?? ''),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
