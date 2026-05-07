import 'package:flutter/material.dart';

import '../../../../services/localization_service.dart';

Future<void> showCardDetailSheet(
  BuildContext context,
  Map<String, dynamic> card, {
  List<Map<String, dynamic>> variants = const [],
}) async {
  final loc = appLocalizations;
  final allVariants = variants.isEmpty ? [card] : variants;
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final allSetCodes = allVariants
          .map((entry) => entry['set']?.toString() ?? '')
          .where((entry) => entry.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      final allLangs = allVariants
          .map((entry) => entry['lang']?.toString() ?? '')
          .where((entry) => entry.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      String? selectedSet = card['set']?.toString();
      String? selectedLang = card['lang']?.toString();
      if (selectedSet != null && selectedSet.isEmpty) selectedSet = null;
      if (selectedLang != null && selectedLang.isEmpty) selectedLang = null;
      Map<String, dynamic> selectedCard = card;

      return StatefulBuilder(
        builder: (ctx, setState) {
          Map<String, dynamic> _selectVariantByFilters({
            String? setCode,
            String? lang,
          }) {
            final matches = allVariants.where((entry) {
              final setMatch = setCode == null || setCode.isEmpty
                  ? true
                  : entry['set']?.toString() == setCode;
              final langMatch = lang == null || lang.isEmpty
                  ? true
                  : entry['lang']?.toString() == lang;
              return setMatch && langMatch;
            }).toList();
            if (matches.isEmpty) return selectedCard;
            matches.sort((a, b) {
              final ad = a['released_at']?.toString() ?? '';
              final bd = b['released_at']?.toString() ?? '';
              return bd.compareTo(ad);
            });
            return matches.first;
          }

          selectedCard =
              _selectVariantByFilters(setCode: selectedSet, lang: selectedLang);
          selectedSet = selectedCard['set']?.toString();
          selectedLang = selectedCard['lang']?.toString();
          if (selectedSet != null && selectedSet.isEmpty) selectedSet = null;
          if (selectedLang != null && selectedLang.isEmpty) selectedLang = null;

          final name = selectedCard['name']?.toString() ?? '';
          final typeLine = selectedCard['type_line']?.toString() ?? '';
          final oracleText = selectedCard['oracle_text']?.toString() ?? '';
          final setName = selectedCard['set_name']?.toString() ?? '';
          final setCode = selectedCard['set']?.toString().toUpperCase() ?? '';
          final rarity = selectedCard['rarity']?.toString() ?? '';
          final manaCost = selectedCard['mana_cost']?.toString() ?? '';
          final legalities = selectedCard['legalities'];
          final prices = selectedCard['prices'];

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
                      child: Text(loc.translate('search.cardDetailTitle'), style: theme.textTheme.titleMedium),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(ctx).pop()),
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
                        Text(name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        if (allVariants.length > 1) ...[
                          const SizedBox(height: 6),
                          Text(
                            loc
                                .translate('search.cardDetailVariants')
                                .replaceAll('{count}', allVariants.length.toString()),
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: selectedSet,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    labelText:
                                        loc.translate('search.cardDetailSet'),
                                  ),
                                  items: [
                                    for (final code in allSetCodes)
                                      DropdownMenuItem(
                                        value: code,
                                        child: Text(code.toUpperCase()),
                                      ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedSet = value;
                                       selectedCard = _selectVariantByFilters(
                                         setCode: value,
                                         lang: selectedLang,
                                       );
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: selectedLang,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    labelText:
                                        loc.translate('search.cardDetailLang'),
                                  ),
                                  items: [
                                    for (final lang in allLangs)
                                      DropdownMenuItem(
                                        value: lang,
                                        child: Text(lang.toUpperCase()),
                                      ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedLang = value;
                                       selectedCard = _selectVariantByFilters(
                                         setCode: selectedSet,
                                         lang: value,
                                       );
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (manaCost.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(manaCost, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary)),
                        ],
                        const SizedBox(height: 4),
                        Text(typeLine, style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
                        if (setName.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text('$setName ($setCode)'
                              '${rarity.isNotEmpty ? ' · ${rarity[0].toUpperCase()}${rarity.substring(1)}' : ''}', style: theme.textTheme.bodySmall),
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
                          Text(loc.translate('search.cardDetailLegalities'), style: theme.textTheme.titleSmall),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              for (final entry in (legalities).entries.where((e) => e.value != 'not_legal'))
                                Chip(
                                  label: Text('${entry.key}: ${entry.value}', style: const TextStyle(fontSize: 10)),
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                          Text(loc.translate('search.cardDetailPrices'), style: theme.textTheme.titleSmall),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 16,
                            children: [
                              if (prices['usd'] != null) Text('USD \$${prices['usd']}', style: theme.textTheme.bodySmall),
                              if (prices['eur'] != null) Text('EUR €${prices['eur']}', style: theme.textTheme.bodySmall),
                              if (prices['tix'] != null) Text('TIX ${prices['tix']}', style: theme.textTheme.bodySmall),
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
    },
  );
}
