import 'package:flutter/material.dart';

import '../../../services/localization_service.dart';

/// Advanced filter modal rebuilt with full fields and safe layout.
class AdvancedFilterModal extends StatefulWidget {
  const AdvancedFilterModal({super.key});

  @override
  State<AdvancedFilterModal> createState() => _AdvancedFilterModalState();
}

class _AdvancedFilterModalState extends State<AdvancedFilterModal> {
  // --- Controllers ---
  final _nameCtrl = TextEditingController();
  final _oracleCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _manaCtrl = TextEditingController();
  final _kwCtrl = TextEditingController();
  final _cmcCtrl = TextEditingController();
  final _powCtrl = TextEditingController();
  final _touCtrl = TextEditingController();
  final _loyCtrl = TextEditingController();
  final _setCtrl = TextEditingController();
  final _artistCtrl = TextEditingController();
  final _flavorCtrl = TextEditingController();
  final _usdCtrl = TextEditingController();
  final _eurCtrl = TextEditingController();
  final _tixCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _previewCtrl = TextEditingController();

  // --- Operators / flags ---
  String _cmcOp = '=';
  String _powOp = '=';
  String _touOp = '=';
  String _loyOp = '=';
  bool _linkPowTou = false;

  // --- Dropdowns ---
  String? _rarity;
  String? _lang;
  String? _format;
  String? _sortOrder;
  String? _sortDir;
  String? _unique;

  // --- Colors ---
  final _colorMap = <String, bool>{'w': false, 'u': false, 'b': false, 'r': false, 'g': false};
  bool _selColorless = false;
  bool _selMulticolor = false;
  String _colorOp = ':';

  // --- Color identity ---
  final _idColorMap = <String, bool>{'w': false, 'u': false, 'b': false, 'r': false, 'g': false};
  bool _idColorless = false;
  String _idColorOp = ':';

  // --- is: selections ---
  final _selectedIs = <String>{};

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _oracleCtrl,
      _typeCtrl,
      _manaCtrl,
      _kwCtrl,
      _cmcCtrl,
      _powCtrl,
      _touCtrl,
      _loyCtrl,
      _setCtrl,
      _artistCtrl,
      _flavorCtrl,
      _usdCtrl,
      _eurCtrl,
      _tixCtrl,
      _yearCtrl,
      _previewCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String _q(String s) => s.contains(' ') ? '"${s.replaceAll('"', '')}"' : s;

  String _buildQuery() {
    final parts = <String>[];

    if (_nameCtrl.text.trim().isNotEmpty) parts.add('name:${_q(_nameCtrl.text.trim())}');
    if (_oracleCtrl.text.trim().isNotEmpty) parts.add('o:${_q(_oracleCtrl.text.trim())}');
    if (_typeCtrl.text.trim().isNotEmpty) parts.add('t:${_q(_typeCtrl.text.trim())}');
    if (_manaCtrl.text.trim().isNotEmpty) parts.add('m:${_manaCtrl.text.trim()}');
    if (_kwCtrl.text.trim().isNotEmpty) parts.add('kw:${_q(_kwCtrl.text.trim())}');

    final colors = _colorMap.entries.where((e) => e.value).map((e) => e.key).join();
    if (_selColorless) {
      parts.add('c:colorless');
    } else if (_selMulticolor) {
      parts.add('c:m');
    } else if (colors.isNotEmpty) {
      parts.add('c$_colorOp$colors');
    }

    final idColors = _idColorMap.entries.where((e) => e.value).map((e) => e.key).join();
    if (_idColorless) {
      parts.add('id:colorless');
    } else if (idColors.isNotEmpty) {
      parts.add('id$_idColorOp$idColors');
    }

    if (_rarity != null) parts.add('r:$_rarity');
    if (_cmcCtrl.text.trim().isNotEmpty) parts.add('mv$_cmcOp${_cmcCtrl.text.trim()}');

    if (_powCtrl.text.trim().isNotEmpty) parts.add('pow$_powOp${_powCtrl.text.trim()}');
    if (_touCtrl.text.trim().isNotEmpty) {
      final op = _linkPowTou ? _powOp : _touOp;
      parts.add('tou$op${_touCtrl.text.trim()}');
    }
    if (_loyCtrl.text.trim().isNotEmpty) parts.add('loy$_loyOp${_loyCtrl.text.trim()}');

    if (_setCtrl.text.trim().isNotEmpty) parts.add('s:${_setCtrl.text.trim()}');
    if (_lang != null) parts.add('lang:$_lang');
    if (_format != null) parts.add('f:$_format');

    if (_artistCtrl.text.trim().isNotEmpty) parts.add('a:${_q(_artistCtrl.text.trim())}');
    if (_flavorCtrl.text.trim().isNotEmpty) parts.add('ft:${_q(_flavorCtrl.text.trim())}');

    if (_usdCtrl.text.trim().isNotEmpty) parts.add('usd${_usdCtrl.text.trim()}');
    if (_eurCtrl.text.trim().isNotEmpty) parts.add('eur${_eurCtrl.text.trim()}');
    if (_tixCtrl.text.trim().isNotEmpty) parts.add('tix${_tixCtrl.text.trim()}');
    if (_yearCtrl.text.trim().isNotEmpty) parts.add('year${_yearCtrl.text.trim()}');

    for (final kw in _selectedIs) {
      parts.add('is:$kw');
    }

    if (_unique != null) parts.add('unique:$_unique');
    if (_sortOrder != null) parts.add('order:$_sortOrder');
    if (_sortDir != null) parts.add('direction:$_sortDir');

    return parts.join(' ');
  }

