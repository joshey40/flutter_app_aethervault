import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../services/card_database/database.dart';
import '../../../services/collection/collection_enums.dart';
import '../../../services/collection/collection_repository.dart';
import '../../../services/import/card_import_resolver.dart';
import '../../../services/import/card_list_parser.dart';
import 'collection_dialogs.dart';
import 'collection_labels.dart';

/// Imports a pasted card list (text list or CSV export of another app) into
/// the collection. Every line is checked against the Scryfall data and shown
/// in a review list before anything is added.
class CollectionImportPage extends StatefulWidget {
  const CollectionImportPage({this.folderId, super.key});

  /// The folder to import into, null = root.
  final String? folderId;

  @override
  State<CollectionImportPage> createState() => _CollectionImportPageState();
}

class _CollectionImportPageState extends State<CollectionImportPage> {
  final _database = AppDatabase();
  final _repository = CollectionRepository.shared;
  final _textController = TextEditingController();

  FolderTarget _target = FolderTarget(folderId: null, label: rootFolderLabel);

  /// Null while the text is being edited, set once it was checked.
  List<ResolvedImportLine>? _lines;
  List<ImportLineError> _errors = const [];

  /// Thumbnails of double-faced cards, which only have images per face.
  final _faceImages = <String, String>{};
  bool _working = false;

