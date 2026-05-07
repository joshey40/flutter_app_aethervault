import 'package:flutter/material.dart';

import '../../../../services/localization_service.dart';

Future<void> showCardDetailSheet(BuildContext context, Map<String, dynamic> card) async {
  final loc = appLocalizations;
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final name = card['name']?.toString() ?? '';
      final typeLine = card['type_line']?.toString() ?? '';
      final oracleText = card['oracle_text']?.toString() ?? '';
      final setName = card['set_name']?.toString() ?? '';
      final setCode = card['set']?.toString().toUpperCase() ?? '';
      final rarity = card['rarity']?.toString() ?? '';
      final manaCost = card['mana_cost']?.toString() ?? '';
      final legalities = card['legalities'];
      final prices = card['prices'];

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
}
