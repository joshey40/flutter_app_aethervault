import 'package:material_ui/material_ui.dart';

import '../../../services/card_database/database.dart';
import '../../../services/collection/collection_repository.dart';
import '../../home/collection/collection_dialogs.dart';
import '../../home/collection/collection_labels.dart';

/// Lists where the user's copies of [card] are, grouped by location and
/// properties, with actions to move, edit or remove them. Shows nothing if
/// the user has no copies.
class CollectionCopiesSection extends StatelessWidget {
  const CollectionCopiesSection({required this.card, super.key});

  final ScryfallCard card;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CollectionEntry>>(
      stream: CollectionRepository.shared.watchEntriesForCard(card.scryfallId),
      builder: (context, snapshot) {
        final entries = snapshot.data ?? const <CollectionEntry>[];
        if (entries.isEmpty) return const SizedBox.shrink();

        final groups = <String, List<CollectionEntry>>{};
        for (final entry in entries) {
          final key = [
            entry.folderId,
            entry.finish.value,
            entry.quality.value,
            entry.isProxy,
            entry.isAltered,
            entry.isSigned,
            entry.isOwned,
          ].join('|');
          groups.putIfAbsent(key, () => []).add(entry);
        }
        final owned = entries.where((entry) => entry.isOwned).length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${tr('collection.copies.title')} ($owned)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            for (final group in groups.values) _CopyRow(entries: group),
          ],
        );
      },
    );
  }
}

class _CopyRow extends StatelessWidget {
  const _CopyRow({required this.entries});

  /// Copies with the same location and properties.
  final List<CollectionEntry> entries;

  CollectionEntry get _first => entries.first;
  List<String> get _ids => [for (final entry in entries) entry.id];

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } on CollectionException catch (error) {
      if (context.mounted) {
        showCollectionSnackBar(
          context,
          tr('collection.error', {'error': error.message}),
        );
      }
    }
  }

  Future<void> _move(BuildContext context) async {
    final target = await showFolderPicker(context);
    if (target == null || !context.mounted) return;
    await _run(context, () async {
      final result = await CollectionRepository.shared.moveEntries(
        _ids,
        target.folderId,
        board: target.board,
      );
      if (result.skippedPlaceholders > 0 && context.mounted) {
        showCollectionSnackBar(
          context,
          tr('collection.skipped_placeholders', {
            'count': result.skippedPlaceholders,
          }),
        );
      }
    });
  }

  Future<void> _edit(BuildContext context) async {
    final first = _first;
    final changes = await showEditEntriesDialog(context, [
      EntryProperties(
        finish: first.finish,
        quality: first.quality,
        isProxy: first.isProxy,
        isAltered: first.isAltered,
        isSigned: first.isSigned,
      ),
    ]);
    if (changes == null || !context.mounted) return;
    await _run(
      context,
      () => CollectionRepository.shared.updateEntries(
        _ids,
        finish: changes.finish,
        quality: changes.quality,
        isProxy: changes.isProxy,
        isAltered: changes.isAltered,
        isSigned: changes.isSigned,
      ),
    );
  }

  Future<void> _remove(BuildContext context, {required bool all}) async {
    final ids = all ? _ids : [_ids.first];
    if (all && !await showDeleteCardsDialog(context, ids.length)) return;
    if (!context.mounted) return;
    await _run(context, () => CollectionRepository.shared.deleteEntries(ids));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final first = _first;
    final details = [
      finishLabel(first.finish),
      qualityLabel(first.quality),
      if (first.isProxy) tr('collection.add.proxy'),
      if (first.isAltered) tr('collection.add.altered'),
      if (first.isSigned) tr('collection.add.signed'),
      if (!first.isOwned) tr('collection.copies.placeholder'),
    ].join(' · ');

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Text(
        '${entries.length}×',
        style: theme.textTheme.titleMedium?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      title: CollectionLocationText(folderId: first.folderId),
      subtitle: Text(details),
      trailing: PopupMenuButton<String>(
        tooltip: tr('collection.more'),
        onSelected: (action) => switch (action) {
          'move' => _move(context),
          'edit' => _edit(context),
          'remove_one' => _remove(context, all: false),
          _ => _remove(context, all: true),
        },
        itemBuilder: (context) => [
          PopupMenuItem(value: 'move', child: Text(tr('collection.move'))),
          PopupMenuItem(
            value: 'edit',
            child: Text(tr('collection.edit_cards')),
          ),
          PopupMenuItem(
            value: 'remove_one',
            child: Text(tr('collection.copies.remove_one')),
          ),
          if (entries.length > 1)
            PopupMenuItem(
              value: 'remove_all',
              child: Text(tr('collection.copies.remove_all')),
            ),
        ],
      ),
    );
  }
}

/// "Collection › Binder › Atraxa › Main" for a folder.
class CollectionLocationText extends StatelessWidget {
  const CollectionLocationText({required this.folderId, super.key});

  final String? folderId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Folder>>(
      future: CollectionRepository.shared.getFolderPath(folderId),
      builder: (context, snapshot) {
        final path = snapshot.data ?? const <Folder>[];
        final names = [
          if (path.isEmpty) rootFolderLabel,
          for (final folder in path)
            folder.folderType.isBoard
                ? boardLabel(folder.folderType)
                : folder.name,
        ];
        return Text(
          names.join(' › '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