  void _refreshPreview() => _previewCtrl.text = _buildQuery();

  void _clearAll() {
    setState(() {
      for (final c in [
        _nameCtrl,
        _oracleCtrl,
        _typeCtrl,
        _manaCtrl,
        _kwCtrl,
        _cmcCtrl,
        _powCtrl,
        _touCtrl,
        _loyCtrl,
        _setCtrl,
        _artistCtrl,
        _flavorCtrl,
        _usdCtrl,
        _eurCtrl,
        _tixCtrl,
        _yearCtrl,
      ]) {
        c.clear();
      }
      _cmcOp = '=';
      _powOp = '=';
      _touOp = '=';
      _loyOp = '=';
      _linkPowTou = false;
      _rarity = null;
      _lang = null;
      _format = null;
      _sortOrder = null;
      _sortDir = null;
      _unique = null;
      for (final k in _colorMap.keys) {
        _colorMap[k] = false;
      }
      for (final k in _idColorMap.keys) {
        _idColorMap[k] = false;
      }
      _selColorless = false;
      _selMulticolor = false;
      _colorOp = ':';
      _idColorless = false;
      _idColorOp = ':';
      _selectedIs.clear();
      _previewCtrl.text = '';
    });
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Text(text, style: Theme.of(context).textTheme.labelLarge),
      );

