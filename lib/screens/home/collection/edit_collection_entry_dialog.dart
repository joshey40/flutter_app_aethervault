import 'package:material_ui/material_ui.dart';

import '../../../services/card_database/database.dart';
import '../../../services/collection/collection_enums.dart';
import 'collection_labels.dart';

/// The new state of a group of identical cards.
class EntryEditResult {
  const EntryEditResult({
    required this.scryfallId,
    required this.amount,
    required this.finish,
    required this.quality,
    required this.isProxy,
    required this.isAltered,
    required this.isSigned,
  });

  final String scryfallId;
  final int amount;
  final CardFinish finish;
  final CardQuality quality;
  final bool isProxy;
  final bool isAltered;
  final bool isSigned;
}

/// Edits a group of identical cards: language, printing, amount, finish,
/// condition and flags. [variants] are all printings of the card (may be
/// empty if the Scryfall data is missing; then printing can't be changed).
Future<EntryEditResult?> showEditCollectionEntryDialog(
  BuildContext context, {
  required CollectionEntry entry,
  required int amount,
  required List<ScryfallCard> variants,
}) {
  return showDialog<EntryEditResult>(
    context: context,
    builder: (context) => _EditCollectionEntryDialog(
      entry: entry,
      amount: amount,
      variants: variants,
    ),
  );
}

class _EditCollectionEntryDialog extends StatefulWidget {
  const _EditCollectionEntryDialog({
    required this.entry,
    required this.amount,
    required this.variants,
  });

  final CollectionEntry entry;
  final int amount;
  final List<ScryfallCard> variants;

  @override
  State<_EditCollectionEntryDialog> createState() =>
      _EditCollectionEntryDialogState();
}

class _EditCollectionEntryDialogState
    extends State<_EditCollectionEntryDialog> {
  late String _scryfallId = widget.entry.scryfallId;
  late int _amount = widget.amount;
  late CardFinish _finish = widget.entry.finish;
  late CardQuality _quality = widget.entry.quality;
  late bool _isProxy = widget.entry.isProxy;
  late bool _isAltered = widget.entry.isAltered;
  late bool _isSigned = widget.entry.isSigned;

  ScryfallCard? get _printing {
    for (final variant in widget.variants) {
      if (variant.scryfallId == _scryfallId) return variant;
    }
    return null;
  }

  List<String> get _languages =>
      widget.variants.map((variant) => variant.lang).toSet().toList()..sort();

  List<ScryfallCard> _printingsIn(String? language) =>
      widget.variants.where((variant) => variant.lang == language).toList()
        ..sort((a, b) => b.releasedAt.compareTo(a.releasedAt));

  List<CardFinish> get _availableFinishes {
    final card = _printing;
    if (card == null) return CardFinish.values;
    final finishes = [
      if (card.nonfoil) CardFinish.nonfoil,
      if (card.foil) CardFinish.foil,
      if (card.etched) CardFinish.etched,
    ];
    return finishes.isEmpty ? CardFinish.values : finishes;
  }

  void _selectPrinting(String scryfallId) {
    setState(() {
      _scryfallId = scryfallId;
      final finishes = _availableFinishes;
      if (!finishes.contains(_finish)) _finish = finishes.first;
    });
  }

  /// Switches the language and keeps the same set if it exists there.
  void _selectLanguage(String language) {
    final printings = _printingsIn(language);
    if (printings.isEmpty) return;
    final sameSet = printings.where(
      (printing) => printing.setCode == _printing?.setCode,
    );
    _selectPrinting(
      (sameSet.isEmpty ? printings.first : sameSet.first).scryfallId,
    );
  }

  String _printingLabel(ScryfallCard card) =>
      '${card.setName} (${card.setCode.toUpperCase()} #${card.collectorNumber})';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final printing = _printing;

    return AlertDialog(
      title: Text(tr('collection.edit_entry.title')),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (printing != null) ...[
                DropdownButtonFormField<String>(
                  initialValue: printing.lang,
                  decoration: InputDecoration(
                    labelText: tr('collection.edit_entry.language'),
                  ),
                  items: [
                    for (final language in _languages)
                      DropdownMenuItem(
                        value: language,
                        child: Text(language.toUpperCase()),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) _selectLanguage(value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  // Rebuild when the language changes the list.
                  key: ValueKey('printings-${printing.lang}'),
                  initialValue: printing.scryfallId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: tr('collection.edit_entry.printing'),
                  ),
                  items: [
                    for (final variant in _printingsIn(printing.lang))
                      DropdownMenuItem(
                        value: variant.scryfallId,
                        child: Text(
                          _printingLabel(variant),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) _selectPrinting(value);
                  },
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(child: Text(tr('collection.add.amount'))),
                  IconButton.outlined(
                    tooltip: '-1',
                    icon: const Icon(Icons.remove),
                    onPressed: _amount > 1
                        ? () => setState(() => _amount--)
                        : null,
                  ),
                  SizedBox(
                    width: 44,
                    child: Text(
                      '$_amount',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  IconButton.outlined(
                    tooltip: '+1',
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() => _amount++),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(tr('collection.add.finish')),
              const SizedBox(height: 6),
              SegmentedButton<CardFinish>(
                showSelectedIcon: false,
                segments: [
                  for (final finish in CardFinish.values)
                    ButtonSegment(
                      value: finish,
                      label: Text(finishLabel(finish)),
                      enabled: _availableFinishes.contains(finish),
                    ),
                ],
                selected: {_finish},
                onSelectionChanged: (selection) =>
                    setState(() => _finish = selection.single),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CardQuality>(
                initialValue: _quality,
                decoration: InputDecoration(
                  labelText: tr('collection.add.quality'),
                ),
                items: [
                  for (final quality in CardQuality.values)
                    DropdownMenuItem(
                      value: quality,
                      child: Text(qualityLabel(quality)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _quality = value);
                },
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: Text(tr('collection.add.proxy')),
                    selected: _isProxy,
                    onSelected: (value) => setState(() => _isProxy = value),
                  ),
                  FilterChip(
                    label: Text(tr('collection.add.altered')),
                    selected: _isAltered,
                    onSelected: (value) => setState(() => _isAltered = value),
                  ),
                  FilterChip(
                    label: Text(tr('collection.add.signed')),
                    selected: _isSigned,
                    onSelected: (value) => setState(() => _isSigned = value),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tr('cancel')),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            EntryEditResult(
              scryfallId: _scryfallId,
              amount: _amount,
              finish: _finish,
              quality: _quality,
              isProxy: _isProxy,
              isAltered: _isAltered,
              isSigned: _isSigned,
            ),
          ),
          child: Text(tr('save')),
        ),
      ],
    );
  }
}
