import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:drift/drift.dart' show Value;
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../services/app_preferences_storage.dart';
import '../../services/card_database/database.dart';
import '../../services/collection/collection_enums.dart';
import '../../services/collection/collection_repository.dart';
import '../../services/collection/collection_search.dart';
import 'collection/collection_dialogs.dart';
import 'collection/collection_labels.dart';

/// Browses the collection like a file explorer: breadcrumbs, the boxes and
/// decks of the current folder, and the cards inside it.
///
/// A deck is shown as one list of all its owned cards (all boards together).
class CollectionPage extends StatefulWidget {
  const CollectionPage({this.folderId, this.initialPath, super.key});

  /// The opened folder, null = root.
  final String? folderId;

  /// The folders down to [folderId], if the caller already knows them. Shows
  /// the breadcrumbs right away instead of after loading.
  final List<Folder>? initialPath;

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

enum _SortBy { added, name, set, cmc }

enum _MenuAction { toggleView, toggleSubfolders, newBox }

class _CollectionPageState extends State<CollectionPage> {
  final _repository = CollectionRepository.shared;
  final _database = AppDatabase();
  final _preferences = AppPreferencesStorage();
  final _searchController = TextEditingController();

  /// Folders from the top level down to the open folder. Null while loading.
  List<Folder>? _path;

  late Stream<List<Folder>> _childFolders;
  late Stream<Map<String, int>> _folderCounts;
  Stream<List<CardGroup>>? _groups;

  bool _listView = false;
  bool _includeSubfolders = false;
  _SortBy _sortBy = _SortBy.added;
  bool _descending = true;
  String _query = '';
  Timer? _searchDebounce;

  /// Keys of the card groups matching [_query], null = no search active.
  Set<String>? _matches;

  /// The query and the card groups [_matches] were computed for.
  String? _searchedQuery;
  Set<String> _searchedKeys = const {};
  String? _searchError;

  /// Keys of the selected card groups. Not empty = selection mode.
  final _selected = <String>{};
  List<CardGroup> _currentGroups = const [];

  /// Scryfall data for the shown cards, loaded lazily.
  /// Shared by all collection pages, so opening a folder doesn't reload
  /// cards that were already shown.
  static final _cards = <String, ScryfallCard>{};
  static final _faceImages = <String, String>{};
  static final _requestedCards = <String>{};

  /// Cards that are not in the local Scryfall data (yet).
  static final _missingCards = <String>{};

  Folder? get _folder => (_path?.isEmpty ?? true) ? null : _path!.last;
  bool get _isDeck => _folder?.folderType == FolderType.deck;
  bool get _folderMissing =>
      widget.folderId != null && _path != null && _path!.isEmpty;
  bool get _selecting => _selected.isNotEmpty;

