import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/scryfall_search_engine.dart';
import '../../services/scryfall_service.dart';
import '../../services/localization_service.dart';
import 'search_syntax_page.dart';

// ---------------------------------------------------------------------------
// Advanced filter modal
// ---------------------------------------------------------------------------

class _AdvancedFilterModal extends StatefulWidget {
  const _AdvancedFilterModal();

  @override
  State<_AdvancedFilterModal> createState() => _AdvancedFilterModalState();
}

class _AdvancedFilterModalState extends State<_AdvancedFilterModal> {
  // --- Text controllers ---
  final _nameCtrl     = TextEditingController();
  final _oracleCtrl   = TextEditingController();
  final _typeCtrl     = TextEditingController();
  final _cmcValueCtrl = TextEditingController();
  final _loyCtrl      = TextEditingController();
  final _manaCtrl     = TextEditingController();
  final _powCtrl      = TextEditingController();
  final _touCtrl      = TextEditingController();
  final _kwCtrl       = TextEditingController();
  final _artistCtrl   = TextEditingController();
  final _flavorCtrl   = TextEditingController();
  final _setCtrl      = TextEditingController();
  final _usdCtrl      = TextEditingController();
  final _eurCtrl      = TextEditingController();
  final _tixCtrl      = TextEditingController();
  final _yearCtrl     = TextEditingController();
  final _previewCtrl  = TextEditingController();

  // --- Numeric operators ---
  String _cmcOp  = '=';
  String _powOp  = '=';
  String _touOp  = '=';
  String _loyOp  = '=';
  String _usdOp  = '=';
  String _eurOp  = '=';
  String _tixOp  = '=';
  String _yearOp = '=';
  bool   _linkPowTou = false;

  // --- Dropdowns ---
  String? _rarity;
  String? _lang;
  String? _format;
  String? _sortOrder;
  String? _sortDir;
  String? _unique;

  // --- Color (c:) ---
  final _colorMap = <String, bool>{'w': false, 'u': false, 'b': false, 'r': false, 'g': false};
  String _colorOp      = ':';
  bool   _selMulticolor = false;
  bool   _selColorless  = false;

  // --- Color identity (id:) – chip-based ---
  final _idColorMap  = <String, bool>{'w': false, 'u': false, 'b': false, 'r': false, 'g': false};
  String _idColorOp   = ':';
  bool   _idSelColorless = false;

  // --- is: selections ---
  final _selectedIs = <String>{};

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _oracleCtrl, _typeCtrl, _cmcValueCtrl, _loyCtrl,
      _manaCtrl, _powCtrl, _touCtrl, _kwCtrl, _artistCtrl,
      _flavorCtrl, _setCtrl, _usdCtrl, _eurCtrl, _tixCtrl,
      _yearCtrl, _previewCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Query builder
  // -------------------------------------------------------------------------

  String _buildQuery() {
    final parts = <String>[];

    if (_nameCtrl.text.trim().isNotEmpty)   parts.add('name:${_q(_nameCtrl.text.trim())}');
    if (_oracleCtrl.text.trim().isNotEmpty) parts.add('o:${_q(_oracleCtrl.text.trim())}');
    if (_typeCtrl.text.trim().isNotEmpty)   parts.add('t:${_q(_typeCtrl.text.trim())}');
    if (_manaCtrl.text.trim().isNotEmpty)   parts.add('m:${_manaCtrl.text.trim()}');
    if (_kwCtrl.text.trim().isNotEmpty)     parts.add('kw:${_q(_kwCtrl.text.trim())}');

    // Color (c:)
    final colorsSelected = _colorMap.entries.where((e) => e.value).map((e) => e.key).join();
    if (_selColorless) {
      parts.add('c:colorless');
    } else if (_selMulticolor) {
      parts.add('c:m');
    } else if (colorsSelected.isNotEmpty) {
      parts.add('c$_colorOp$colorsSelected');
    }

    // Color identity (id:) – chip-based
    final idSelected = _idColorMap.entries.where((e) => e.value).map((e) => e.key).join();
    if (_idSelColorless) {
      parts.add('id:colorless');
    } else if (idSelected.isNotEmpty) {
      parts.add('id$_idColorOp$idSelected');
    }

    if (_rarity != null) parts.add('r:$_rarity');

    if (_cmcValueCtrl.text.trim().isNotEmpty) parts.add('mv$_cmcOp${_cmcValueCtrl.text.trim()}');

    if (_powCtrl.text.trim().isNotEmpty) parts.add('pow$_powOp${_powCtrl.text.trim()}');
    if (_touCtrl.text.trim().isNotEmpty) {
      final op = _linkPowTou ? _powOp : _touOp;
      parts.add('tou$op${_touCtrl.text.trim()}');
    }
    if (_loyCtrl.text.trim().isNotEmpty) parts.add('loy$_loyOp${_loyCtrl.text.trim()}');

    if (_setCtrl.text.trim().isNotEmpty) parts.add('s:${_setCtrl.text.trim()}');
    if (_lang   != null) parts.add('lang:$_lang');
    if (_format != null) parts.add('f:$_format');

    if (_artistCtrl.text.trim().isNotEmpty) parts.add('a:${_q(_artistCtrl.text.trim())}');
    if (_flavorCtrl.text.trim().isNotEmpty) parts.add('ft:${_q(_flavorCtrl.text.trim())}');

    if (_usdCtrl.text.trim().isNotEmpty)  parts.add('usd$_usdOp${_usdCtrl.text.trim()}');
    if (_eurCtrl.text.trim().isNotEmpty)  parts.add('eur$_eurOp${_eurCtrl.text.trim()}');
    if (_tixCtrl.text.trim().isNotEmpty)  parts.add('tix$_tixOp${_tixCtrl.text.trim()}');
    if (_yearCtrl.text.trim().isNotEmpty) parts.add('year$_yearOp${_yearCtrl.text.trim()}');

    for (final kw in _selectedIs) {
      parts.add('is:$kw');
    }

    if (_unique    != null) parts.add('unique:$_unique');
    if (_sortOrder != null) parts.add('order:$_sortOrder');
    if (_sortDir   != null) parts.add('direction:$_sortDir');

    return parts.join(' ');
  }

