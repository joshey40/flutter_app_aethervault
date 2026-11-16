import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../services/card_database/database.dart';
import '../../../services/collection/collection_repository.dart';
import '../../../services/routing/card_detail_route.dart';
import '../../widgets/card_details/card_deatail_sheet.dart';
import '../../widgets/card_details/collection_copies_section.dart';
import 'collection_dialogs.dart';
import 'collection_labels.dart';
import 'edit_collection_entry_dialog.dart';

/// Detail view of a group of identical cards from the collection, with
/// actions to edit, move and delete them.
class CollectionCardPage extends StatefulWidget {
  const CollectionCardPage({required this.entryIds, super.key});

  final List<String> entryIds;

  @override
  State<CollectionCardPage> createState() => _CollectionCardPageState();
}

class _CollectionCardPageState extends State<CollectionCardPage> {
  final _repository = CollectionRepository.shared;

  late List<String> _ids;
  late Stream<List<CollectionEntry>> _entries;
  List<CollectionEntry> _current = const [];

  String? _loadedCardId;
  Future<CardDetailData?>? _cardData;
  CardDetailData? _data;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _setIds(widget.entryIds);
  }

  void _setIds(List<String> ids) {
    _ids = ids;
    _entries = _repository.watchEntries(ids);
  }

  Future<CardDetailData?> _cardDataFor(String scryfallId) {
    if (_loadedCardId != scryfallId) {
      _loadedCardId = scryfallId;
      _cardData = loadCardDetailData(scryfallId).then((data) {
        _data = data;
        return data;
      });
    }
    return _cardData!;
  }

  void _leave() {
    if (_leaving) return;
    _leaving = true;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/collection');
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } on CollectionException catch (error) {
      if (mounted) {
        showCollectionSnackBar(
          context,
          tr('collection.error', {'error': error.message}),
        );
      }
    }
  }

  Future<void> _edit() async {
    if (_current.isEmpty) return;
    final result = await showEditCollectionEntryDialog(
      context,
      entry: _current.first,
      amount: _current.length,
      variants: _data?.variants ?? const [],
    );
    if (result == null) return;
    await _run(() async {
      final ids = await _repository.updateGroup(
        [for (final entry in _current) entry.id],
        amount: result.amount,
        scryfallId: result.scryfallId,
        finish: result.finish,
        quality: result.quality,
        isProxy: result.isProxy,
        isAltered: result.isAltered,
        isSigned: result.isSigned,
      );
      if (mounted) setState(() => _setIds(ids));
    });
  }

  Future<void> _move() async {
    final target = await showFolderPicker(context);
    if (target == null) return;
    await _run(() async {
      final result = await _repository.moveEntries(
        _ids,
        target.folderId,
        board: target.board,
      );
      if (!mounted) return;
      var message = tr('collection.moved', {'count': result.moved});
      if (result.skippedPlaceholders > 0) {
        message +=
            '. ${tr('collection.skipped_placeholders', {'count': result.skippedPlaceholders})}';
      }
      showCollectionSnackBar(context, message);
    });
  }

  Future<void> _delete() async {
    final count = _current.length;
    if (!await showDeleteCardsDialog(context, count)) return;
    await _run(() async {
      await _repository.deleteEntries(_ids);
      if (!mounted) return;
      showCollectionSnackBar(
        context,
        tr('collection.deleted', {'count': count}),
      );
      _leave();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CollectionEntry>>(
      stream: _entries,
      builder: (context, snapshot) {
        final entries = snapshot.data;
        if (entries != null) _current = entries;
        if (entries != null && entries.isEmpty) {
          // All cards were deleted or don't exist (anymore).
          WidgetsBinding.instance.addPostFrameCallback((_) => _leave());
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(tr('card_detail.title')),
            leading: IconButton(
              tooltip: tr('back'),
              icon: const Icon(Icons.arrow_back),
              onPressed: _leave,
            ),
            actions: [
              IconButton(
                tooltip: tr('collection.edit_entry.title'),
                icon: const Icon(Icons.edit_outlined),
                onPressed: _current.isEmpty ? null : _edit,
              ),
              IconButton(
                tooltip: tr('collection.move'),
                icon: const Icon(Icons.drive_file_move_outlined),
                onPressed: _current.isEmpty ? null : _move,
              ),
              IconButton(
                tooltip: tr('collection.delete'),
                icon: const Icon(Icons.delete_outline),
                onPressed: _current.isEmpty ? null : _delete,
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: entries == null || entries.isEmpty
              ? const SizedBox.shrink()
              : _buildBody(entries),
        );
      },
    );
  }

  Widget _buildBody(List<CollectionEntry> entries) {
    final scryfallId = entries.first.scryfallId;
    return FutureBuilder<CardDetailData?>(
      future: _cardDataFor(scryfallId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data;
        if (data == null) {
          return Center(child: Text(tr('card_detail.not_found')));
        }
        return CardDetailSheet(
          // A new printing starts with a fresh sheet.
          key: ValueKey(scryfallId),
          card: data.card,
          faces: data.faces,
          variants: data.variants,
          variantFaces: data.variantFaces,
          showAddToCollection: false,
          showCopies: false,
          info: _EntryInfo(entries: entries),
        );
      },
    );
  }
}

/// "4× · Foil · Near Mint · Proxy" and where the cards are.
class _EntryInfo extends StatelessWidget {
  const _EntryInfo({required this.entries});

  final List<CollectionEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final first = entries.first;
    final details = [
      finishLabel(first.finish),
      qualityLabel(first.quality),
      if (first.isProxy) tr('collection.add.proxy'),
      if (first.isAltered) tr('collection.add.altered'),
      if (first.isSigned) tr('collection.add.signed'),
      if (!first.isOwned) tr('collection.copies.placeholder'),
    ].join(' · ');
    final folderIds = entries.map((entry) => entry.folderId).toSet();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${entries.length}×',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                details,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              for (final folderId in folderIds)
                DefaultTextStyle.merge(
                  style: theme.textTheme.bodySmall,
                  child: CollectionLocationText(folderId: folderId),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