  @override
  void initState() {
    super.initState();
    _loadTarget();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadTarget() async {
    final folderId = widget.folderId;
    if (folderId == null) return;
    final folder = await _repository.getFolder(folderId);
    if (folder != null && mounted) {
      setState(
        () => _target = FolderTarget(folderId: folderId, label: folder.name),
      );
    }
  }

  Future<void> _pickTarget() async {
    final target = await showFolderPicker(context);
    if (target == null) return;
    setState(
      () => _target = target.folderId == null
          ? FolderTarget(folderId: null, label: rootFolderLabel)
          : target,
    );
  }

  Future<void> _check() async {
    final parsed = parseCardList(_textController.text);
    setState(() => _working = true);
    final lines = await CardImportResolver(_database).resolve(parsed.lines);
    await _loadFaceImages(lines);
    if (!mounted) return;
    setState(() {
      _working = false;
      _lines = lines;
      _errors = parsed.errors;
    });
  }

  Future<void> _loadFaceImages(List<ResolvedImportLine> lines) async {
    final missing = [
      for (final line in lines)
        if (line.card != null && line.card!.imageSmall == null)
          line.card!.scryfallId,
    ];
    _faceImages.addAll(await _database.getFrontFaceImages(missing));
  }

  Future<void> _import() async {
    final lines = _lines!.where((line) => line.willImport).toList();
    setState(() => _working = true);
    try {
      final added = await _repository.addCardBatch(
        [
          for (final line in lines)
            (
              scryfallId: line.card!.scryfallId,
              amount: line.line.quantity,
              finish: line.line.finish,
              quality: line.line.quality,
              isProxy: line.line.isProxy,
              isAltered: line.line.isAltered,
              isSigned: line.line.isSigned,
            ),
        ],
        folderId: _target.folderId,
        board: _target.board,
      );
      if (!mounted) return;
      showCollectionSnackBar(
        context,
        tr('collection.import.done', {'count': added, 'target': _target.label}),
      );
      context.pop();
    } on CollectionException catch (error) {
      if (!mounted) return;
      setState(() => _working = false);
      showCollectionSnackBar(
        context,
        tr('collection.error', {'error': error.message}),
      );
    }
  }

  Future<void> _changePrinting(ResolvedImportLine line) async {
    final card = line.card;
    if (card == null) return;
    final variants = card.oracleId == null
        ? [card]
        : await _database.getCardVariantsByOracleId(card.oracleId!);
    if (!mounted) return;
    final picked = await showDialog<ScryfallCard>(
      context: context,
      builder: (context) => _PrintingPickerDialog(
        variants: variants,
        selectedId: card.scryfallId,
      ),
    );
    if (picked == null) return;
    final pickedLine = ResolvedImportLine(line: line.line, card: picked);
    await _loadFaceImages([pickedLine]);
    if (!mounted) return;
    setState(() {
      line.card = picked;
      // The user decided, so the hints don't apply anymore.
      line.notes
        ..remove(ImportNote.ambiguousPrinting)
        ..remove(ImportNote.languageFallback);
    });
  }

  Future<void> _changeName(int index) async {
    final line = _lines![index];
    final controller = TextEditingController(text: line.line.name ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('collection.import.change_name')),
        content: TextField(
          controller: controller,
          autofocus: true,
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(tr('ok')),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty) return;
    // A corrected name means set and number of the line were wrong too.
    final corrected = ImportLine(
      lineNumber: line.line.lineNumber,
      raw: line.line.raw,
      quantity: line.line.quantity,
      name: name.trim(),
      language: line.line.language,
      finish: line.line.finish,
      quality: line.line.quality,
      isProxy: line.line.isProxy,
      isAltered: line.line.isAltered,
      isSigned: line.line.isSigned,
    );
    final resolved = await CardImportResolver(_database).resolveOne(corrected);
    await _loadFaceImages([resolved]);
    if (mounted) setState(() => _lines![index] = resolved);
  }

  @override
  Widget build(BuildContext context) {
    final reviewing = _lines != null;
    return PopScope(
      canPop: !reviewing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _lines = null);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr('collection.import.title')),
          leading: IconButton(
            tooltip: tr('back'),
            icon: const Icon(Icons.arrow_back),
            onPressed: () =>
                reviewing ? setState(() => _lines = null) : context.pop(),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: reviewing ? _buildReview() : _buildInput(),
          ),
        ),
      ),
    );
  }

  Widget _buildTarget() {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: _working ? null : _pickTarget,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: tr('collection.add.target'),
          prefixIcon: Icon(Icons.folder_outlined, color: colorScheme.primary),
          suffixIcon: Icon(
            Icons.keyboard_arrow_down,
            color: colorScheme.primary,
          ),
        ),
        child: Text(_target.label, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  Widget _buildInput() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(tr('collection.import.hint'), style: theme.textTheme.bodySmall),
        const SizedBox(height: 12),
        _buildTarget(),
        const SizedBox(height: 12),
        Expanded(
          child: TextField(
            controller: _textController,
            expands: true,
            maxLines: null,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            decoration: InputDecoration(
              hintText: '4 Lightning Bolt (M10) 146\n1 Sol Ring *F*\n...',
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _working || _textController.text.trim().isEmpty
              ? null
              : _check,
          icon: _working
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.fact_check_outlined),
          label: Text(tr('collection.import.check')),
        ),
      ],
    );
  }

  Widget _buildReview() {
    final theme = Theme.of(context);
    final lines = _lines!;
    final certain = lines.where((l) => l.isCertain && !l.skip).length;
    final hinted = lines
        .where((l) => l.card != null && !l.isCertain && !l.skip)
        .length;
    final missing = lines.where((l) => l.card == null).length;
    final cardCount = lines
        .where((l) => l.willImport)
        .fold<int>(0, (sum, l) => sum + l.line.quantity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTarget(),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _SummaryChip(
              icon: Icons.check_circle_outline,
              color: Colors.green.shade600,
              label: tr('collection.import.certain', {'count': certain}),
            ),
            _SummaryChip(
              icon: Icons.info_outline,
              color: Colors.amber.shade700,
              label: tr('collection.import.hinted', {'count': hinted}),
            ),
            _SummaryChip(
              icon: Icons.error_outline,
              color: theme.colorScheme.error,
              label: tr('collection.import.missing', {
                'count': missing + _errors.length,
              }),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            children: [
              for (var i = 0; i < lines.length; i++)
                _ReviewTile(
                  line: lines[i],
                  faceImage: lines[i].card == null
                      ? null
                      : _faceImages[lines[i].card!.scryfallId],
                  onChangePrinting: () => _changePrinting(lines[i]),
                  onChangeName: () => _changeName(i),
                  onToggleSkip: () =>
                      setState(() => lines[i].skip = !lines[i].skip),
                ),
              for (final error in _errors)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.error,
                  ),
                  title: Text(
                    error.raw,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    tr('collection.import.line_error', {
                      'line': error.lineNumber,
                      'error': error.message,
                    }),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _working || cardCount == 0 ? null : _import,
          icon: _working
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download_done),
          label: Text(tr('collection.import.submit', {'count': cardCount})),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.line,
    required this.faceImage,
    required this.onChangePrinting,
    required this.onChangeName,
    required this.onToggleSkip,
  });

  final ResolvedImportLine line;

  /// Fallback image for cards without their own (double-faced cards).
  final String? faceImage;
  final VoidCallback onChangePrinting;
  final VoidCallback onChangeName;
  final VoidCallback onToggleSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final card = line.card;
    final imported = line.line;

    final (icon, color) = switch (line) {
      _ when line.skip => (Icons.block, colorScheme.outline),
      _ when card == null => (Icons.error_outline, colorScheme.error),
      _ when !line.isCertain => (Icons.info_outline, Colors.amber.shade700),
      _ => (Icons.check_circle_outline, Colors.green.shade600),
    };

    final details = [
      if (card != null)
        '${card.setCode.toUpperCase()} #${card.collectorNumber}',
      if (card != null) card.lang.toUpperCase(),
      if (imported.finish != CardFinish.nonfoil) finishLabel(imported.finish),
      if (imported.quality != CardQuality.unknown)
        qualityShort(imported.quality),
      if (imported.isProxy) tr('collection.add.proxy'),
      if (imported.isAltered) tr('collection.add.altered'),
      if (imported.isSigned) tr('collection.add.signed'),
    ].join(' · ');

    final notes = [
      if (line.notes.contains(ImportNote.ambiguousPrinting))
        tr('collection.import.note_ambiguous'),
      if (line.notes.contains(ImportNote.languageFallback))
        tr('collection.import.note_language', {
          'language': imported.language?.toUpperCase() ?? '',
        }),
      if (line.notes.contains(ImportNote.notFound))
        tr('collection.import.note_not_found', {'line': imported.raw.trim()}),
    ];

    final thumbnail = card?.imageSmall ?? faceImage;
    return Opacity(
      opacity: line.skip ? 0.5 : 1,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                width: 32,
                height: 45,
                child: thumbnail == null
                    ? ColoredBox(color: colorScheme.surfaceContainerHighest)
                    : CachedNetworkImage(
                        imageUrl: thumbnail,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ],
        ),
        title: Text(
          '${imported.quantity}× ${card?.name ?? imported.name ?? _printingLabel(imported)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (details.isNotEmpty) Text(details),
            for (final note in notes)
              Text(note, style: TextStyle(color: color)),
          ],
        ),
        trailing: PopupMenuButton<VoidCallback>(
          tooltip: tr('collection.more'),
          onSelected: (action) => action(),
          itemBuilder: (context) => [
            if (card != null)
              PopupMenuItem(
                value: onChangePrinting,
                child: Text(tr('collection.import.change_printing')),
              ),
            PopupMenuItem(
              value: onChangeName,
              child: Text(tr('collection.import.change_name')),
            ),
            if (card != null)
              PopupMenuItem(
                value: onToggleSkip,
                child: Text(
                  tr(
                    line.skip
                        ? 'collection.import.include'
                        : 'collection.import.skip',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// "MSC #211" for lines without a name, else the Scryfall ID.
String _printingLabel(ImportLine line) => line.setCode != null
    ? '${line.setCode!.toUpperCase()} #${line.collectorNumber ?? ''}'
    : line.scryfallId ?? '';

/// Lists all printings (sets and languages) of a card to pick one.
class _PrintingPickerDialog extends StatelessWidget {
  const _PrintingPickerDialog({
    required this.variants,
    required this.selectedId,
  });

  final List<ScryfallCard> variants;
  final String selectedId;

  @override
  Widget build(BuildContext context) {
    final sorted = [...variants]
      ..sort((a, b) => b.releasedAt.compareTo(a.releasedAt));
    return AlertDialog(
      title: Text(tr('collection.import.change_printing')),
      content: SizedBox(
        width: 420,
        height: 460,
        child: ListView(
          children: [
            for (final card in sorted)
              ListTile(
                selected: card.scryfallId == selectedId,
                leading: SizedBox(
                  width: 32,
                  height: 45,
                  child: card.imageSmall == null
                      ? null
                      : CachedNetworkImage(
                          imageUrl: card.imageSmall!,
                          fit: BoxFit.cover,
                        ),
                ),
                title: Text(card.setName),
                subtitle: Text(
                  '${card.setCode.toUpperCase()} #${card.collectorNumber} · '
                  '${card.lang.toUpperCase()} · ${card.releasedAt}',
                ),
                onTap: () => Navigator.of(context).pop(card),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tr('cancel')),
        ),
      ],
    );
  }
}