  String _q(String s) {
    if (s.contains(' ')) return '"${s.replaceAll('"', '')}"';
    return s;
  }

  void _refreshPreview() {
    _previewCtrl.text = _buildQuery();
  }

  void _clearAll() {
    setState(() {
      for (final c in [
        _nameCtrl, _oracleCtrl, _typeCtrl, _cmcValueCtrl, _loyCtrl,
        _manaCtrl, _powCtrl, _touCtrl, _kwCtrl, _artistCtrl,
        _flavorCtrl, _setCtrl, _usdCtrl, _eurCtrl, _tixCtrl, _yearCtrl,
      ]) {
        c.clear();
      }
      _cmcOp = '='; _powOp = '='; _touOp = '='; _loyOp = '=';
      _usdOp = '='; _eurOp = '='; _tixOp = '='; _yearOp = '=';
      _linkPowTou = false;
      _rarity = null; _lang = null; _format = null;
      _sortOrder = null; _sortDir = null; _unique = null;
      for (final k in _colorMap.keys)   { _colorMap[k]   = false; }
      for (final k in _idColorMap.keys) { _idColorMap[k] = false; }
      _colorOp = ':'; _selMulticolor = false; _selColorless = false;
      _idColorOp = ':'; _idSelColorless = false;
      _selectedIs.clear();
      _previewCtrl.text = '';
    });
  }

