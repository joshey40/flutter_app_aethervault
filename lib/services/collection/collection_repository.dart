import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../card_database/database.dart';
import 'collection_enums.dart';

/// Thrown when a collection operation is not allowed, e.g. adding a
/// placeholder to a box or moving a folder into itself.
class CollectionException implements Exception {
  const CollectionException(this.message);

  final String message;

  @override
  String toString() => 'CollectionException: $message';
}

/// Identical physical cards, grouped for display.
class CardGroup {
  const CardGroup({
    required this.scryfallId,
    required this.finish,
    required this.quality,
    required this.isProxy,
    required this.isAltered,
    required this.isSigned,
    required this.isOwned,
    required this.count,
    required this.lastAddedAt,
    this.board,
  });

  final String scryfallId;
  final CardFinish finish;
  final CardQuality quality;
  final bool isProxy;
  final bool isAltered;
  final bool isSigned;
  final bool isOwned;
  final int count;

  /// Newest addedAt of the cards in this group (Unix ms).
  final int lastAddedAt;

  /// The board the cards are in. Only set when a single deck is shown.
  final FolderType? board;
}

/// Result of [CollectionRepository.moveEntries].
class MoveResult {
  const MoveResult({required this.moved, required this.skippedPlaceholders});

  final int moved;

  /// Placeholders can only live inside decks, so they are not moved out.
  final int skippedPlaceholders;
}

/// Reads and changes the local collection (folders, decks and cards).
///
/// Every change marks the touched rows as dirty so they get synced later.
/// Nothing is hard-deleted here: rows are only marked with isDeleted.
class CollectionRepository {
  CollectionRepository(this._db, {Uuid? uuid, int Function()? now})
    : _uuid = uuid ?? const Uuid(),
      _now = now ?? (() => DateTime.now().millisecondsSinceEpoch);

  final AppDatabase _db;
  final Uuid _uuid;
  final int Function() _now;

  /// Namespace for board folder IDs. Never change it: every device must
  /// compute the same ID for the same board, otherwise boards get duplicated.
  static const boardIdNamespace = '386b7927-da35-4683-8b1d-f036641a993c';

  /// The ID of the [board] folder inside the deck [deckId]. It is derived from
  /// both, so two devices that create the same board offline agree on its ID.
  static String boardFolderId(String deckId, FolderType board) {
    assert(board.isBoard);
    return const Uuid().v5(boardIdNamespace, '$deckId/${board.value}');
  }

  $FoldersTable get _folders => _db.folders;
  $CollectionEntriesTable get _entries => _db.collectionEntries;

  Expression<int> get _folderDirtyIncrement =>
      _folders.dirtyRevision + const Constant(1);
  Expression<int> get _entryDirtyIncrement =>
      _entries.dirtyRevision + const Constant(1);

  // ===========================================================================
  // Folders: reading
  // ===========================================================================

