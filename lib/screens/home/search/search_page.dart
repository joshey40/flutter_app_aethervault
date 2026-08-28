import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_aethervault/services/card_database/database.dart';
import '../../../services/localization_service.dart';
import 'package:go_router/go_router.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    this.initialQuery,
  });

  final String? initialQuery;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final AppDatabase _database = AppDatabase();
  final TextEditingController _controller = TextEditingController();

  Timer? _debounce;
  List<ScryfallCard> _results = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchScope = 'one_card';
  String _orderBy = 'name';
  String _orderDir = 'asc';

  /// Handle changes in the search input field with a debounce.
  void _onSearchChanged(String value) {
    _debounce?.cancel();

    final query = value.trim();
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _runSearch(query);
    });
  }

  /// Execute the search query against the database and update the UI with results or errors.
  Future<void> _runSearch(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _database.getCardsByScryfallSyntax(query, _searchScope, _orderBy, _orderDir);

      if (!mounted) return;
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '${appLocalizations.translate('search.search_error')}: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _controller.text = widget.initialQuery ?? '';

    if (_controller.text.isNotEmpty) {
      _onSearchChanged(_controller.text);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Widget _buildFilterDropdown<T>({
    required BuildContext context,
    required T initialValue,
    required List<T> values,
    required String Function(T) labelBuilder,
    required IconData icon,
    required ValueChanged<T> onSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: DropdownMenu<T>(
        initialSelection: initialValue,
        expandedInsets: EdgeInsets.zero,
        textStyle: textTheme.bodyMedium,
        leadingIcon: Icon(icon, size: 18, color: colorScheme.primary),
        trailingIcon: Icon(Icons.keyboard_arrow_down, size: 20, color: colorScheme.primary),
        selectedTrailingIcon: Icon(Icons.keyboard_arrow_up, size: 20, color: colorScheme.primary),
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          filled: true,
          fillColor: colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          prefixIconConstraints: const BoxConstraints(minWidth: 26, minHeight: 22),
          suffixIconConstraints: const BoxConstraints(minWidth: 26, minHeight: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.0),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.0),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.0),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(colorScheme.surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(2),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.0),
              side: BorderSide(color: colorScheme.outline),
            ),
          ),
        ),
        dropdownMenuEntries: values
            .map(
              (v) => DropdownMenuEntry<T>(
                value: v,
                label: labelBuilder(v),
                style: MenuItemButton.styleFrom(textStyle: textTheme.bodyMedium),
              ),
            )
            .toList(),
        onSelected: (value) {
          if (value != null) {
            onSelected(value);
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 2.0, top: 64.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: appLocalizations.translate('search.bar_hint'),
                    prefixIcon: Icon(Icons.search, size: 20, color: colorScheme.primary),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, size: 20, color: colorScheme.primary),
                            onPressed: () {
                              _controller.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                height: 52.0,
                width: 52.0,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: IconButton(
                  icon: Icon(Icons.info_outline, size: 20, color: colorScheme.primary),
                  tooltip: appLocalizations.translate('search.syntax_help'),
                  onPressed: () {
                    context.push('/search/syntax-help');
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 2.0, top: 10.0),
          child: Row(
            children: [
              _buildFilterDropdown<String>(
                context: context,
                initialValue: _searchScope,
                values: const ['one_card', 'all_prints'],
                labelBuilder: (v) => appLocalizations.translate('search.scope.$v'),
                icon: Icons.filter_alt_outlined,
                onSelected: (value) {
                  setState(() => _searchScope = value);
                  _onSearchChanged(_controller.text);
                },
              ),
              const SizedBox(width: 8.0),
              _buildFilterDropdown<String>(
                context: context,
                initialValue: _orderBy,
                values: const ['name', 'released_at', 'set', 'rarity', 'color', 'cmc', 'power', 'toughness'],
                labelBuilder: (v) => appLocalizations.translate('search.order.$v'),
                icon: Icons.sort_by_alpha,
                onSelected: (value) {
                  setState(() => _orderBy = value);
                  _onSearchChanged(_controller.text);
                },
              ),
              const SizedBox(width: 8.0),
              _buildFilterDropdown<String>(
                context: context,
                initialValue: _orderDir,
                values: const ['asc', 'desc'],
                labelBuilder: (v) => appLocalizations.translate('search.order.$v'),
                icon: Icons.swap_vert,
                onSelected: (value) {
                  setState(() => _orderDir = value);
                  _onSearchChanged(_controller.text);
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 10.0, right: 10.0, bottom: 2.0),
          child: Row(
            children: [
              Text(
                '${appLocalizations.translate('search.results')}: ${_results.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16.0),
              if (_isLoading)
                const SizedBox(
                  width: 16.0,
                  height: 16.0,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _errorMessage!,
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        Expanded(
          child: _results.isEmpty
              ? Center(
                  child: Text(
                    _controller.text.isEmpty
                        ? appLocalizations.translate('search.hint')
                        : (_isLoading ? '' : appLocalizations.translate('search.no_results')),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12.0),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200.0,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                    childAspectRatio: 0.716, // 63:88mm
                  ),
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final card = _results[index];
                    return _CardTile(card: card, database: _database);
                  },
                ),
        ),
      ],
    );
  }
}

class _CardTile extends StatefulWidget {
  const _CardTile({required this.card, required this.database});

  final ScryfallCard card;
  final AppDatabase database;

  @override
  State<_CardTile> createState() => _CardTileState();
}

class _CardTileState extends State<_CardTile> {
  List<ScryfallCardFace>? _faces;
  int _faceIndex = 0;
  bool _loadingFaces = false;

  @override
  void initState() {
    super.initState();
    if (widget.card.imageNormal == null && widget.card.hasCardFaces) {
      _loadFaces();
    }
  }

  /// Load card faces from the database if the main card image is not available.
  Future<void> _loadFaces() async {
    setState(() => _loadingFaces = true);
    final faces = await widget.database.getCardFacesByCardId(widget.card.scryfallId);
    if (!mounted) return;
    setState(() {
      _faces = faces;
      _loadingFaces = false;
    });
  }

  /// Get the list of image URLs for the card faces, filtering out any null values.
  List<String> get _faceImageUrls {
    if (_faces == null) return const [];
    return _faces!.map((f) => f.imageNormal).whereType<String>().toList();
  }

  /// Determine if the card can be flipped (i.e., has multiple distinct face images).
  bool get _canFlip => _faceImageUrls.length >= 2 && _faceImageUrls.toSet().length >= 2;

  /// Get the current image URL to display, either from the main card or the selected face.
  String? get _currentImageUrl {
    if (widget.card.imageNormal != null) return widget.card.imageNormal;
    final urls = _faceImageUrls;
    if (urls.isEmpty) return null;
    return urls[_faceIndex.clamp(0, urls.length - 1)];
  }

  /// Flip to the next card face.
  void _flip() {
    final urls = _faceImageUrls;
    if (urls.length < 2) return;
    setState(() => _faceIndex = (_faceIndex + 1) % urls.length);
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _currentImageUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () {
              // TODO: Navigate to card detail
            },
            child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.image_not_supported),
                    ),
                  )
                : Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: _loadingFaces
                        ? const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : const Icon(Icons.image_not_supported),
                  ),
          ),
          if (_canFlip)
            Positioned(
              right: 4,
              top: 32,
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: IconButton(
                  icon: const Icon(Icons.flip, color: Colors.white, size: 16),
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                  onPressed: _flip,
                  tooltip: appLocalizations.translate('search.flip_card'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}