  // -------------------------------------------------------------------------
  // Widget helpers
  // -------------------------------------------------------------------------

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Text(text, style: Theme.of(context).textTheme.labelLarge),
      );

  Widget _subsectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 2),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
        ),
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

  // Shared WUBRG chip row, optionally with a Multicolor chip.
  Widget _colorChips({
    required Map<String, bool> map,
    required bool selColorless,
    bool? selMulticolor,
    required void Function(String, bool) onColor,
    required void Function(bool) onColorless,
    void Function(bool)? onMulticolor,
  }) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        for (final entry in const {'w': 'W', 'u': 'U', 'b': 'B', 'r': 'R', 'g': 'G'}.entries)
          FilterChip(
            label: Text(entry.value),
            selected: map[entry.key]!,
            onSelected: (v) => onColor(entry.key, v),
          ),
        if (selMulticolor != null)
          FilterChip(
            label: const Text('Multicolor'),
            selected: selMulticolor,
            onSelected: onMulticolor,
          ),
        FilterChip(
          label: const Text('Colorless'),
          selected: selColorless,
          onSelected: onColorless,
        ),
      ],
    );
  }

  Widget _colorMatchRow(String label, String op, ValueChanged<Set<String>> onChanged) =>
      Row(children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: ':', label: Text('≥ includes')),
            ButtonSegment(value: '=', label: Text('= exactly')),
            ButtonSegment(value: '<=', label: Text('≤ at most')),
          ],
          selected: {op},
          onSelectionChanged: onChanged,
          style: const ButtonStyle(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ]);

  Widget _isGroup(String label, List<String> keywords) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _subsectionLabel(label),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final kw in keywords)
                FilterChip(
                  label: Text(kw),
                  selected: _selectedIs.contains(kw),
                  onSelected: (v) => setState(() {
                    v ? _selectedIs.add(kw) : _selectedIs.remove(kw);
                    _refreshPreview();
                  }),
                ),
            ],
          ),
        ],
      );

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final loc   = appLocalizations;
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.95,
      minChildSize: 0.3,
      expand: false,
      builder: (sheetCtx, scrollCtrl) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---- Header ----
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(children: [
                Expanded(
                  child: Text(
                    loc.translate('search.advancedFilter'),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(sheetCtx).pop(null),
                ),
              ]),
            ),

            // ---- Live query preview ----
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: TextField(
                controller: _previewCtrl,
                readOnly: true,
                decoration: InputDecoration(
                  isDense: true,
                  labelText: loc.translate('search.filterQueryPreview'),
                  labelStyle: theme.textTheme.labelSmall,
                  border: const OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  suffixIcon: _previewCtrl.text.isNotEmpty
                      ? const Icon(Icons.search, size: 16)
                      : null,
                ),
                style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
              ),
            ),

            const Divider(height: 1),

            // ---- Scrollable form body ----
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: EdgeInsets.fromLTRB(
                  16, 8, 16,
                  MediaQuery.of(sheetCtx).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name / Oracle / Type
                    _sectionLabel(loc.translate('search.filterName')),
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(isDense: true),
                      onChanged: (_) => setState(_refreshPreview),
                    ),
                    _sectionLabel(loc.translate('search.filterOracle')),
                    TextField(
                      controller: _oracleCtrl,
                      decoration: const InputDecoration(isDense: true),
                      minLines: 1,
                      maxLines: 3,
                      onChanged: (_) => setState(_refreshPreview),
                    ),
                    _sectionLabel(loc.translate('search.filterType')),
                    TextField(
                      controller: _typeCtrl,
                      decoration: const InputDecoration(isDense: true),
                      onChanged: (_) => setState(_refreshPreview),
                    ),

                    // Mana cost / Keyword ability
                    _sectionLabel(loc.translate('search.filterManaCost')),
                    TextField(
                      controller: _manaCtrl,
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: '{2}{W}{U}',
                      ),
                      onChanged: (_) => setState(_refreshPreview),
                    ),
                    _sectionLabel(loc.translate('search.filterKeyword')),
                    TextField(
                      controller: _kwCtrl,
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: 'flying, trample …',
                      ),
                      onChanged: (_) => setState(_refreshPreview),
                    ),

                    // Colors (c:)
                    _sectionLabel(loc.translate('search.filterColors')),
                    _colorChips(
                      map: _colorMap,
                      selColorless: _selColorless,
                      selMulticolor: _selMulticolor,
                      onColor: (k, v) => setState(() {
                        _colorMap[k] = v;
                        if (v) { _selMulticolor = false; _selColorless = false; }
                        _refreshPreview();
                      }),
                      onColorless: (v) => setState(() {
                        _selColorless = v;
                        if (v) {
                          _selMulticolor = false;
                          for (final k in _colorMap.keys) { _colorMap[k] = false; }
                        }
                        _refreshPreview();
                      }),
                      onMulticolor: (v) => setState(() {
                        _selMulticolor = v;
                        if (v) {
                          _selColorless = false;
                          for (final k in _colorMap.keys) { _colorMap[k] = false; }
                        }
                        _refreshPreview();
                      }),
                    ),
                    if (_colorMap.values.any((v) => v)) ...[
                      const SizedBox(height: 4),
                      _colorMatchRow(
                        loc.translate('search.filterColorMatch'),
                        _colorOp,
                        (s) => setState(() { _colorOp = s.first; _refreshPreview(); }),
                      ),
                    ],

                    // Color identity (id:) – chip-based
                    _sectionLabel(loc.translate('search.filterColorIdentity')),
                    _colorChips(
                      map: _idColorMap,
                      selColorless: _idSelColorless,
                      onColor: (k, v) => setState(() {
                        _idColorMap[k] = v;
                        if (v) { _idSelColorless = false; }
                        _refreshPreview();
                      }),
                      onColorless: (v) => setState(() {
                        _idSelColorless = v;
                        if (v) {
                          for (final k in _idColorMap.keys) { _idColorMap[k] = false; }
                        }
                        _refreshPreview();
                      }),
                    ),
                    if (_idColorMap.values.any((v) => v)) ...[
                      const SizedBox(height: 4),
                      _colorMatchRow(
                        loc.translate('search.filterIdentityMatch'),
                        _idColorOp,
                        (s) => setState(() { _idColorOp = s.first; _refreshPreview(); }),
                      ),
                    ],

                    // Rarity
                    _sectionLabel(loc.translate('search.filterRarity')),
                    DropdownButtonFormField<String>(
                      value: _rarity,
                      decoration: const InputDecoration(isDense: true),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(loc.translate('search.filterRarityAny')),
                        ),
                        ...['common', 'uncommon', 'rare', 'mythic'].map(
                          (r) => DropdownMenuItem(
                            value: r,
                            child: Text(r[0].toUpperCase() + r.substring(1)),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() { _rarity = v; _refreshPreview(); }),
                    ),

                    // Mana value
                    _sectionLabel(loc.translate('search.filterCmc')),
                    Row(children: [
                      _opDropdown(_cmcOp, (v) => setState(() { _cmcOp = v ?? '='; _refreshPreview(); })),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _cmcValueCtrl,
                          decoration: const InputDecoration(isDense: true, hintText: '0–20'),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(_refreshPreview),
                        ),
                      ),
                    ]),

                    // Power / Toughness with link-toggle
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 4),
                      child: Row(children: [
                        Expanded(
                          child: Text(
                            '${loc.translate('search.filterPower')} / '
                            '${loc.translate('search.filterToughness')}',
                            style: theme.textTheme.labelLarge,
                          ),
                        ),
                        Text(
                          loc.translate('search.filterLinkPowTou'),
                          style: const TextStyle(fontSize: 11),
                        ),
                        Switch(
                          value: _linkPowTou,
                          onChanged: (v) => setState(() {
                            _linkPowTou = v;
                            _refreshPreview();
                          }),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ]),
                    ),
                    Row(children: [
                      _opDropdown(
                        _powOp,
                        (v) => setState(() { _powOp = v ?? '='; _refreshPreview(); }),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TextField(
                          controller: _powCtrl,
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: loc.translate('search.filterPower'),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(_refreshPreview),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (!_linkPowTou)
                        _opDropdown(
                          _touOp,
                          (v) => setState(() { _touOp = v ?? '='; _refreshPreview(); }),
                        ),
                      if (!_linkPowTou) const SizedBox(width: 4),
                      Expanded(
                        child: TextField(
                          controller: _touCtrl,
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: loc.translate('search.filterToughness'),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(_refreshPreview),
                        ),
                      ),
                    ]),

                    // Loyalty
                    _sectionLabel(loc.translate('search.filterLoyalty')),
                    Row(children: [
                      _opDropdown(_loyOp, (v) => setState(() { _loyOp = v ?? '='; _refreshPreview(); })),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _loyCtrl,
                          decoration: const InputDecoration(isDense: true),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(_refreshPreview),
                        ),
                      ),
                    ]),

                    // Set
                    _sectionLabel(loc.translate('search.filterSet')),
                    TextField(
                      controller: _setCtrl,
                      decoration: const InputDecoration(isDense: true, hintText: 'one, mkm …'),
                      maxLength: 10,
                      buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                      onChanged: (_) => setState(_refreshPreview),
                    ),

                    // Language dropdown
                    _sectionLabel(loc.translate('search.filterLang')),
                    DropdownButtonFormField<String>(
                      value: _lang,
                      decoration: const InputDecoration(isDense: true),
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(loc.translate('search.filterLangAny')),
                        ),
                        ...const {
                          'en':  'English',
                          'de':  'German',
                          'fr':  'French',
                          'it':  'Italian',
                          'es':  'Spanish',
                          'pt':  'Portuguese',
                          'ja':  'Japanese',
                          'ko':  'Korean',
                          'ru':  'Russian',
                          'zhs': 'Chinese (Simplified)',
                          'zht': 'Chinese (Traditional)',
                          'ph':  'Phyrexian',
                        }.entries.map(
                          (e) => DropdownMenuItem(
                            value: e.key,
                            child: Text('${e.value} (${e.key})'),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() { _lang = v; _refreshPreview(); }),
                    ),

                    // Format dropdown
                    _sectionLabel(loc.translate('search.filterFormat')),
                    DropdownButtonFormField<String>(
                      value: _format,
                      decoration: const InputDecoration(isDense: true),
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(loc.translate('search.filterFormatAny')),
                        ),
                        ...const [
                          'standard', 'future', 'historic', 'timeless', 'gladiator',
                          'pioneer', 'modern', 'legacy', 'pauper', 'vintage', 'penny',
                          'commander', 'oathbreaker', 'standardbrawl', 'brawl',
                          'alchemy', 'paupercommander', 'duel', 'oldschool', 'premodern',
                        ].map((f) => DropdownMenuItem(value: f, child: Text(f))),
                      ],
                      onChanged: (v) => setState(() { _format = v; _refreshPreview(); }),
                    ),

                    // Artist / Flavor text
                    _sectionLabel(loc.translate('search.filterArtist')),
                    TextField(
                      controller: _artistCtrl,
                      decoration: const InputDecoration(isDense: true),
                      onChanged: (_) => setState(_refreshPreview),
                    ),
                    _sectionLabel(loc.translate('search.filterFlavorText')),
                    TextField(
                      controller: _flavorCtrl,
                      decoration: const InputDecoration(isDense: true),
                      onChanged: (_) => setState(_refreshPreview),
                    ),

                    // Prices
                    _sectionLabel(loc.translate('search.filterPriceUsd')),
                    Row(children: [
                      _opDropdown(_usdOp, (v) => setState(() { _usdOp = v ?? '='; _refreshPreview(); })),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _usdCtrl,
                          decoration: const InputDecoration(isDense: true, hintText: '0.00'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => setState(_refreshPreview),
                        ),
                      ),
                    ]),
                    _sectionLabel(loc.translate('search.filterPriceEur')),
                    Row(children: [
                      _opDropdown(_eurOp, (v) => setState(() { _eurOp = v ?? '='; _refreshPreview(); })),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _eurCtrl,
                          decoration: const InputDecoration(isDense: true, hintText: '0.00'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => setState(_refreshPreview),
                        ),
                      ),
                    ]),
                    _sectionLabel(loc.translate('search.filterPriceTix')),
                    Row(children: [
                      _opDropdown(_tixOp, (v) => setState(() { _tixOp = v ?? '='; _refreshPreview(); })),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _tixCtrl,
                          decoration: const InputDecoration(isDense: true, hintText: '0.00'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => setState(_refreshPreview),
                        ),
                      ),
                    ]),

                    // Year
                    _sectionLabel(loc.translate('search.filterYear')),
                    Row(children: [
                      _opDropdown(_yearOp, (v) => setState(() { _yearOp = v ?? '='; _refreshPreview(); })),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _yearCtrl,
                          decoration: const InputDecoration(isDense: true, hintText: '1993–2026'),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(_refreshPreview),
                        ),
                      ),
                    ]),

                    // Sort order / direction
                    _sectionLabel(loc.translate('search.filterSortOrder')),
                    Row(children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _sortOrder,
                          decoration: const InputDecoration(isDense: true),
                          isExpanded: true,
                          items: [
                            DropdownMenuItem(value: null, child: Text(loc.translate('search.filterSortDefault'))),
                            ...const [
                              'name', 'cmc', 'color', 'rarity', 'power',
                              'toughness', 'set', 'artist', 'usd', 'eur',
                              'tix', 'released',
                            ].map((f) => DropdownMenuItem(value: f, child: Text(f))),
                          ],
                          onChanged: (v) => setState(() { _sortOrder = v; _refreshPreview(); }),
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _sortDir,
                        isDense: true,
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text(loc.translate('search.filterSortAsc')),
                          ),
                          DropdownMenuItem(
                            value: 'desc',
                            child: Text(loc.translate('search.filterSortDesc')),
                          ),
                        ],
                        onChanged: (v) => setState(() { _sortDir = v; _refreshPreview(); }),
                      ),
                    ]),

                    // Unique mode
                    _sectionLabel(loc.translate('search.filterUnique')),
                    DropdownButtonFormField<String>(
                      value: _unique,
                      decoration: const InputDecoration(isDense: true),
                      items: [
                        DropdownMenuItem(value: null, child: Text(loc.translate('search.filterUniqueDefault'))),
                        DropdownMenuItem(value: 'prints', child: Text(loc.translate('search.filterUniquePrints'))),
                        DropdownMenuItem(value: 'art',    child: Text(loc.translate('search.filterUniqueArt'))),
                      ],
                      onChanged: (v) => setState(() { _unique = v; _refreshPreview(); }),
                    ),

                    // is: chips – grouped by category
                    _sectionLabel(loc.translate('search.filterIs')),
                    _isGroup(loc.translate('search.filterIsCardTypes'), const [
                      'creature', 'instant', 'sorcery', 'artifact', 'enchantment',
                      'land', 'planeswalker', 'battle', 'tribal',
                    ]),
                    _isGroup(loc.translate('search.filterIsProperties'), const [
                      'legendary', 'basic', 'snow', 'vanilla', 'frenchvanilla', 'bear',
                      'modal', 'multicolor', 'colorless', 'monocolored', 'hybrid',
                      'phyrexian', 'spell', 'permanent', 'historic', 'party',
                      'outlaw', 'manland',
                    ]),
                    _isGroup(loc.translate('search.filterIsFramePrint'), const [
                      'reprint', 'promo', 'fullart', 'foil', 'nonfoil', 'etched',
                      'textless', 'hires', 'dfc', 'mdfc', 'transform', 'split',
                      'flip', 'meld', 'funny', 'universesbeyond', 'old', 'new',
                      'colorshifted',
                    ]),
                    _isGroup(loc.translate('search.filterIsLegality'), const [
                      'commander', 'companion', 'partner', 'brawler', 'reserved',
                    ]),
                  ],
                ),
              ),
            ),

            const Divider(height: 1),

            // ---- Bottom action bar ----
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(children: [
                TextButton.icon(
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: Text(loc.translate('search.filterClearAll')),
                  onPressed: _clearAll,
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(sheetCtx).pop(null),
                  child: Text(loc.translate('search.filterCancel')),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.of(sheetCtx).pop(_buildQuery()),
                  child: Text(loc.translate('search.filterApply')),
                ),
              ]),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Search Page – helpers
