import 'package:material_ui/material_ui.dart';

import '../../../services/card_database/database.dart';
import '../../../services/collection/collection_enums.dart';
import '../../../services/collection/collection_repository.dart';
import 'collection_labels.dart';

// =============================================================================
// Folder picker
// =============================================================================

/// Where cards should go: a box, the root, or a board inside a deck.
class FolderTarget {
  const FolderTarget({required this.folderId, this.board, required this.label});

  /// Null = root.
  final String? folderId;

  /// Only set if [folderId] is a deck.
  final FolderType? board;

  /// Human readable, e.g. "Atraxa › Main".
  final String label;
}

/// Lets the user browse the folders and pick a box, the root, or a board of a
/// deck. Returns null if cancelled.
///
/// When moving a box or deck, pass it as [movingFolder]: then only boxes and
/// the root can be picked, and the folder itself can't be opened.
Future<FolderTarget?> showFolderPicker(
  BuildContext context, {
  Folder? movingFolder,
}) {
  return showDialog<FolderTarget>(
    context: context,
    builder: (context) => _FolderPickerDialog(movingFolder: movingFolder),
  );
}

class _FolderPickerDialog extends StatefulWidget {
  const _FolderPickerDialog({this.movingFolder});

  final Folder? movingFolder;

  @override
  State<_FolderPickerDialog> createState() => _FolderPickerDialogState();
}

class _FolderPickerDialogState extends State<_FolderPickerDialog> {
  final _repository = CollectionRepository.shared;

  /// The boxes opened so far, the last one is shown.
  final _path = <Folder>[];

  /// If set, the boards of this deck are shown.
  Folder? _deck;

  Folder? get _current => _path.isEmpty ? null : _path.last;

