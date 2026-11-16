import 'package:material_ui/material_ui.dart';

import '../../../services/app_preferences_storage.dart';
import '../../../services/card_database/database.dart';
import '../../../services/collection/collection_enums.dart';
import '../../../services/collection/collection_repository.dart';
import '../../home/collection/collection_dialogs.dart';
import '../../home/collection/collection_labels.dart';

/// Asks how many copies of [card] to add, where to, and with which
/// properties, then adds them. Starts with the last used folder and condition.
Future<void> showAddToCollectionDialog(
  BuildContext context,
  ScryfallCard card,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final initialTarget = await _loadLastTarget();
  final initialQuality = await AppPreferencesStorage()
      .loadCollectionLastAddQuality();
  if (!context.mounted) return;

  final count = await showDialog<int>(
    context: context,
    builder: (context) => _AddToCollectionDialog(
      card: card,
      initialTarget: initialTarget,
      initialQuality: initialQuality == null
          ? CardQuality.nearMint
          : CardQuality.fromValue(initialQuality),
    ),
  );
  if (count == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          tr('collection.added', {'count': count, 'name': card.name}),
        ),
      ),
    );
}

/// The last folder cards were added to, if it still exists.
Future<FolderTarget> _loadLastTarget() async {
  const root = FolderTarget(folderId: null, label: '');
  final stored = await AppPreferencesStorage().loadCollectionLastAddTarget();
  if (stored == null || stored.isEmpty) return root;

  final [folderId, boardValue] = '$stored|'.split('|').take(2).toList();
  if (folderId.isEmpty) return root;
  final folder = await CollectionRepository.shared.getFolder(folderId);
  if (folder == null) return root;

  final board = folder.folderType == FolderType.deck
      ? FolderType.fromValue(int.tryParse(boardValue) ?? FolderType.main.value)
      : null;
  return FolderTarget(
    folderId: folder.id,
    board: board,
    label: board == null
        ? folder.name
        : '${folder.name} › ${boardLabel(board)}',
  );
}

class _AddToCollectionDialog extends StatefulWidget {
  const _AddToCollectionDialog({
    required this.card,
    required this.initialTarget,
    required this.initialQuality,
  });

  final ScryfallCard card;
  final FolderTarget initialTarget;
  final CardQuality initialQuality;

  @override
  State<_AddToCollectionDialog> createState() => _AddToCollectionDialogState();
}

class _AddToCollectionDialogState extends State<_AddToCollectionDialog> {
  late FolderTarget _target = widget.initialTarget;
  late CardQuality _quality = widget.initialQuality;
  late CardFinish _finish = _availableFinishes.first;
  int _amount = 1;
  bool _isProxy = false;
  bool _isAltered = false;
  bool _isSigned = false;
  bool _saving = false;
  String? _error;

  /// The finishes this printing exists in, according to Scryfall.
  List<CardFinish> get _availableFinishes {
    final card = widget.card;
    final finishes = [
      if (card.nonfoil) CardFinish.nonfoil,
      if (card.foil) CardFinish.foil,
      if (card.etched) CardFinish.etched,
    ];
    return finishes.isEmpty ? CardFinish.values : finishes;
  }

  String get _targetLabel =>
      _target.folderId == null ? rootFolderLabel : _target.label;

  Future<void> _pickTarget() async {
    final target = await showFolderPicker(context);
    if (target != null) setState(() => _target = target);
  }

  Future<void> _submit() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await CollectionRepository.shared.addCards(
        scryfallId: widget.card.scryfallId,
        amount: _amount,
        folderId: _target.folderId,
        board: _target.board,
        finish: _finish,
        quality: _quality,
        isProxy: _isProxy,
        isAltered: _isAltered,
        isSigned: _isSigned,
      );
      final preferences = AppPreferencesStorage();
      await preferences.saveCollectionLastAddTarget(
        '${_target.folderId ?? ''}|${_target.board?.value ?? ''}',
      );
      await preferences.saveCollectionLastAddQuality(_quality.value);
      if (mounted) Navigator.of(context).pop(_amount);
    } on CollectionException catch (error) {
      setState(() {
        _saving = false;
        _error = tr('collection.error', {'error': error.message});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final card = widget.card;

    return AlertDialog(
      title: Text(tr('collection.add.title')),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${card.name} · ${card.setCode.toUpperCase()} #${card.collectorNumber}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _pickTarget,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: tr('collection.add.target'),
                    prefixIcon: Icon(
                      _target.board != null
                          ? Icons.space_dashboard_outlined
                          : Icons.folder_outlined,
                      color: colorScheme.primary,
                    ),
                    suffixIcon: Icon(
                      Icons.keyboard_arrow_down,
                      color: colorScheme.primary,
                    ),
                  ),
                  child: Text(_targetLabel, overflow: TextOverflow.ellipsis),
                ),
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
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
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: colorScheme.error)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(tr('cancel')),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: Text(tr('collection.add.submit')),
        ),
      ],
    );
  }
}