  Widget _subsectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 2),
        child: Text(text, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
      );

  Widget _opDropdown(String value, ValueChanged<String?> onChanged) => DropdownButton<String>(
        value: value,
        isDense: true,
        items: const ['=', '>', '<', '>=', '<=', '!='].map((op) => DropdownMenuItem(value: op, child: Text(op))).toList(),
        onChanged: onChanged,
      );

  Widget _colorChips({required Map<String, bool> map, required bool selColorless, bool? selMulticolor, required void Function(String, bool) onColor, required void Function(bool) onColorless, void Function(bool)? onMulticolor}) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        for (final entry in const {'w': 'W', 'u': 'U', 'b': 'B', 'r': 'R', 'g': 'G'}.entries)
          FilterChip(label: Text(entry.value), selected: map[entry.key]!, onSelected: (v) => onColor(entry.key, v)),
        if (selMulticolor != null)
          FilterChip(label: const Text('Multicolor'), selected: selMulticolor, onSelected: onMulticolor),
        FilterChip(label: const Text('Colorless'), selected: selColorless, onSelected: onColorless),
      ],
    );
  }

  Widget _colorMatchRow(String label, String op, ValueChanged<Set<String>> onChanged) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: ':', label: Text('≥ includes')),
                ButtonSegment(value: '=', label: Text('= exactly')),
                ButtonSegment(value: '<=', label: Text('≤ at most')),
              ],
              selected: {op},
              onSelectionChanged: onChanged,
              style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap, visualDensity: VisualDensity.compact),
            ),
          ),
        ],
      );

  Widget _isGroup(String label, List<String> keywords) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _subsectionLabel(label),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final kw in keywords)
                FilterChip(label: Text(kw), selected: _selectedIs.contains(kw), onSelected: (v) => setState(() { v ? _selectedIs.add(kw) : _selectedIs.remove(kw); _refreshPreview(); })),
            ],
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final loc = appLocalizations;
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(children: [
                Expanded(child: Text(loc.translate('search.advancedFilter'), style: theme.textTheme.titleMedium)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(sheetCtx).pop(null)),
              ]),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: TextField(controller: _previewCtrl, readOnly: true, decoration: InputDecoration(isDense: true, labelText: loc.translate('search.filterQueryPreview'), border: const OutlineInputBorder()), style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace')),
            ),

            const Divider(height: 1),

            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(sheetCtx).viewInsets.bottom + 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel(loc.translate('search.filterName')),
                    TextField(controller: _nameCtrl, decoration: const InputDecoration(isDense: true), onChanged: (_) => setState(_refreshPreview)),

                    _sectionLabel(loc.translate('search.filterOracle')),
                    TextField(controller: _oracleCtrl, decoration: const InputDecoration(isDense: true), minLines: 1, maxLines: 3, onChanged: (_) => setState(_refreshPreview)),

                    _sectionLabel(loc.translate('search.filterType')),
                    TextField(controller: _typeCtrl, decoration: const InputDecoration(isDense: true), onChanged: (_) => setState(_refreshPreview)),

                    _sectionLabel(loc.translate('search.filterManaCost')),
                    TextField(controller: _manaCtrl, decoration: const InputDecoration(isDense: true, hintText: '{2}{W}{U}'), onChanged: (_) => setState(_refreshPreview)),

                    _sectionLabel(loc.translate('search.filterKeyword')),
                    TextField(controller: _kwCtrl, decoration: const InputDecoration(isDense: true, hintText: 'flying, trample …'), onChanged: (_) => setState(_refreshPreview)),

                    _sectionLabel(loc.translate('search.filterColors')),
                    _colorChips(
                      map: _colorMap,
                      selColorless: _selColorless,
                      selMulticolor: _selMulticolor,
                      onColor: (k, v) => setState(() {
                        _colorMap[k] = v;
                        if (v) {
                          _selMulticolor = false;
                          _selColorless = false;
                        }
                        _refreshPreview();
                      }),
                      onColorless: (v) => setState(() {
                        _selColorless = v;
                        if (v) {
                          _selMulticolor = false;
                          for (final k in _colorMap.keys) {
                            _colorMap[k] = false;
                          }
                        }
                        _refreshPreview();
                      }),
                      onMulticolor: (v) => setState(() {
                        _selMulticolor = v;
                        if (v) {
                          _selColorless = false;
                          for (final k in _colorMap.keys) {
                            _colorMap[k] = false;
                          }
                        }
                        _refreshPreview();
                      }),
                    ),
                    if (_colorMap.values.any((v) => v)) ...[
                      const SizedBox(height: 4),
                      _colorMatchRow(loc.translate('search.filterColorMatch'), _colorOp, (s) => setState(() { _colorOp = s.first; _refreshPreview(); })),
                    ],

                    _sectionLabel(loc.translate('search.filterColorIdentity')),
                    _colorChips(
                      map: _idColorMap,
                      selColorless: _idColorless,
                      onColor: (k, v) => setState(() {
                        _idColorMap[k] = v;
                        if (v) _idColorless = false;
                        _refreshPreview();
                      }),
                      onColorless: (v) => setState(() {
                        _idColorless = v;
                        if (v) {
                          for (final k in _idColorMap.keys) {
                            _idColorMap[k] = false;
                          }
                        }
                        _refreshPreview();
                      }),
                    ),
                    if (_idColorMap.values.any((v) => v)) ...[
                      const SizedBox(height: 4),
                      _colorMatchRow(loc.translate('search.filterIdentityMatch'), _idColorOp, (s) => setState(() { _idColorOp = s.first; _refreshPreview(); })),
                    ],

                    _sectionLabel(loc.translate('search.filterRarity')),
                    DropdownButtonFormField<String>(initialValue: _rarity, decoration: const InputDecoration(isDense: true), items: [
                      DropdownMenuItem(value: null, child: Text(loc.translate('search.filterRarityAny'))),
                      ...['common', 'uncommon', 'rare', 'mythic'].map((r) => DropdownMenuItem(value: r, child: Text(r[0].toUpperCase() + r.substring(1)))),
                    ], onChanged: (v) => setState(() { _rarity = v; _refreshPreview(); })),

                    _sectionLabel(loc.translate('search.filterCmc')),
                    Row(children: [
                      _opDropdown(_cmcOp, (v) => setState(() { _cmcOp = v ?? '='; _refreshPreview(); })),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: _cmcCtrl, decoration: const InputDecoration(isDense: true, hintText: '0–20'), keyboardType: TextInputType.number, onChanged: (_) => setState(_refreshPreview))),
                    ]),

                    Padding(padding: const EdgeInsets.only(top: 12, bottom: 4), child: Row(children: [
                      Expanded(child: Text('${loc.translate('search.filterPower')} / ${loc.translate('search.filterToughness')}', style: theme.textTheme.labelLarge)),
                      Text(loc.translate('search.filterLinkPowTou'), style: const TextStyle(fontSize: 11)),
                      Switch(value: _linkPowTou, onChanged: (v) => setState(() { _linkPowTou = v; _refreshPreview(); }), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    ])),

                    Row(children: [
                      _opDropdown(_powOp, (v) => setState(() { _powOp = v ?? '='; _refreshPreview(); })),
                      const SizedBox(width: 4),
                      Expanded(child: TextField(controller: _powCtrl, decoration: InputDecoration(isDense: true, labelText: loc.translate('search.filterPower')), keyboardType: TextInputType.number, onChanged: (_) => setState(_refreshPreview))),
                      const SizedBox(width: 12),
                      if (!_linkPowTou) _opDropdown(_touOp, (v) => setState(() { _touOp = v ?? '='; _refreshPreview(); })),
                      if (!_linkPowTou) const SizedBox(width: 4),
                      Expanded(child: TextField(controller: _touCtrl, decoration: InputDecoration(isDense: true, labelText: loc.translate('search.filterToughness')), keyboardType: TextInputType.number, onChanged: (_) => setState(_refreshPreview))),
                    ]),

                    _sectionLabel(loc.translate('search.filterLoyalty')),
                    Row(children: [
                      _opDropdown(_loyOp, (v) => setState(() { _loyOp = v ?? '='; _refreshPreview(); })),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: _loyCtrl, decoration: const InputDecoration(isDense: true), keyboardType: TextInputType.number, onChanged: (_) => setState(_refreshPreview))),
                    ]),

                    _sectionLabel(loc.translate('search.filterSet')),
                    TextField(controller: _setCtrl, decoration: const InputDecoration(isDense: true, hintText: 'one, mkm …'), maxLength: 10, buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null, onChanged: (_) => setState(_refreshPreview)),

                    _sectionLabel(loc.translate('search.filterLang')),
                    DropdownButtonFormField<String>(initialValue: _lang, decoration: const InputDecoration(isDense: true), isExpanded: true, items: [
                      DropdownMenuItem(value: null, child: Text(loc.translate('search.filterLangAny'))),
                      ...const {
                        'en': 'English',
                        'de': 'German',
                        'fr': 'French',
                        'it': 'Italian',
                        'es': 'Spanish',
                        'pt': 'Portuguese',
                        'ja': 'Japanese',
                        'ko': 'Korean',
                        'ru': 'Russian',
                        'zhs': 'Chinese (Simplified)',
                        'zht': 'Chinese (Traditional)',
                        'ph': 'Phyrexian',
                      }.entries.map((e) => DropdownMenuItem(value: e.key, child: Text('${e.value} (${e.key})'))),
                    ], onChanged: (v) => setState(() { _lang = v; _refreshPreview(); })),

                    _sectionLabel(loc.translate('search.filterArtist')),
                    TextField(controller: _artistCtrl, decoration: const InputDecoration(isDense: true), onChanged: (_) => setState(_refreshPreview)),
                    _sectionLabel(loc.translate('search.filterFlavorText')),
                    TextField(controller: _flavorCtrl, decoration: const InputDecoration(isDense: true), onChanged: (_) => setState(_refreshPreview)),

                    _sectionLabel(loc.translate('search.filterPriceUsd')),
                    Row(children: [
                      _opDropdown('=', (v) {}),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: _usdCtrl, decoration: const InputDecoration(isDense: true, hintText: '0.00'), keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: (_) => setState(_refreshPreview))),
                    ]),

                    _sectionLabel(loc.translate('search.filterYear')),
                    Row(children: [
                      _opDropdown('=', (v) {}),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: _yearCtrl, decoration: const InputDecoration(isDense: true, hintText: '1993–2026'), keyboardType: TextInputType.number, onChanged: (_) => setState(_refreshPreview))),
                    ]),

                    _sectionLabel(loc.translate('search.filterIs')),
                    _isGroup(loc.translate('search.filterIsCardTypes'), const ['creature', 'instant', 'sorcery', 'artifact', 'enchantment', 'land', 'planeswalker', 'battle', 'tribal']),
                    _isGroup(loc.translate('search.filterIsProperties'), const ['legendary', 'basic', 'snow', 'vanilla', 'frenchvanilla', 'bear', 'modal', 'multicolor', 'colorless', 'monocolored', 'hybrid', 'phyrexian', 'spell', 'permanent']),
                  ],
                ),
              ),
            ),

            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(children: [
                TextButton.icon(icon: const Icon(Icons.clear_all, size: 16), label: Text(loc.translate('search.filterClearAll')), style: TextButton.styleFrom(minimumSize: const Size(64, 36), tapTargetSize: MaterialTapTargetSize.shrinkWrap), onPressed: _clearAll),
                const Spacer(),
                ElevatedButton(style: ElevatedButton.styleFrom(minimumSize: const Size(64, 36)), onPressed: () => Navigator.of(sheetCtx).pop(_buildQuery()), child: Text(loc.translate('search.filterApply'))),
              ]),
            ),
          ],
        );
      },
    );
  }
}