  void _back() {
    setState(() {
      if (_deck != null) {
        _deck = null;
      } else if (_path.isNotEmpty) {
        _path.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final canGoBack = _deck != null || _path.isNotEmpty;
    final title = _deck != null
        ? tr('collection.picker.choose_board', {'name': _deck!.name})
        : _current?.name ?? rootFolderLabel;

    return AlertDialog(
      title: Text(tr('collection.picker.title')),
      content: SizedBox(
        width: 380,
        height: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (canGoBack)
                  IconButton(
                    tooltip: tr('back'),
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _back,
                  ),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: _deck != null
                  ? _buildBoardList()
                  : StreamBuilder<List<Folder>>(
                      stream: _repository.watchChildFolders(_current?.id),
                      builder: (context, snapshot) {
                        final moving = widget.movingFolder;
                        final folders = (snapshot.data ?? const <Folder>[])
                            .where(
                              (folder) =>
                                  moving == null ||
                                  (folder.folderType == FolderType.box &&
                                      folder.id != moving.id),
                            )
                            .toList();
                        return ListView(
                          children: [
                            for (final folder in folders)
                              ListTile(
                                leading: Icon(
                                  folderIcon(folder.folderType),
                                  color:
                                      parseFolderColor(folder.color) ??
                                      colorScheme.primary,
                                ),
                                title: Text(folder.name),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => setState(() {
                                  if (folder.folderType == FolderType.deck) {
                                    _deck = folder;
                                  } else {
                                    _path.add(folder);
                                  }
                                }),
                              ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tr('cancel')),
        ),
        if (_deck == null)
          FilledButton(
            onPressed: () => Navigator.of(context).pop(
              FolderTarget(
                folderId: _current?.id,
                label: _current?.name ?? rootFolderLabel,
              ),
            ),
            child: Text(tr('collection.picker.choose_here')),
          ),
      ],
    );
  }

  Widget _buildBoardList() {
    final deck = _deck!;
    return ListView(
      children: [
        for (final board in FolderType.boards)
          ListTile(
            title: Text(boardLabel(board)),
            onTap: () => Navigator.of(context).pop(
              FolderTarget(
                folderId: deck.id,
                board: board,
                label: '${deck.name} › ${boardLabel(board)}',
              ),
            ),
          ),
      ],
    );
  }
}

// =============================================================================
// Folder form (create / edit)
// =============================================================================

class FolderFormResult {
  const FolderFormResult({
    required this.name,
    required this.color,
    required this.isPrivate,
    required this.format,
    required this.bracket,
    required this.description,
  });

  final String name;
  final String? color;
  final bool isPrivate;
  final String? format;
  final int? bracket;
  final String? description;
}

/// Asks for the properties of a new or existing box or deck.
Future<FolderFormResult?> showFolderForm(
  BuildContext context, {
  required FolderType type,
  Folder? existing,
}) {
  return showDialog<FolderFormResult>(
    context: context,
    builder: (context) => _FolderFormDialog(type: type, existing: existing),
  );
}

class _FolderFormDialog extends StatefulWidget {
  const _FolderFormDialog({required this.type, this.existing});

  final FolderType type;
  final Folder? existing;

  @override
  State<_FolderFormDialog> createState() => _FolderFormDialogState();
}

class _FolderFormDialogState extends State<_FolderFormDialog> {
  late final TextEditingController _name;
  late final TextEditingController _description;
  String? _color;
  bool _isPrivate = false;
  String? _format;
  int? _bracket;
  String? _nameError;

  bool get _isDeck => widget.type == FolderType.deck;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _name = TextEditingController(text: existing?.name ?? '');
    _description = TextEditingController(text: existing?.description ?? '');
    _color = existing?.color;
    _isPrivate = existing?.isPrivate ?? false;
    _format = existing?.format;
    _bracket = existing?.bracket;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = tr('collection.folder_form.name_required'));
      return;
    }
    final description = _description.text.trim();
    Navigator.of(context).pop(
      FolderFormResult(
        name: name,
        color: _color,
        isPrivate: _isPrivate,
        format: _isDeck ? _format : null,
        bracket: _isDeck && _format == 'commander' ? _bracket : null,
        description: description.isEmpty ? null : description,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.existing != null
        ? 'collection.folder_form.edit'
        : _isDeck
        ? 'collection.folder_form.new_deck'
        : 'collection.folder_form.new_box';

    return AlertDialog(
      title: Text(tr(title)),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _name,
                autofocus: widget.existing == null,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                onChanged: (_) {
                  if (_nameError != null) setState(() => _nameError = null);
                },
                decoration: InputDecoration(
                  labelText: tr('collection.folder_form.name'),
                  errorText: _nameError,
                ),
              ),
              const SizedBox(height: 16),
              Text(tr('collection.folder_form.color')),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ColorDot(
                    color: null,
                    selected: _color == null,
                    tooltip: tr('collection.folder_form.no_color'),
                    onTap: () => setState(() => _color = null),
                  ),
                  for (final hex in folderColors)
                    _ColorDot(
                      color: parseFolderColor(hex),
                      selected: _color == hex,
                      onTap: () => setState(() => _color = hex),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(tr('collection.private')),
                subtitle: Text(tr('collection.folder_form.private_hint')),
                value: _isPrivate,
                onChanged: (value) => setState(() => _isPrivate = value),
              ),
              if (_isDeck) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<String?>(
                  initialValue: _format,
                  decoration: InputDecoration(
                    labelText: tr('collection.folder_form.format'),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(tr('collection.folder_form.no_format')),
                    ),
                    for (final format in deckFormats)
                      DropdownMenuItem(
                        value: format,
                        child: Text(formatLabel(format)),
                      ),
                  ],
                  onChanged: (value) => setState(() => _format = value),
                ),
                if (_format == 'commander') ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int?>(
                    initialValue: _bracket,
                    decoration: InputDecoration(
                      labelText: tr('collection.folder_form.bracket'),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(tr('collection.folder_form.no_bracket')),
                      ),
                      for (var bracket = 1; bracket <= 5; bracket++)
                        DropdownMenuItem(
                          value: bracket,
                          child: Text('$bracket'),
                        ),
                    ],
                    onChanged: (value) => setState(() => _bracket = value),
                  ),
                ],
              ],
              const SizedBox(height: 12),
              TextField(
                controller: _description,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: tr('collection.folder_form.description'),
                ),
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
        FilledButton(onPressed: _submit, child: Text(tr('save'))),
      ],
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
    this.tooltip,
  });

  final Color? color;
  final bool selected;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dot = InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outline,
            width: selected ? 3 : 1,
          ),
        ),
        child: color == null
            ? Icon(Icons.block, size: 16, color: colorScheme.outline)
            : null,
      ),
    );
    return tooltip == null ? dot : Tooltip(message: tooltip!, child: dot);
  }
}

// =============================================================================
// Delete folder
// =============================================================================

/// Asks whether to delete [folder]. Returns null if cancelled, otherwise
/// whether its contents should be kept (moved to [parentLabel]).
Future<bool?> showDeleteFolderDialog(
  BuildContext context, {
  required Folder folder,
  required int cardCount,
  required String parentLabel,
}) {
  final isDeck = folder.folderType == FolderType.deck;
  var keepContents = false;

  return showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final keepText = !keepContents
            ? tr('collection.delete_folder.keep_off')
            : tr(
                isDeck
                    ? 'collection.delete_folder.keep_on_deck'
                    : 'collection.delete_folder.keep_on',
                {'target': parentLabel},
              );
        return AlertDialog(
          title: Text(
            tr(
              isDeck
                  ? 'collection.delete_folder.title_deck'
                  : 'collection.delete_folder.title_box',
            ),
          ),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  tr('collection.delete_folder.contents', {
                    'name': folder.name,
                    'count': cardCount,
                  }),
                ),
                if (isDeck) ...[
                  const SizedBox(height: 4),
                  Text(tr('collection.delete_folder.boards_note')),
                ],
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(tr('collection.delete_folder.keep')),
                  subtitle: Text(keepText),
                  value: keepContents,
                  onChanged: (value) => setState(() => keepContents = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(tr('cancel')),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () => Navigator.of(context).pop(keepContents),
              child: Text(tr('collection.delete')),
            ),
          ],
        );
      },
    ),
  );
}