  @override
  void initState() {
    super.initState();
    // The Scryfall data may have been updated since, so look again.
    _requestedCards.removeAll(_missingCards);
    _missingCards.clear();
    _path = widget.initialPath;
    _childFolders = _repository.watchChildFolders(widget.folderId);
    _folderCounts = _repository.watchFolderCardCounts(widget.folderId);
    _subscribeGroups();
    _loadPath();
    _preferences.loadCollectionListView().then((listView) {
      if (mounted) setState(() => _listView = listView);
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPath() async {
    final path = await _repository.getFolderPath(widget.folderId);
    if (mounted) setState(() => _path = path);
  }

  void _subscribeGroups() {
    _groups = _repository.watchCardGroups(
      widget.folderId,
      includeSubfolders: _includeSubfolders,
    );
  }

  /// Loads the Scryfall data for cards that are not loaded yet.
  Future<void> _loadCards(List<CardGroup> groups) async {
    final missing = groups
        .map((group) => group.scryfallId)
        .where(_requestedCards.add)
        .toList();
    if (missing.isEmpty) return;

    final cards = await _database.getCardsByIds(missing);
    final withoutImage = cards.values
        .where((card) => card.imageNormal == null && card.hasCardFaces)
        .map((card) => card.scryfallId)
        .toList();
    final faceImages = await _database.getFrontFaceImages(withoutImage);
    if (!mounted) return;
    setState(() {
      _cards.addAll(cards);
      _faceImages.addAll(faceImages);
      _missingCards.addAll(missing.where((id) => !cards.containsKey(id)));
    });
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), _runSearch);
  }

  /// Filters the shown cards with the syntax in [_query] (Scryfall syntax
  /// plus own: and cond:, see [CollectionSearch]).
  Future<void> _runSearch() async {
    final query = _query.trim();
    final groups = _currentGroups;
    _searchedQuery = query;
    _searchedKeys = groups.map((group) => group.key).toSet();
    if (query.isEmpty) {
      setState(() {
        _matches = null;
        _searchError = null;
      });
      return;
    }

    Set<String> matches;
    String? error;
    try {
      matches = await CollectionSearch(_database).filter(query, groups);
    } catch (e) {
      matches = const {};
      error = e is FormatException ? e.message : '$e';
    }
    // Ignore results of searches that were overtaken by a newer one.
    if (!mounted || _searchedQuery != query) return;
    setState(() {
      _matches = matches;
      _searchError = error;
    });
  }

  /// Searches again if the shown cards changed while a search is active.
  void _refreshSearchFor(List<CardGroup> groups) {
    if (_query.trim().isEmpty) return;
    final keys = groups.map((group) => group.key).toSet();
    final unchanged =
        keys.length == _searchedKeys.length && keys.containsAll(_searchedKeys);
    if (!unchanged) _runSearch();
  }

  String? _imageUrl(String scryfallId) =>
      _cards[scryfallId]?.imageNormal ?? _faceImages[scryfallId];

  List<CardGroup> _visibleGroups(List<CardGroup> groups) {
    final matches = _matches;
    final visible = matches == null
        ? [...groups]
        : groups.where((group) => matches.contains(group.key)).toList();

    int compare(CardGroup a, CardGroup b) {
      final cardA = _cards[a.scryfallId];
      final cardB = _cards[b.scryfallId];
      final result = switch (_sortBy) {
        _SortBy.added => a.lastAddedAt.compareTo(b.lastAddedAt),
        _SortBy.name => (cardA?.name ?? '').compareTo(cardB?.name ?? ''),
        _SortBy.set => (cardA?.releasedAt ?? '').compareTo(
          cardB?.releasedAt ?? '',
        ),
        _SortBy.cmc => (cardA?.cmc ?? 0).compareTo(cardB?.cmc ?? 0),
      };
      return _descending ? -result : result;
    }

    visible.sort((a, b) {
      // In a deck, keep the boards together (commander first).
      final board = (a.board?.value ?? 0).compareTo(b.board?.value ?? 0);
      if (board != 0) return board;
      final result = compare(a, b);
      return result != 0
          ? result
          : (_cards[a.scryfallId]?.name ?? '').compareTo(
              _cards[b.scryfallId]?.name ?? '',
            );
    });
    return visible;
  }

  // ===========================================================================
  // Actions
  // ===========================================================================

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

  void _openFolder(Folder folder) {
    context.push('/collection?folder=${folder.id}', extra: [...?_path, folder]);
  }

  /// Jumps to a folder of the current path (null = root).
  void _goToFolder(String? folderId) {
    final path = _path ?? const <Folder>[];
    final index = path.indexWhere((folder) => folder.id == folderId);
    context.go(
      folderId == null ? '/collection' : '/collection?folder=$folderId',
      extra: path.sublist(0, index + 1),
    );
  }

  Future<void> _createFolder(FolderType type) async {
    final result = await showFolderForm(context, type: type);
    if (result == null) return;
    await _run(() async {
      await _repository.createFolder(
        name: result.name,
        parentId: widget.folderId,
        type: type,
        color: result.color,
        isPrivate: result.isPrivate,
        format: result.format,
        bracket: result.bracket,
        description: result.description,
      );
    });
  }

  Future<void> _editFolder(Folder folder) async {
    final result = await showFolderForm(
      context,
      type: folder.folderType,
      existing: folder,
    );
    if (result == null) return;
    await _run(
      () => _repository.updateFolder(
        folder.id,
        name: result.name,
        color: Value(result.color),
        isPrivate: result.isPrivate,
        format: Value(result.format),
        bracket: Value(result.bracket),
        description: Value(result.description),
      ),
    );
  }

  Future<void> _moveFolder(Folder folder) async {
    final target = await showFolderPicker(context, movingFolder: folder);
    if (target == null || target.folderId == folder.parentId) return;
    await _run(() async {
      await _repository.moveFolder(folder.id, target.folderId);
      if (!mounted) return;
      showCollectionSnackBar(
        context,
        tr('collection.folder_moved', {
          'name': folder.name,
          'target': target.folderId == null ? rootFolderLabel : target.label,
        }),
      );
    });
  }

  Future<void> _deleteFolder(Folder folder, int cardCount) async {
    final keepContents = await showDeleteFolderDialog(
      context,
      folder: folder,
      cardCount: cardCount,
      parentLabel: _folder?.name ?? rootFolderLabel,
    );
    if (keepContents == null) return;
    await _run(
      () => _repository.deleteFolder(folder.id, keepContents: keepContents),
    );
  }

  List<CardGroup> get _selectedGroups =>
      _currentGroups.where((group) => _selected.contains(group.key)).toList();

  List<String> get _selectedEntryIds => [
    for (final group in _selectedGroups) ...group.entryIds,
  ];

  void _toggleSelection(CardGroup group) {
    setState(() {
      if (!_selected.remove(group.key)) _selected.add(group.key);
    });
  }

  void _clearSelection() => setState(_selected.clear);

  Future<void> _moveSelected() async {
    final ids = _selectedEntryIds;
    final target = await showFolderPicker(context);
    if (target == null) return;
    await _run(() async {
      final result = await _repository.moveEntries(
        ids,
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
      _clearSelection();
    });
  }

  Future<void> _editSelected() async {
    final groups = _selectedGroups;
    final ids = _selectedEntryIds;
    final changes = await showEditEntriesDialog(context, [
      for (final group in groups)
        EntryProperties(
          finish: group.finish,
          quality: group.quality,
          isProxy: group.isProxy,
          isAltered: group.isAltered,
          isSigned: group.isSigned,
        ),
    ]);
    if (changes == null) return;
    await _run(() async {
      await _repository.updateEntries(
        ids,
        finish: changes.finish,
        quality: changes.quality,
        isProxy: changes.isProxy,
        isAltered: changes.isAltered,
        isSigned: changes.isSigned,
      );
      _clearSelection();
    });
  }

  Future<void> _deleteSelected() async {
    final ids = _selectedEntryIds;
    if (!await showDeleteCardsDialog(context, ids.length)) return;
    await _run(() async {
      await _repository.deleteEntries(ids);
      if (!mounted) return;
      showCollectionSnackBar(
        context,
        tr('collection.deleted', {'count': ids.length}),
      );
      _clearSelection();
    });
  }

  void _toggleListView() {
    setState(() => _listView = !_listView);
    _preferences.saveCollectionListView(_listView);
  }

  // ===========================================================================
  // Build
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_selecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _clearSelection();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 0),
                child: _selecting ? _buildSelectionBar() : _buildSearchBar(),
              ),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: tr('collection.search_hint'),
              prefixIcon: Icon(
                Icons.search,
                size: 20,
                color: colorScheme.primary,
              ),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: Icon(
                        Icons.clear,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        _onQueryChanged('');
                      },
                    ),
            ),
            onChanged: _onQueryChanged,
          ),
        ),
        const SizedBox(width: 8),
        _SortMenuButton(
          sortBy: _sortBy,
          descending: _descending,
          onSortBy: (value) => setState(() => _sortBy = value),
          onDescending: (value) => setState(() => _descending = value),
        ),
        const SizedBox(width: 8),
        _buildMoreMenu(),
      ],
    );
  }

  Widget _buildMoreMenu() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 52,
      width: 52,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline),
      ),
      child: PopupMenuButton<_MenuAction>(
        tooltip: tr('collection.more'),
        icon: Icon(Icons.more_vert, size: 20, color: colorScheme.primary),
        onSelected: (action) => switch (action) {
          _MenuAction.toggleView => _toggleListView(),
          _MenuAction.toggleSubfolders => setState(() {
            _includeSubfolders = !_includeSubfolders;
            _subscribeGroups();
          }),
          _MenuAction.newBox => _createFolder(FolderType.box),
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: _MenuAction.toggleView,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(_listView ? Icons.grid_view : Icons.view_list),
              title: Text(
                tr(_listView ? 'collection.view_grid' : 'collection.view_list'),
              ),
            ),
          ),
          if (!_isDeck)
            CheckedPopupMenuItem(
              value: _MenuAction.toggleSubfolders,
              checked: _includeSubfolders,
              child: Text(tr('collection.include_subfolders')),
            ),
          if (!_isDeck && !_folderMissing) ...[
            const PopupMenuDivider(),
            PopupMenuItem(
              value: _MenuAction.newBox,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.create_new_folder_outlined),
                title: Text(tr('collection.new_box')),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectionBar() {
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          IconButton(
            tooltip: tr('cancel'),
            icon: const Icon(Icons.close),
            onPressed: _clearSelection,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              tr('collection.selected', {'count': _selectedEntryIds.length}),
              style: Theme.of(context).textTheme.titleLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _SquareButton(
            icon: Icons.drive_file_move_outlined,
            tooltip: tr('collection.move'),
            onPressed: _moveSelected,
          ),
          const SizedBox(width: 8),
          _SquareButton(
            icon: Icons.edit_outlined,
            tooltip: tr('collection.edit_cards'),
            onPressed: _editSelected,
          ),
          const SizedBox(width: 8),
          _SquareButton(
            icon: Icons.delete_outline,
            tooltip: tr('collection.delete_cards'),
            onPressed: _deleteSelected,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_folderMissing) {
      return Center(
        child: TextButton(
          onPressed: () => _goToFolder(null),
          child: Text(rootFolderLabel),
        ),
      );
    }

    return StreamBuilder<List<Folder>>(
      stream: _childFolders,
      builder: (context, folderSnapshot) {
        final folders = _isDeck
            ? const <Folder>[]
            : folderSnapshot.data ?? const <Folder>[];
        return StreamBuilder<List<CardGroup>>(
          stream: _groups,
          builder: (context, groupSnapshot) {
            final groups = groupSnapshot.data;
            // Show nothing until everything is there, so the page doesn't
            // jump around while loading.
            if (groups == null ||
                _path == null ||
                (!_isDeck && !folderSnapshot.hasData)) {
              return const SizedBox.shrink();
            }
            _currentGroups = groups;
            _selected.removeWhere(
              (key) => !groups.any((group) => group.key == key),
            );
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadCards(groups);
              _refreshSearchFor(groups);
            });
            final visible = _visibleGroups(groups);
            final cardCount = visible.fold<int>(0, (sum, g) => sum + g.count);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildBreadcrumbs()),
                if (folders.isNotEmpty && !_selecting)
                  _buildFolderGrid(folders),
                if (_isDeck)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: Text(
                        tr('collection.deck_hint'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                if (groups.isEmpty && folders.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                      child: Text(
                        '${tr('collection.cards')}: $cardCount',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (_searchError != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                        child: Text(
                          '${tr('search.search_error')}$_searchError',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  _listView ? _buildCardList(visible) : _buildCardGrid(visible),
                ],
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBreadcrumbs() {
    final colorScheme = Theme.of(context).colorScheme;
    final path = _path ?? const <Folder>[];
    final crumbs = <(String?, String)>[
      (null, rootFolderLabel),
      for (final folder in path) (folder.id, folder.name),
    ];
    final mutedColor = colorScheme.onSurface.withValues(alpha: 0.6);

    // All crumbs look the same, only the current folder is highlighted.
    ButtonStyle crumbStyle(Color color) => TextButton.styleFrom(
      foregroundColor: color,
      disabledForegroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (var i = 0; i < crumbs.length; i++) ...[
            if (i > 0) Icon(Icons.chevron_right, size: 16, color: mutedColor),
            TextButton(
              style: crumbStyle(
                i == crumbs.length - 1 ? colorScheme.primary : mutedColor,
              ),
              onPressed: i == crumbs.length - 1
                  ? null
                  : () => _goToFolder(crumbs[i].$1),
              child: Text(crumbs[i].$2),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFolderGrid(List<Folder> folders) {
    return StreamBuilder<Map<String, int>>(
      stream: _folderCounts,
      builder: (context, snapshot) {
        final counts = snapshot.data;
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 280,
              mainAxisExtent: 64,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final folder = folders[index];
              final count = counts == null ? null : counts[folder.id] ?? 0;
              return _FolderTile(
                folder: folder,
                cardCount: count,
                onOpen: () => _openFolder(folder),
                onEdit: () => _editFolder(folder),
                onMove: () => _moveFolder(folder),
                onDelete: () => _deleteFolder(folder, count ?? 0),
              );
            }, childCount: folders.length),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final textTheme = Theme.of(context).textTheme;
    final isRoot = widget.folderId == null && !_includeSubfolders;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.style_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            tr(isRoot ? 'collection.empty_title' : 'collection.empty_folder'),
            style: textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          if (isRoot) ...[
            const SizedBox(height: 6),
            Text(tr('collection.empty_body'), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.go('/search'),
              icon: const Icon(Icons.search),
              label: Text(tr('collection.open_search')),
            ),
          ],
        ],
      ),
    );
  }

  void _onCardTap(CardGroup group) {
    if (_selecting) {
      _toggleSelection(group);
    } else if (!_missingCards.contains(group.scryfallId)) {
      // Cards without Scryfall data can't be shown in detail.
      context.push('/collection/entries?ids=${group.entryIds.join(',')}');
    }
  }

  Widget _buildCardGrid(List<CardGroup> groups) {
    return SliverPadding(
      padding: const EdgeInsets.all(12),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.716, // 63:88mm
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final group = groups[index];
          return _CardGridTile(
            group: group,
            card: _cards[group.scryfallId],
            imageUrl: _imageUrl(group.scryfallId),
            missing: _missingCards.contains(group.scryfallId),
            selecting: _selecting,
            selected: _selected.contains(group.key),
            onTap: () => _onCardTap(group),
            onLongPress: () => _toggleSelection(group),
          );
        }, childCount: groups.length),
      ),
    );
  }

  Widget _buildCardList(List<CardGroup> groups) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
      sliver: SliverList.separated(
        itemCount: groups.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final group = groups[index];
          return _CardListTile(
            group: group,
            card: _cards[group.scryfallId],
            showBoard: _isDeck,
            missing: _missingCards.contains(group.scryfallId),
            selecting: _selecting,
            selected: _selected.contains(group.key),
            onTap: () => _onCardTap(group),
            onLongPress: () => _toggleSelection(group),
          );
        },
      ),
    );
  }
}

// =============================================================================
// Widgets
// =============================================================================

class _SquareButton extends StatelessWidget {
  const _SquareButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 52,
      width: 52,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: colorScheme.primary),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }
}

/// One button for both sort options: what to sort by and the direction.
class _SortMenuButton extends StatelessWidget {
  const _SortMenuButton({
    required this.sortBy,
    required this.descending,
    required this.onSortBy,
    required this.onDescending,
  });

  final _SortBy sortBy;
  final bool descending;
  final ValueChanged<_SortBy> onSortBy;
  final ValueChanged<bool> onDescending;

  String _label(_SortBy sortBy) => switch (sortBy) {
    _SortBy.added => tr('collection.sort_added'),
    _SortBy.name => tr('search.order.name'),
    _SortBy.set => tr('search.order.set'),
    _SortBy.cmc => tr('search.order.cmc'),
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 52,
      width: 52,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline),
      ),
      // Values are either a _SortBy or a bool (descending).
      child: PopupMenuButton<Object>(
        tooltip: tr('collection.sort'),
        icon: Icon(Icons.sort, size: 20, color: colorScheme.primary),
        onSelected: (value) {
          if (value is _SortBy) onSortBy(value);
          if (value is bool) onDescending(value);
        },
        itemBuilder: (context) => [
          for (final option in _SortBy.values)
            CheckedPopupMenuItem<Object>(
              value: option,
              checked: option == sortBy,
              child: Text(_label(option)),
            ),
          const PopupMenuDivider(),
          CheckedPopupMenuItem<Object>(
            value: false,
            checked: !descending,
            child: Text(tr('search.order.asc')),
          ),
          CheckedPopupMenuItem<Object>(
            value: true,
            checked: descending,
            child: Text(tr('search.order.desc')),
          ),
        ],
      ),
    );
  }
}

