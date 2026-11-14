import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_app_aethervault/services/card_database/database.dart';
import 'package:flutter_app_aethervault/services/collection/collection_enums.dart';
import 'package:flutter_app_aethervault/services/collection/collection_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late CollectionRepository repo;
  var clock = 1000;

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    clock = 1000;
    repo = CollectionRepository(db, now: () => clock++);
  });

  tearDown(() => db.close());

  Future<CollectionEntry> entry(String id) => (db.select(
    db.collectionEntries,
  )..where((e) => e.id.equals(id))).getSingle();

  Future<Folder> folderRow(String id) =>
      (db.select(db.folders)..where((f) => f.id.equals(id))).getSingle();

  group('folders', () {
    test('boxes and decks can be created in the root and in boxes', () async {
      final box = await repo.createFolder(name: ' Binder ');
      final deck = await repo.createFolder(
        name: 'Atraxa',
        parentId: box.id,
        type: FolderType.deck,
        format: 'commander',
      );

      expect(box.name, 'Binder');
      expect(box.parentId, isNull);
      expect(box.dirtyRevision, 1);
      expect(deck.parentId, box.id);
      expect(await repo.watchChildFolders(null).first, [box]);
      expect(await repo.watchChildFolders(box.id).first, [deck]);
      expect((await repo.getFolderPath(deck.id)).map((f) => f.id), [
        box.id,
        deck.id,
      ]);
    });

    test('folders cannot be put into decks or boards', () async {
      final deck = await repo.createFolder(name: 'D', type: FolderType.deck);
      expect(
        () => repo.createFolder(name: 'X', parentId: deck.id),
        throwsA(isA<CollectionException>()),
      );
      expect(
        () => repo.createFolder(name: 'X', type: FolderType.main),
        throwsA(isA<CollectionException>()),
      );
    });

    test('a folder cannot be moved into its own subfolder', () async {
      final a = await repo.createFolder(name: 'A');
      final b = await repo.createFolder(name: 'B', parentId: a.id);
      expect(
        () => repo.moveFolder(a.id, b.id),
        throwsA(isA<CollectionException>()),
      );
    });

    test('updates mark the folder dirty again', () async {
      final box = await repo.createFolder(name: 'Box');
      await repo.updateFolder(
        box.id,
        name: 'Rares',
        color: const Value('#fff'),
      );

      final row = await folderRow(box.id);
      expect(row.name, 'Rares');
      expect(row.color, '#fff');
      expect(row.dirtyRevision, 2);
    });
  });

  group('adding cards', () {
    test('adds one row per copy with the given properties', () async {
      final ids = await repo.addCards(
        scryfallId: 'island',
        amount: 3,
        finish: CardFinish.foil,
        quality: CardQuality.nearMint,
      );

      expect(ids.toSet(), hasLength(3));
      final row = await entry(ids.first);
      expect(row.folderId, isNull);
      expect(row.finish, CardFinish.foil);
      expect(row.quality, CardQuality.nearMint);
      expect(row.isOwned, isTrue);
      expect(row.dirtyRevision, 1);
    });

    test('cards added to a deck go into a board with a stable id', () async {
      final deck = await repo.createFolder(name: 'D', type: FolderType.deck);
      final mainIds = await repo.addCards(scryfallId: 'sol', folderId: deck.id);
      final cmdIds = await repo.addCards(
        scryfallId: 'atraxa',
        folderId: deck.id,
        board: FolderType.commander,
      );

      final mainBoardId = CollectionRepository.boardFolderId(
        deck.id,
        FolderType.main,
      );
      expect((await entry(mainIds.single)).folderId, mainBoardId);
      expect(
        (await entry(cmdIds.single)).folderId,
        CollectionRepository.boardFolderId(deck.id, FolderType.commander),
      );
      expect((await folderRow(mainBoardId)).folderType, FolderType.main);

      // Adding more cards reuses the board instead of creating another one.
      await repo.addCards(scryfallId: 'ring', folderId: deck.id);
      final boards = await (db.select(
        db.folders,
      )..where((f) => f.parentId.equals(deck.id))).get();
      expect(boards, hasLength(2));
      // Boards are not listed as normal subfolders.
      expect(await repo.watchChildFolders(deck.id).first, isEmpty);
    });

    test('board ids are the same on every device', () {
      expect(
        CollectionRepository.boardFolderId('deck-1', FolderType.main),
        CollectionRepository.boardFolderId('deck-1', FolderType.main),
      );
      expect(
        CollectionRepository.boardFolderId('deck-1', FolderType.main),
        isNot(
          CollectionRepository.boardFolderId('deck-1', FolderType.sideboard),
        ),
      );
    });

    test('placeholders are only allowed in decks', () async {
      final box = await repo.createFolder(name: 'Box');
      final deck = await repo.createFolder(name: 'D', type: FolderType.deck);

      expect(
        () => repo.addCards(scryfallId: 'x', isOwned: false),
        throwsA(isA<CollectionException>()),
      );
      expect(
        () => repo.addCards(scryfallId: 'x', folderId: box.id, isOwned: false),
        throwsA(isA<CollectionException>()),
      );
      await repo.addCards(scryfallId: 'x', folderId: deck.id, isOwned: false);
    });
  });

  group('card groups', () {
    test('identical copies are grouped with their count', () async {
      await repo.addCards(scryfallId: 'island', amount: 4);
      await repo.addCards(scryfallId: 'island', finish: CardFinish.foil);

      final groups = await repo.watchCardGroups(null).first;
      expect(groups, hasLength(2));
      final nonfoil = groups.firstWhere((g) => g.finish == CardFinish.nonfoil);
      expect(nonfoil.count, 4);
      expect(nonfoil.board, isNull);
    });

    test('subfolders are only included when asked for', () async {
      final box = await repo.createFolder(name: 'Box');
      final inner = await repo.createFolder(name: 'Inner', parentId: box.id);
      await repo.addCards(scryfallId: 'loose');
      await repo.addCards(scryfallId: 'outer', folderId: box.id);
      await repo.addCards(scryfallId: 'inner', folderId: inner.id);

      Future<Set<String>> ids(String? folderId, bool sub) async =>
          (await repo.watchCardGroups(folderId, includeSubfolders: sub).first)
              .map((g) => g.scryfallId)
              .toSet();

      expect(await ids(null, false), {'loose'});
      expect(await ids(null, true), {'loose', 'outer', 'inner'});
      expect(await ids(box.id, false), {'outer'});
      expect(await ids(box.id, true), {'outer', 'inner'});
    });

    test(
      'a deck shows all boards, grouped per board, without placeholders',
      () async {
        final deck = await repo.createFolder(name: 'D', type: FolderType.deck);
        await repo.addCards(scryfallId: 'sol', folderId: deck.id);
        await repo.addCards(
          scryfallId: 'sol',
          folderId: deck.id,
          board: FolderType.sideboard,
        );
        await repo.addCards(
          scryfallId: 'proxy',
          folderId: deck.id,
          isOwned: false,
        );

        final groups = await repo.watchCardGroups(deck.id).first;
        expect(groups.map((g) => g.board).toSet(), {
          FolderType.main,
          FolderType.sideboard,
        });
        expect(groups.every((g) => g.scryfallId == 'sol'), isTrue);

        final withPlaceholders = await repo
            .watchCardGroups(deck.id, ownedOnly: false)
            .first;
        expect(withPlaceholders, hasLength(3));
      },
    );

    test('the stream updates when cards change', () async {
      final stream = repo.watchCardGroups(null);
      final expectation = expectLater(
        stream.map((groups) => groups.length),
        emitsInOrder([0, 1]),
      );
      await Future<void>.delayed(Duration.zero);
      await repo.addCards(scryfallId: 'island');
      await expectation;
    });
  });

  group('changing cards', () {
    test('moving out of a deck skips placeholders', () async {
      final box = await repo.createFolder(name: 'Box');
      final deck = await repo.createFolder(name: 'D', type: FolderType.deck);
      final owned = await repo.addCards(scryfallId: 'a', folderId: deck.id);
      final placeholder = await repo.addCards(
        scryfallId: 'b',
        folderId: deck.id,
        isOwned: false,
      );

      final result = await repo.moveEntries([...owned, ...placeholder], box.id);

      expect(result.moved, 1);
      expect(result.skippedPlaceholders, 1);
      expect((await entry(owned.single)).folderId, box.id);
      expect((await entry(owned.single)).dirtyRevision, 2);
    });

    test('only cards in decks can become placeholders', () async {
      final deck = await repo.createFolder(name: 'D', type: FolderType.deck);
      final inDeck = await repo.addCards(scryfallId: 'a', folderId: deck.id);
      final loose = await repo.addCards(scryfallId: 'b');

      final changed = await repo.setOwned([
        ...inDeck,
        ...loose,
      ], isOwned: false);

      expect(changed, 1);
      expect((await entry(inDeck.single)).isOwned, isFalse);
      expect((await entry(loose.single)).isOwned, isTrue);
    });

    test('deleting only marks cards as deleted', () async {
      final ids = await repo.addCards(scryfallId: 'a', amount: 2);
      await repo.updateEntries([ids.first], quality: CardQuality.played);
      await repo.deleteEntries([ids.first]);

      final row = await entry(ids.first);
      expect(row.isDeleted, isTrue);
      expect(row.quality, CardQuality.played);
      expect(row.dirtyRevision, 3);
      expect((await repo.watchCardGroups(null).first).single.count, 1);
    });
  });

  group('deleting folders', () {
    test('a box with keepContents moves its content one level up', () async {
      final parent = await repo.createFolder(name: 'Parent');
      final box = await repo.createFolder(name: 'Box', parentId: parent.id);
      final child = await repo.createFolder(name: 'Child', parentId: box.id);
      final card = await repo.addCards(scryfallId: 'a', folderId: box.id);

      await repo.deleteFolder(box.id, keepContents: true);

      expect((await folderRow(box.id)).isDeleted, isTrue);
      expect((await folderRow(child.id)).parentId, parent.id);
      expect((await entry(card.single)).folderId, parent.id);
      expect((await entry(card.single)).isDeleted, isFalse);
    });

    test('a box without keepContents deletes everything inside', () async {
      final box = await repo.createFolder(name: 'Box');
      final child = await repo.createFolder(name: 'Child', parentId: box.id);
      final deck = await repo.createFolder(
        name: 'D',
        parentId: child.id,
        type: FolderType.deck,
      );
      final card = await repo.addCards(scryfallId: 'a', folderId: deck.id);

      await repo.deleteFolder(box.id, keepContents: false);

      expect((await folderRow(child.id)).isDeleted, isTrue);
      expect((await folderRow(deck.id)).isDeleted, isTrue);
      expect(
        (await folderRow(
          CollectionRepository.boardFolderId(deck.id, FolderType.main),
        )).isDeleted,
        isTrue,
      );
      expect((await entry(card.single)).isDeleted, isTrue);
    });

    test(
      'a deck with keepContents keeps owned cards and drops the rest',
      () async {
        final box = await repo.createFolder(name: 'Box');
        final deck = await repo.createFolder(
          name: 'D',
          parentId: box.id,
          type: FolderType.deck,
        );
        final owned = await repo.addCards(
          scryfallId: 'a',
          folderId: deck.id,
          board: FolderType.commander,
        );
        final placeholder = await repo.addCards(
          scryfallId: 'b',
          folderId: deck.id,
          isOwned: false,
        );

        await repo.deleteFolder(deck.id, keepContents: true);

        expect((await entry(owned.single)).folderId, box.id);
        expect((await entry(owned.single)).isDeleted, isFalse);
        expect((await entry(placeholder.single)).isDeleted, isTrue);
        final boards = await (db.select(
          db.folders,
        )..where((f) => f.parentId.equals(deck.id))).get();
        expect(boards.every((b) => b.isDeleted), isTrue);
      },
    );

    test('boards cannot be changed or deleted directly', () async {
      final deck = await repo.createFolder(name: 'D', type: FolderType.deck);
      await repo.addCards(scryfallId: 'a', folderId: deck.id);
      final boardId = CollectionRepository.boardFolderId(
        deck.id,
        FolderType.main,
      );

      expect(
        () => repo.deleteFolder(boardId, keepContents: true),
        throwsA(isA<CollectionException>()),
      );
      expect(
        () => repo.updateFolder(boardId, name: 'X'),
        throwsA(isA<CollectionException>()),
      );
    });
  });
}