/// Asks whether [count] cards should be deleted.
Future<bool> showDeleteCardsDialog(BuildContext context, int count) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(tr('collection.delete_cards_title')),
      content: Text(tr('collection.delete_cards_body', {'count': count})),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(tr('cancel')),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(tr('collection.delete')),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

// =============================================================================
// Edit card properties
// =============================================================================

/// The editable properties of one or more cards.
class EntryProperties {
  const EntryProperties({
    required this.finish,
    required this.quality,
    required this.isProxy,
    required this.isAltered,
    required this.isSigned,
  });

  /// Null = leave unchanged.
  final CardFinish? finish;
  final CardQuality? quality;
  final bool? isProxy;
  final bool? isAltered;
  final bool? isSigned;
}

/// Lets the user change properties of cards. Values the [current] cards don't
/// share start as "unchanged". Returns only the values that should change.
Future<EntryProperties?> showEditEntriesDialog(
  BuildContext context,
  List<EntryProperties> current,
) {
  T? common<T>(T? Function(EntryProperties p) read) {
    final values = current.map(read).toSet();
    return values.length == 1 ? values.single : null;
  }

  final initial = EntryProperties(
    finish: common((p) => p.finish),
    quality: common((p) => p.quality),
    isProxy: common((p) => p.isProxy),
    isAltered: common((p) => p.isAltered),
    isSigned: common((p) => p.isSigned),
  );

  return showDialog<EntryProperties>(
    context: context,
    builder: (context) => _EditEntriesDialog(initial: initial),
  );
}

class _EditEntriesDialog extends StatefulWidget {
  const _EditEntriesDialog({required this.initial});

  final EntryProperties initial;

  @override
  State<_EditEntriesDialog> createState() => _EditEntriesDialogState();
}

class _EditEntriesDialogState extends State<_EditEntriesDialog> {
  late CardFinish? _finish = widget.initial.finish;
  late CardQuality? _quality = widget.initial.quality;
  late bool? _isProxy = widget.initial.isProxy;
  late bool? _isAltered = widget.initial.isAltered;
  late bool? _isSigned = widget.initial.isSigned;

  /// Only report what actually changed.
  T? _changed<T>(T? value, T? initial) => value == initial ? null : value;

  @override
  Widget build(BuildContext context) {
    final unchanged = tr('collection.edit_entries.unchanged');
    final initial = widget.initial;

    Widget flag(
      String label,
      bool? value,
      bool? initialValue,
      ValueChanged<bool?> onChanged,
    ) {
      return CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        tristate: initialValue == null,
        title: Text(label),
        subtitle: value == null ? Text(unchanged) : null,
        value: value,
        onChanged: onChanged,
      );
    }

    return AlertDialog(
      title: Text(tr('collection.edit_entries.title')),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<CardFinish?>(
              initialValue: _finish,
              decoration: InputDecoration(
                labelText: tr('collection.add.finish'),
              ),
              items: [
                if (initial.finish == null)
                  DropdownMenuItem(value: null, child: Text(unchanged)),
                for (final finish in CardFinish.values)
                  DropdownMenuItem(
                    value: finish,
                    child: Text(finishLabel(finish)),
                  ),
              ],
              onChanged: (value) => setState(() => _finish = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<CardQuality?>(
              initialValue: _quality,
              decoration: InputDecoration(
                labelText: tr('collection.add.quality'),
              ),
              items: [
                if (initial.quality == null)
                  DropdownMenuItem(value: null, child: Text(unchanged)),
                for (final quality in CardQuality.values)
                  DropdownMenuItem(
                    value: quality,
                    child: Text(qualityLabel(quality)),
                  ),
              ],
              onChanged: (value) => setState(() => _quality = value),
            ),
            const SizedBox(height: 8),
            flag(
              tr('collection.add.proxy'),
              _isProxy,
              initial.isProxy,
              (v) => setState(() => _isProxy = v),
            ),
            flag(
              tr('collection.add.altered'),
              _isAltered,
              initial.isAltered,
              (v) => setState(() => _isAltered = v),
            ),
            flag(
              tr('collection.add.signed'),
              _isSigned,
              initial.isSigned,
              (v) => setState(() => _isSigned = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tr('cancel')),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            EntryProperties(
              finish: _changed(_finish, initial.finish),
              quality: _changed(_quality, initial.quality),
              isProxy: _changed(_isProxy, initial.isProxy),
              isAltered: _changed(_isAltered, initial.isAltered),
              isSigned: _changed(_isSigned, initial.isSigned),
            ),
          ),
          child: Text(tr('save')),
        ),
      ],
    );
  }
}