class _FolderTile extends StatelessWidget {
  const _FolderTile({
    required this.folder,
    required this.cardCount,
    required this.onOpen,
    required this.onEdit,
    required this.onMove,
    required this.onDelete,
  });

  final Folder folder;

  /// Null while loading.
  final int? cardCount;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onMove;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDeck = folder.folderType == FolderType.deck;
    final subtitle = [
      if (isDeck && folder.format != null) formatLabel(folder.format!),
      if (cardCount != null) '$cardCount ${tr('collection.cards')}',
    ].join(' · ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  folderIcon(folder.folderType, filled: true),
                  color: parseFolderColor(folder.color) ?? colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            folder.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (folder.isPrivate) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.lock_outline,
                            size: 14,
                            color: colorScheme.primary,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<VoidCallback>(
                tooltip: tr('collection.more'),
                icon: const Icon(Icons.more_vert),
                onSelected: (action) => action(),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: onEdit,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.edit_outlined),
                      title: Text(tr('collection.edit')),
                    ),
                  ),
                  PopupMenuItem(
                    value: onMove,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.drive_file_move_outlined),
                      title: Text(tr('collection.move')),
                    ),
                  ),
                  PopupMenuItem(
                    value: onDelete,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.delete_outline,
                        color: colorScheme.error,
                      ),
                      title: Text(
                        tr('collection.delete'),
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardGridTile extends StatelessWidget {
  const _CardGridTile({
    required this.group,
    required this.card,
    required this.imageUrl,
    required this.missing,
    required this.selecting,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  final CardGroup group;
  final ScryfallCard? card;
  final String? imageUrl;

  /// The card is not in the local Scryfall data.
  final bool missing;
  final bool selecting;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final placeholder = Container(
      color: colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(10),
      alignment: Alignment.center,
      child: missing
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.help_outline, color: colorScheme.primary, size: 32),
                const SizedBox(height: 8),
                Text(
                  tr('collection.missing_card'),
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tr('collection.missing_card_hint'),
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall,
                ),
              ],
            )
          : Text(
              card?.name ?? '',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall,
            ),
    );

    final isFoil = group.finish != CardFinish.nonfoil;
    final tile = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          imageUrl == null
              ? placeholder
              : CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => placeholder,
                  errorWidget: (context, url, error) => placeholder,
                ),
          if (isFoil)
            const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: _foilGradient),
              ),
            ),
          Positioned(
            left: 6,
            bottom: 6,
            child: _CountBadge(count: group.count),
          ),
          if (selecting)
            Positioned(
              top: 6,
              right: 6,
              child: Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: selected ? colorScheme.primary : Colors.white,
                shadows: const [Shadow(blurRadius: 4)],
              ),
            ),
          if (selected)
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.primary, width: 3),
              ),
            ),
        ],
      ),
    );

    return GestureDetector(onTap: onTap, onLongPress: onLongPress, child: tile);
  }
}