  /// A folder that is not deleted, or null.
  Future<Folder?> getFolder(String id) {
    return (_db.select(_folders)
          ..where((f) => f.id.equals(id) & f.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  /// The boxes and decks directly inside [parentId] (null = root), by name.
  /// Board folders are never included.
  Stream<List<Folder>> watchChildFolders(String? parentId) {
    return (_db.select(_folders)
          ..where(
            (f) =>
                _parentIs(f, parentId) &
                f.isDeleted.equals(false) &
                f.folderType.isInValues([FolderType.box, FolderType.deck]),
          )
          ..orderBy([
            (f) => OrderingTerm(expression: f.name.collate(Collate.noCase)),
          ]))
        .watch();
  }

  /// The folders from the top level down to [folderId] (for breadcrumbs).
  /// Empty for the root.
  Future<List<Folder>> getFolderPath(String? folderId) async {
    final path = <Folder>[];
    var currentId = folderId;
    while (currentId != null) {
      final folder = await getFolder(currentId);
      if (folder == null) break;
      path.insert(0, folder);
      currentId = folder.parentId;
    }
    return path;
  }

  // ===========================================================================
  // Folders: changing
  // ===========================================================================

  /// Creates a box or a deck inside [parentId] (null = root).
  Future<Folder> createFolder({
    required String name,
    String? parentId,
    FolderType type = FolderType.box,
    String? color,
    bool isPrivate = false,
    String? format,
    int? bracket,
    String? description,
  }) async {
    if (type != FolderType.box && type != FolderType.deck) {
      throw const CollectionException('Only boxes and decks can be created.');
    }
    final trimmedName = _requireName(name);

    return _db.transaction(() async {
      await _requireBoxOrRoot(parentId);
      return _db
          .into(_folders)
          .insertReturning(
            FoldersCompanion.insert(
              id: _uuid.v4(),
              name: Value(trimmedName),
              parentId: Value(parentId),
              folderType: type,
              color: Value(color),
              isPrivate: Value(isPrivate),
              format: Value(format),
              bracket: Value(bracket),
              description: Value(description),
              addedAt: _now(),
              dirtyRevision: const Value(1),
            ),
          );
    });
  }

  /// Changes the given properties of a box or deck. Absent values stay.
  Future<void> updateFolder(
    String id, {
    String? name,
    Value<String?> color = const Value.absent(),
    bool? isPrivate,
    Value<String?> format = const Value.absent(),
    Value<int?> bracket = const Value.absent(),
    Value<String?> description = const Value.absent(),
  }) async {
    await _db.transaction(() async {
      await _requireEditableFolder(id);
      await (_db.update(_folders)..where((f) => f.id.equals(id))).write(
        FoldersCompanion.custom(
          name: name == null ? null : Variable<String>(_requireName(name)),
          color: color.present ? Variable<String>(color.value) : null,
          isPrivate: isPrivate == null ? null : Variable<bool>(isPrivate),
          format: format.present ? Variable<String>(format.value) : null,
          bracket: bracket.present ? Variable<int>(bracket.value) : null,
          description: description.present
              ? Variable<String>(description.value)
              : null,
          dirtyRevision: _folderDirtyIncrement,
        ),
      );
    });
  }

  /// Moves a box or deck into [newParentId] (null = root).
  Future<void> moveFolder(String id, String? newParentId) async {
    await _db.transaction(() async {
      await _requireEditableFolder(id);
      await _requireBoxOrRoot(newParentId);

      // A folder must not end up inside itself.
      var ancestorId = newParentId;
      while (ancestorId != null) {
        if (ancestorId == id) {
          throw const CollectionException(
            'A folder cannot be moved into itself.',
          );
        }
        ancestorId = (await getFolder(ancestorId))?.parentId;
      }

      await (_db.update(_folders)..where((f) => f.id.equals(id))).write(
        FoldersCompanion.custom(
          parentId: Variable<String>(newParentId),
          dirtyRevision: _folderDirtyIncrement,
        ),
      );
    });
  }

  /// Deletes a box or deck.
  ///
  /// The boards of a deck are always deleted with it. [keepContents] decides
  /// what happens to everything inside:
  /// - true: cards (and for boxes also subfolders) move one level up, into
  ///   the parent of the deleted folder. Placeholders are deleted anyway,
  ///   because they can only exist inside decks.
  /// - false: everything inside is deleted as well.
  Future<void> deleteFolder(String id, {required bool keepContents}) async {
    await _db.transaction(() async {
      final folder = await _requireEditableFolder(id);
      final targetId = folder.parentId;

      if (folder.folderType == FolderType.deck) {
        final boardIds = await _childFolderIds(id);
        if (keepContents) {
          await _writeEntries(
            (e) => e.folderId.isIn(boardIds) & e.isOwned.equals(true),
            CollectionEntriesCompanion.custom(
              folderId: Variable<String>(targetId),
            ),
          );
        }
        await _deleteEntriesWhere((e) => e.folderId.isIn(boardIds));
        await _deleteFolders([...boardIds, id]);
        return;
      }

      if (keepContents) {
        await (_db.update(_folders)
              ..where((f) => f.parentId.equals(id) & f.isDeleted.equals(false)))
            .write(
              FoldersCompanion.custom(
                parentId: Variable<String>(targetId),
                dirtyRevision: _folderDirtyIncrement,
              ),
            );
        await _writeEntries(
          (e) => e.folderId.equals(id),
          CollectionEntriesCompanion.custom(
            folderId: Variable<String>(targetId),
          ),
        );
        await _deleteFolders([id]);
      } else {
        final subtree = await _subtreeFolderIds(id);
        await _deleteEntriesWhere((e) => e.folderId.isIn(subtree));
        await _deleteFolders(subtree);
      }
    });
  }

  // ===========================================================================
  // Cards: reading
  // ===========================================================================

  /// Identical cards in [folderId] (null = root), grouped with their count,
  /// newest first.
  ///
  /// - A deck always includes all its boards, grouped per board.
  /// - [includeSubfolders] also includes everything below the folder. For the
  ///   root this is the whole collection.
  /// - [ownedOnly] hides placeholders (the collection never shows them).
  Stream<List<CardGroup>> watchCardGroups(
    String? folderId, {
    bool includeSubfolders = false,
    bool ownedOnly = true,
  }) async* {
    Folder? folder;
    if (folderId != null) {
      folder = await getFolder(folderId);
      if (folder == null) {
        yield const [];
        return;
      }
    }
    final groupByBoard = folder?.folderType == FolderType.deck;

    final variables = <Variable>[];
    final String scopeFilter;
    if (folderId == null) {
      scopeFilter = includeSubfolders ? '1' : 'e.folder_id IS NULL';
    } else {
      // The folder itself, its boards and (optionally) all subfolders.
      scopeFilter =
          '''e.folder_id IN (
        WITH RECURSIVE scope(id) AS (
          SELECT ?1
          UNION ALL
          SELECT f.id FROM folders f JOIN scope s ON f.parent_id = s.id
          WHERE f.is_deleted = 0 AND (?2 OR f.folder_type >= ${FolderType.commander.value})
        )
        SELECT id FROM scope
      )''';
      variables
        ..add(Variable.withString(folderId))
        ..add(Variable.withBool(includeSubfolders));
    }

    final boardColumn = groupByBoard
        ? 'b.folder_type AS board_type'
        : 'NULL AS board_type';
    final boardJoin = groupByBoard
        ? 'LEFT JOIN folders b ON b.id = e.folder_id'
        : '';
    final boardGroup = groupByBoard ? ', e.folder_id' : '';

    final query = _db.customSelect(
      '''
      SELECT e.scryfall_id, e.finish, e.quality, e.is_proxy, e.is_altered,
             e.is_signed, e.is_owned, $boardColumn,
             COUNT(*) AS card_count, MAX(e.added_at) AS last_added_at
      FROM collection_entries e
      $boardJoin
      WHERE e.is_deleted = 0
        ${ownedOnly ? 'AND e.is_owned = 1' : ''}
        AND $scopeFilter
      GROUP BY e.scryfall_id, e.finish, e.quality, e.is_proxy, e.is_altered,
               e.is_signed, e.is_owned$boardGroup
      ORDER BY last_added_at DESC, e.scryfall_id
      ''',
      variables: variables,
      readsFrom: {_folders, _entries},
    );

    yield* query.watch().map(
      (rows) => [
        for (final row in rows)
          CardGroup(
            scryfallId: row.read<String>('scryfall_id'),
            finish: CardFinish.fromValue(row.read<int>('finish')),
            quality: CardQuality.fromValue(row.read<int>('quality')),
            isProxy: row.read<bool>('is_proxy'),
            isAltered: row.read<bool>('is_altered'),
            isSigned: row.read<bool>('is_signed'),
            isOwned: row.read<bool>('is_owned'),
            count: row.read<int>('card_count'),
            lastAddedAt: row.read<int>('last_added_at'),
            board: row.readNullable<int>('board_type') == null
                ? null
                : FolderType.fromValue(row.read<int>('board_type')),
          ),
      ],
    );
  }

  /// All copies of one printing, wherever they are (for "Your copies").
  Stream<List<CollectionEntry>> watchEntriesForCard(String scryfallId) {
    return (_db.select(_entries)
          ..where(
            (e) => e.scryfallId.equals(scryfallId) & e.isDeleted.equals(false),
          )
          ..orderBy([(e) => OrderingTerm.desc(e.addedAt)]))
        .watch();
  }

  // ===========================================================================
  // Cards: changing
  // ===========================================================================

  /// Adds [amount] copies of a card and returns their IDs.
  ///
  /// [folderId] null = root. If it is a deck, the card goes into [board]
  /// (default: main). Placeholders ([isOwned] false) are only allowed in decks.
  Future<List<String>> addCards({
    required String scryfallId,
    int amount = 1,
    String? folderId,
    FolderType? board,
    CardFinish finish = CardFinish.nonfoil,
    CardQuality quality = CardQuality.unknown,
    bool isProxy = false,
    bool isAltered = false,
    bool isSigned = false,
    bool isOwned = true,
  }) async {
    if (amount < 1) {
      throw const CollectionException('Amount must be at least 1.');
    }

    return _db.transaction(() async {
      final target = await _resolveTarget(folderId, board);
      if (!isOwned && !target.isBoard) {
        throw const CollectionException(
          'Placeholders can only be added to decks.',
        );
      }

      final addedAt = _now();
      final ids = [for (var i = 0; i < amount; i++) _uuid.v4()];
      await _db.batch((batch) {
        batch.insertAll(_entries, [
          for (final id in ids)
            CollectionEntriesCompanion.insert(
              id: id,
              scryfallId: scryfallId,
              folderId: Value(target.folderId),
              isProxy: Value(isProxy),
              isAltered: Value(isAltered),
              isSigned: Value(isSigned),
              isOwned: Value(isOwned),
              quality: quality,
              finish: finish,
              addedAt: addedAt,
              dirtyRevision: const Value(1),
            ),
        ]);
      });
      return ids;
    });
  }

  /// Moves cards into [targetFolderId] (null = root; for a deck into [board],
  /// default main). Placeholders are skipped unless the target is a deck.
  Future<MoveResult> moveEntries(
    Iterable<String> ids,
    String? targetFolderId, {
    FolderType? board,
  }) async {
    final idList = ids.toList();
    return _db.transaction(() async {
      final target = await _resolveTarget(targetFolderId, board);

      final candidates = _activeEntries(idList);
      final total = await _count(candidates);
      final moved = await _writeEntries(
        (e) =>
            candidates(e) &
            (target.isBoard ? const Constant(true) : e.isOwned.equals(true)),
        CollectionEntriesCompanion.custom(
          folderId: Variable<String>(target.folderId),
        ),
      );
      return MoveResult(moved: moved, skippedPlaceholders: total - moved);
    });
  }

  /// Changes the given properties of cards. Null values stay unchanged.
  Future<void> updateEntries(
    Iterable<String> ids, {
    CardFinish? finish,
    CardQuality? quality,
    bool? isProxy,
    bool? isAltered,
    bool? isSigned,
  }) async {
    await _writeEntries(
      _activeEntries(ids.toList()),
      CollectionEntriesCompanion.custom(
        finish: finish == null ? null : Variable<int>(finish.value),
        quality: quality == null ? null : Variable<int>(quality.value),
        isProxy: isProxy == null ? null : Variable<bool>(isProxy),
        isAltered: isAltered == null ? null : Variable<bool>(isAltered),
        isSigned: isSigned == null ? null : Variable<bool>(isSigned),
      ),
    );
  }

  /// Turns cards into placeholders or back into owned cards.
  /// Only cards inside decks can become placeholders; others are skipped.
  /// Returns how many cards were changed.
  Future<int> setOwned(Iterable<String> ids, {required bool isOwned}) {
    final candidates = _activeEntries(ids.toList());
    if (isOwned) {
      return _writeEntries(
        candidates,
        CollectionEntriesCompanion.custom(isOwned: const Variable(true)),
      );
    }
    final boardIds = _db.selectOnly(_folders)
      ..addColumns([_folders.id])
      ..where(
        _folders.folderType.isBiggerOrEqualValue(FolderType.commander.value),
      );
    return _writeEntries(
      (e) => candidates(e) & e.folderId.isInQuery(boardIds),
      CollectionEntriesCompanion.custom(isOwned: const Variable(false)),
    );
  }

  /// Marks cards as deleted.
  Future<void> deleteEntries(Iterable<String> ids) {
    return _deleteEntriesWhere(_activeEntries(ids.toList()));
  }

  // ===========================================================================
  // Helpers
  // ===========================================================================

  Expression<bool> _parentIs($FoldersTable f, String? parentId) =>
      parentId == null ? f.parentId.isNull() : f.parentId.equals(parentId);

  Expression<bool> Function($CollectionEntriesTable e) _activeEntries(
    List<String> ids,
  ) {
    return (e) => e.id.isIn(ids) & e.isDeleted.equals(false);
  }

  String _requireName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const CollectionException('Folder name must not be empty.');
    }
    return trimmed;
  }

  /// Cards and folders can be put into the root or a box.
  Future<void> _requireBoxOrRoot(String? folderId) async {
    if (folderId == null) return;
    final folder = await getFolder(folderId);
    if (folder == null) {
      throw CollectionException('Folder $folderId does not exist.');
    }
    if (folder.folderType != FolderType.box) {
      throw const CollectionException('Folders can only be put into boxes.');
    }
  }

  /// Boxes and decks can be edited, boards cannot.
  Future<Folder> _requireEditableFolder(String id) async {
    final folder = await getFolder(id);
    if (folder == null) {
      throw CollectionException('Folder $id does not exist.');
    }
    if (folder.folderType.isBoard) {
      throw const CollectionException('Boards cannot be changed directly.');
    }
    return folder;
  }

  /// Where cards end up when they are added to or moved into [folderId].
  Future<({String? folderId, bool isBoard})> _resolveTarget(
    String? folderId,
    FolderType? board,
  ) async {
    if (board != null && !board.isBoard) {
      throw CollectionException('${board.name} is not a board.');
    }
    if (folderId == null) {
      if (board != null) {
        throw const CollectionException('The root has no boards.');
      }
      return (folderId: null, isBoard: false);
    }

    final folder = await getFolder(folderId);
    if (folder == null) {
      throw CollectionException('Folder $folderId does not exist.');
    }
    switch (folder.folderType) {
      case FolderType.box:
        if (board != null) {
          throw const CollectionException('Boxes have no boards.');
        }
        return (folderId: folderId, isBoard: false);
      case FolderType.deck:
        final boardId = await _ensureBoard(folder.id, board ?? FolderType.main);
        return (folderId: boardId, isBoard: true);
      default:
        // Already a board folder.
        if (board != null && board != folder.folderType) {
          throw const CollectionException('Board does not match the folder.');
        }
        return (folderId: folderId, isBoard: true);
    }
  }

  /// Creates the board folder if it does not exist yet. Boards are never
  /// deleted on their own, only together with their deck.
  Future<String> _ensureBoard(String deckId, FolderType board) async {
    final id = boardFolderId(deckId, board);
    await _db
        .into(_folders)
        .insert(
          FoldersCompanion.insert(
            id: id,
            parentId: Value(deckId),
            folderType: board,
            addedAt: _now(),
            dirtyRevision: const Value(1),
          ),
          mode: InsertMode.insertOrIgnore,
        );
    return id;
  }

  Future<List<String>> _childFolderIds(String parentId) async {
    final query = _db.selectOnly(_folders)
      ..addColumns([_folders.id])
      ..where(
        _folders.parentId.equals(parentId) & _folders.isDeleted.equals(false),
      );
    return query.map((row) => row.read(_folders.id)!).get();
  }

  /// [rootId] and all folders below it.
  Future<List<String>> _subtreeFolderIds(String rootId) async {
    final result = <String>[rootId];
    for (var i = 0; i < result.length; i++) {
      result.addAll(await _childFolderIds(result[i]));
    }
    return result;
  }

  Future<int> _count(
    Expression<bool> Function($CollectionEntriesTable e) where,
  ) async {
    final count = _entries.id.count();
    final query = _db.selectOnly(_entries)
      ..addColumns([count])
      ..where(where(_entries));
    return (await query.getSingle()).read(count)!;
  }

  /// Applies [changes] to all matching cards and marks them dirty.
  Future<int> _writeEntries(
    Expression<bool> Function($CollectionEntriesTable e) where,
    Insertable<CollectionEntry> changes,
  ) {
    final columns = Map.of(changes.toColumns(false))
      ..[_entries.dirtyRevision.name] = _entryDirtyIncrement;
    return (_db.update(
      _entries,
    )..where(where)).write(RawValuesInsertable<CollectionEntry>(columns));
  }

  Future<int> _deleteEntriesWhere(
    Expression<bool> Function($CollectionEntriesTable e) where,
  ) {
    return _writeEntries(
      (e) => where(e) & e.isDeleted.equals(false),
      CollectionEntriesCompanion.custom(isDeleted: const Variable(true)),
    );
  }

  Future<void> _deleteFolders(List<String> ids) {
    return (_db.update(
      _folders,
    )..where((f) => f.id.isIn(ids) & f.isDeleted.equals(false))).write(
      FoldersCompanion.custom(
        isDeleted: const Variable(true),
        dirtyRevision: _folderDirtyIncrement,
      ),
    );
  }
}