// ---------------------------------------------------------------------------

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
  List<Map<String, dynamic>> _allMatches = [];
  List<dynamic>? _results;
  int _displayedCount = 0;
  static const int _pageSize = 50;
  int _searchGeneration = 0;

  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _loadingData = false;
  bool _searching = false;
  double? _downloadProgress;
  bool _downloadError = false;
  Timer? _debounce;

  // Download step tracking (for downloadingStep l10n key)
  int _downloadStep  = 0;
  int _downloadTotal = 3;

  // View mode toggle
  bool _isGridView = true;

  // Unsupported keyword warnings
  List<String> _unsupportedWarnings = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    setState(() => _loadingData = true);
    final oracle   = await _scry.loadLocalData(bulkType: ScryfallBulkType.oracleCards)  ?? [];
    final defaults = await _scry.loadLocalData(bulkType: ScryfallBulkType.defaultCards) ?? [];
    final all      = await _scry.loadLocalData(bulkType: ScryfallBulkType.allCards)     ?? [];
    final merged   = await Future(() => _mergeBulk([oracle, defaults, all]));
    if (!mounted) return;
    setState(() {
      _data = merged;
      _results = null;
      _allMatches = [];
      _displayedCount = 0;
      _loadingData = false;
    });
  }

  Future<void> _checkAndLoad({bool forceDownload = false}) async {
    setState(() {
      _loadingData = true;
      _downloadProgress = null;
      _downloadError = false;
      _downloadStep = 0;
    });
    final types = [
      ScryfallBulkType.oracleCards,
      ScryfallBulkType.defaultCards,
      ScryfallBulkType.allCards,
    ];
    _downloadTotal = types.length;
    var step = 0;
    for (final type in types) {
      step++;
      final hasLocalCache = await _scry.hasLocalCache(bulkType: type);
      final stale = await _scry.isCacheStale(bulkType: type);
      if (forceDownload || !hasLocalCache || stale) {
        final uri = await _scry.fetchBulkIndexAndChooseUri(bulkType: type);
        if (uri != null) {
          try {
            if (mounted) setState(() { _downloadProgress = 0; _downloadStep = step; });
            await _scry.downloadBulk(
              uri,
              bulkType: type,
              onProgress: (p) {
                if (mounted) setState(() => _downloadProgress = p);
              },
            );
            if (mounted) setState(() => _downloadProgress = null);
          } catch (_) {
            if (!mounted) return;
            setState(() {
              _loadingData = false;
              _downloadProgress = null;
              _downloadError = true;
            });
            return;
          }
        }
      }
    }

    final oracle   = await _scry.loadLocalData(bulkType: ScryfallBulkType.oracleCards)  ?? [];
    final defaults = await _scry.loadLocalData(bulkType: ScryfallBulkType.defaultCards) ?? [];
    final all      = await _scry.loadLocalData(bulkType: ScryfallBulkType.allCards)     ?? [];
    final merged   = await Future(() => _mergeBulk([oracle, defaults, all]));
    if (!mounted) return;
    setState(() {
      _data = merged;
      _results = null;
      _allMatches = [];
      _displayedCount = 0;
      _loadingData = false;
      _downloadProgress = null;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (_displayedCount >= _allMatches.length) return;
    setState(() {
      _displayedCount = (_displayedCount + _pageSize).clamp(0, _allMatches.length);
      _results = _allMatches.sublist(0, _displayedCount);
    });
  }

  Future<void> _executeSearch() async {
    final q = _controller.text.trim();
    if (_data == null || q.isEmpty) {
      setState(() {
        _allMatches = [];
        _displayedCount = 0;
        _results = null;
        _searching = false;
        _unsupportedWarnings = [];
      });
      return;
    }

    final generation = ++_searchGeneration;
    setState(() {
      _searching = true;
      _results = null;
    });

    final matches = await Future(
      () => _searchEngine.filterCards(_data!, q),
    );

    if (!mounted || generation != _searchGeneration) return;

    setState(() {
      _allMatches = matches;
      _displayedCount = matches.length.clamp(0, _pageSize);
      _results = _allMatches.sublist(0, _displayedCount);
      _searching = false;
      _unsupportedWarnings = _searchEngine.analyzeQuery(q);
    });
  }

  // Bug 1 fix: setState after text assignment so clear button appears.
  // Bug 2 fix: append mode – new filter clauses are added to existing query.
  Future<void> _openFilterMenu() async {
    final built = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AdvancedFilterModal(),
    );

    if (built != null && built.isNotEmpty) {
      final existing = _controller.text.trim();
      _controller.text = existing.isEmpty ? built : '$existing $built';
      setState(() {}); // refresh clear-button visibility (Bug 1)
      _debounce?.cancel();
      _executeSearch();
    }
  }

  void _showStatusInfo() {
    final loc = appLocalizations;
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.translate('search.metaTitle'),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(loc.translate('search.syntaxHint'), style: theme.textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(loc.translate('search.defaultCardsSource'), style: theme.textTheme.bodySmall),
              if (_data != null) ...[
                const SizedBox(height: 4),
                Text(
                  loc.translate('search.metaCardsLoaded').replaceAll('{count}', _data!.length.toString()),
                  style: theme.textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // Card detail bottom sheet
  void _showCardDetail(BuildContext context, Map<String, dynamic> card) {
    final loc = appLocalizations;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final theme      = Theme.of(ctx);
        final name       = card['name']?.toString()       ?? '';
        final typeLine   = card['type_line']?.toString()  ?? '';
        final oracleText = card['oracle_text']?.toString() ?? '';
        final setName    = card['set_name']?.toString()   ?? '';
        final setCode    = card['set']?.toString().toUpperCase() ?? '';
        final rarity     = card['rarity']?.toString()     ?? '';
        final manaCost   = card['mana_cost']?.toString()  ?? '';
        final legalities = card['legalities'];
        final prices     = card['prices'];

        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          maxChildSize: 0.95,
          minChildSize: 0.3,
          expand: false,
          builder: (_, scrollController) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
                child: Row(children: [
                  Expanded(
                    child: Text(
                      loc.translate('search.cardDetailTitle'),
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ]),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (manaCost.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          manaCost,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        typeLine,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontStyle: FontStyle.italic),
                      ),
                      if (setName.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          '$setName ($setCode)'
                          '${rarity.isNotEmpty ? ' · ${rarity[0].toUpperCase()}${rarity.substring(1)}' : ''}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                      if (oracleText.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(oracleText, style: theme.textTheme.bodyMedium),
                        ),
                      ],
                      if (legalities is Map && legalities.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          loc.translate('search.cardDetailLegalities'),
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            for (final entry in (legalities as Map).entries
                                .where((e) => e.value != 'not_legal'))
                              Chip(
                                label: Text(
                                  '${entry.key}: ${entry.value}',
                                  style: const TextStyle(fontSize: 10),
                                ),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                backgroundColor: entry.value == 'legal'
                                    ? Colors.green.shade100
                                    : entry.value == 'banned'
                                        ? Colors.red.shade100
                                        : Colors.orange.shade100,
                              ),
                          ],
                        ),
                      ],
                      if (prices is Map) ...[
                        const SizedBox(height: 16),
                        Text(
                          loc.translate('search.cardDetailPrices'),
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 16,
                          children: [
                            if (prices['usd'] != null)
                              Text('USD \$${prices['usd']}',
                                  style: theme.textTheme.bodySmall),
                            if (prices['eur'] != null)
                              Text('EUR €${prices['eur']}',
                                  style: theme.textTheme.bodySmall),
                            if (prices['tix'] != null)
                              Text('TIX ${prices['tix']}',
                                  style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Card image helpers
  // ---------------------------------------------------------------------------

  String? _getCardImageUrl(Map<String, dynamic> card) {
    final imageUris = card['image_uris'];
    if (imageUris is Map) {
      return (imageUris['normal'] ?? imageUris['small'] ?? imageUris['large'])
          ?.toString();
    }
    // Double-faced / adventure cards store images per face
    final faces = card['card_faces'];
    if (faces is List && faces.isNotEmpty) {
      final face0 = faces[0] as Map<String, dynamic>?;
      final faceUris = face0?['image_uris'];
      if (faceUris is Map) {
        return (faceUris['normal'] ?? faceUris['small'] ?? faceUris['large'])
            ?.toString();
      }
    }
    return null;
  }

  Widget _buildCardImageItem(BuildContext context, Map<String, dynamic> card) {
    final imageUrl = _getCardImageUrl(card);
    final name = card['name']?.toString() ?? '';
    final theme = Theme.of(context);

    Widget imageWidget;
    if (imageUrl != null) {
      imageWidget = Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return Container(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Center(
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (ctx, _, __) => _cardPlaceholder(theme, name),
      );
    } else {
      imageWidget = _cardPlaceholder(theme, name);
    }

    return GestureDetector(
      onTap: () => _showCardDetail(context, card),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageWidget,
      ),
    );
  }

  Widget _buildCardListItem(BuildContext context, Map<String, dynamic> card) {
    final name    = card['name']?.toString()    ?? '';
    final typeLine = card['type_line']?.toString() ?? '';
    final setCode = card['set']?.toString().toUpperCase() ?? '';
    final cmcRaw  = card['cmc'];
    final cmcStr  = cmcRaw != null
        ? cmcRaw.toString().replaceAll(RegExp(r'\.0$'), '')
        : '';
    final theme = Theme.of(context);

    return ListTile(
      dense: true,
      title: Text(
        name,
        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        typeLine,
        style: theme.textTheme.bodySmall,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (cmcStr.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                cmcStr,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.primary),
              ),
            ),
          const SizedBox(width: 6),
          Text(
            setCode,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.secondary),
          ),
        ],
      ),
      onTap: () => _showCardDetail(context, card),
    );
  }

  Widget _cardPlaceholder(ThemeData theme, String name) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: Text(
        name,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall,
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
          // Grid / list view toggle
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            tooltip: _isGridView ? 'List view' : 'Grid view',
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: loc.translate('search.metaTitle'),
            onPressed: _data == null ? null : _showStatusInfo,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: loc.translate('search.downloadAction'),
            onPressed: _loadingData ? null : () => _checkAndLoad(forceDownload: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // Download progress bar
          if (_downloadProgress != null) ...[
            LinearProgressIndicator(value: _downloadProgress),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _downloadStep > 0
                      ? loc
                          .translate('search.downloadingStep')
                          .replaceAll('{current}', _downloadStep.toString())
                          .replaceAll('{total}', _downloadTotal.toString())
                          .replaceAll('{progress}', '${(_downloadProgress! * 100).toInt()}')
                      : loc
                          .translate('search.statusDownloading')
                          .replaceAll('{progress}', '${(_downloadProgress! * 100).toInt()}'),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
          ],

          // Bug 4 fix: error banner with a Retry button alongside the dismiss
          if (_downloadError)
            Container(
              width: double.infinity,
              color: theme.colorScheme.errorContainer,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      size: 16, color: theme.colorScheme.onErrorContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      loc.translate('search.statusError'),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onErrorContainer),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.onErrorContainer,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      setState(() => _downloadError = false);
                      _checkAndLoad(forceDownload: true);
                    },
                    child: Text(loc.translate('search.retryDownload'),
                        style: const TextStyle(fontSize: 12)),
                  ),
                  IconButton(
                    icon: Icon(Icons.close,
                        color: theme.colorScheme.onErrorContainer),
                    iconSize: 16,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => setState(() => _downloadError = false),
                  ),
                ],
              ),
            ),

          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
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
                                      _debounce?.cancel();
                                      setState(() {
                                        _allMatches = [];
                                        _displayedCount = 0;
                                        _results = null;
                                        _unsupportedWarnings = [];
                                      });
                                    },
                                  )
                                : null,
                          ),
                          onSubmitted: (_) {
                            _debounce?.cancel();
                            _executeSearch();
                          },
                          onChanged: (_) {
                            setState(() {}); // refresh clear button visibility
                            _debounce?.cancel();
                            _debounce = Timer(
                              const Duration(milliseconds: 400),
                              _executeSearch,
                            );
                          },
                          textInputAction: TextInputAction.search,
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.tune),
                        tooltip: loc.translate('search.advancedFilter'),
                        onPressed: _data == null ? null : _openFilterMenu,
                      ),
                      IconButton(
                        icon: const Icon(Icons.help_outline),
                        tooltip: 'Search Syntax',
                        onPressed: () async {
                          final example = await Navigator.of(context).push<String>(
                            MaterialPageRoute(
                              builder: (_) => const SearchSyntaxPage(),
                            ),
                          );
                          if (example != null && example.isNotEmpty && mounted) {
                            _controller.text = example;
                            setState(() {});
                            _debounce?.cancel();
                            _executeSearch();
                          }
                        },
                      ),
                    ],
                  ),

                  // Result count header + unsupported keyword warnings
                  if (_results != null && !_searching) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _allMatches.isEmpty
                            ? loc.translate('search.noResults')
                            : _displayedCount >= _allMatches.length
                                ? loc
                                    .translate('search.resultsAll')
                                    .replaceAll('{total}', _allMatches.length.toString())
                                : loc
                                    .translate('search.resultsShowing')
                                    .replaceAll('{shown}', _displayedCount.toString())
                                    .replaceAll('{total}', _allMatches.length.toString()),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                    ),
                    if (_unsupportedWarnings.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          for (final kw in _unsupportedWarnings)
                            Chip(
                              label: Text(
                                loc
                                    .translate('search.unsupportedKeyword')
                                    .replaceAll('{keyword}', kw),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                              ),
                              backgroundColor: theme.colorScheme.errorContainer,
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                        ],
                      ),
                    ],
                  ],

                  const SizedBox(height: 8),

                  // Results / placeholder
                  Expanded(
                    child: _loadingData
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 12),
                                Text(loc.translate('search.statusPreparing')),
                              ],
                            ),
                          )
                        : _searching
                            ? const Center(child: CircularProgressIndicator())
                            : _results == null
                                ? Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.manage_search,
                                          size: 48,
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.3),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          loc.translate('search.hint'),
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.5),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          loc.translate('search.tryExample'),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.5),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 6,
                                          alignment: WrapAlignment.center,
                                          children: [
                                            for (final key in const [
                                              'example1',
                                              'example2',
                                              'example3',
                                              'example4',
                                            ])
                                              ActionChip(
                                                label: Text(
                                                  loc.translate('search.$key'),
                                                  style: theme.textTheme.labelSmall,
                                                ),
                                                onPressed: _data == null
                                                    ? null
                                                    : () {
                                                        _controller.text =
                                                            loc.translate(
                                                                'search.$key');
                                                        setState(() {});
                                                        _debounce?.cancel();
                                                        _executeSearch();
                                                      },
                                              ),
                                          ],
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
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.3),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              loc.translate('search.noResults'),
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                color: theme.colorScheme.onSurface
                                                    .withValues(alpha: 0.5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : _isGridView
                                        ? GridView.builder(
                                            controller: _scrollController,
                                            padding: EdgeInsets.zero,
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              // MTG card ratio ≈ 63 × 88 mm
                                              childAspectRatio: 63 / 88,
                                              crossAxisSpacing: 8,
                                              mainAxisSpacing: 8,
                                            ),
                                            itemCount: _results!.length,
                                            itemBuilder: (context, index) {
                                              final item = _results![index]
                                                  as Map<String, dynamic>;
                                              return _buildCardImageItem(
                                                  context, item);
                                            },
                                          )
                                        : ListView.builder(
                                            controller: _scrollController,
                                            padding: EdgeInsets.zero,
                                            itemCount: _results!.length,
                                            itemBuilder: (context, index) {
                                              final item = _results![index]
                                                  as Map<String, dynamic>;
                                              return _buildCardListItem(
                                                  context, item);
                                            },
                                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