/// Faint rainbow sheen over foil and etched cards.
const _foilGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0x47FF7A7A),
    Color(0x47FFC66B),
    Color(0x47F5F07A),
    Color(0x477FE0A0),
    Color(0x476EC8F5),
    Color(0x479C8BF5),
    Color(0x47F08BD8),
  ],
);

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.primary),
      ),
      child: Text(
        '$count×',
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _CardListTile extends StatelessWidget {
  const _CardListTile({
    required this.group,
    required this.card,
    required this.showBoard,
    required this.missing,
    required this.selecting,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  final CardGroup group;
  final ScryfallCard? card;
  final bool showBoard;

  /// The card is not in the local Scryfall data.
  final bool missing;
  final bool selecting;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final details = [
      if (card != null) card!.setCode.toUpperCase(),
      qualityShort(group.quality),
      if (group.finish != CardFinish.nonfoil) finishLabel(group.finish),
      if (group.isProxy) tr('collection.add.proxy'),
      if (group.isAltered) tr('collection.add.altered'),
      if (group.isSigned) tr('collection.add.signed'),
    ].join(' · ');
    final thumbnail = card?.imageSmall ?? card?.imageNormal;

    return ListTile(
      selected: selected,
      selectedTileColor: colorScheme.primary.withValues(alpha: 0.12),
      onTap: onTap,
      onLongPress: onLongPress,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selecting)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                selected ? Icons.check_box : Icons.check_box_outline_blank,
                color: colorScheme.primary,
              ),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              width: 32,
              height: 45,
              child: thumbnail == null
                  ? ColoredBox(
                      color: colorScheme.surfaceContainerHighest,
                      child: missing
                          ? Icon(
                              Icons.help_outline,
                              size: 18,
                              color: colorScheme.primary,
                            )
                          : null,
                    )
                  : CachedNetworkImage(imageUrl: thumbnail, fit: BoxFit.cover),
            ),
          ),
        ],
      ),
      title: Text(
        missing ? tr('collection.missing_card') : card?.name ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: missing
                  ? '${tr('collection.missing_card_hint')} · $details'
                  : details,
            ),
            if (showBoard && group.board != null)
              TextSpan(
                text: ' · ${boardLabel(group.board!)}',
                style: TextStyle(color: colorScheme.primary),
              ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        '${group.count}×',
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }
}
