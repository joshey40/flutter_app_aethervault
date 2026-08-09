import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_aethervault/services/card_database/database.dart';
import '../../../services/localization_service.dart';
import 'scryfall_syntax_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

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
        _errorMessage = '${appLocalizations.translate('search_error')}: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 2.0, top: 64.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: appLocalizations.translate('search_bar_hint'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
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
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ScryfallSyntaxPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 2.0, top: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButton<String>(
                value: _searchScope,
                items: ['one_card', 'all_prints']
                    .map((value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(appLocalizations.translate(value)),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _searchScope = value;
                    });
                    _onSearchChanged(_controller.text);
                  }
                },
              ),
              DropdownButton<String>(
                value: _orderBy,
                items: ['name', 'released_at', 'set', 'rarity', 'color', 'cmc', 'power', 'toughness']
                    .map((value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(appLocalizations.translate(value)),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _orderBy = value;
                    });
                    _onSearchChanged(_controller.text);
                  }
                },
              ),
              DropdownButton<String>(
                value: _orderDir,
                items: ['asc', 'desc']
                    .map((value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(appLocalizations.translate(value)),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _orderDir = value;
                    });
                    _onSearchChanged(_controller.text);
                  }
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2.0, left: 16.0, right: 16.0, bottom: 2.0),
          child: Row(
            children: [
              Text(
                '${appLocalizations.translate('search_results')}: ${_results.length}',
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
          )
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        Expanded(
          child: _results.isEmpty
              ? Center(
                  child: Text(
                    _controller.text.isEmpty
                        ? appLocalizations.translate('search_hint')
                        : (_isLoading ? '' : appLocalizations.translate('no_results')),
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

  Future<void> _loadFaces() async {
    setState(() => _loadingFaces = true);
    final faces = await widget.database.getCardFacesByCardId(widget.card.scryfallId);
    if (!mounted) return;
    setState(() {
      _faces = faces;
      _loadingFaces = false;
    });
  }

  List<String> get _faceImageUrls {
    if (_faces == null) return const [];
    return _faces!.map((f) => f.imageNormal).whereType<String>().toList();
  }

  bool get _canFlip => _faceImageUrls.length >= 2 && _faceImageUrls.toSet().length >= 2;

  String? get _currentImageUrl {
    if (widget.card.imageNormal != null) return widget.card.imageNormal;
    final urls = _faceImageUrls;
    if (urls.isEmpty) return null;
    return urls[_faceIndex.clamp(0, urls.length - 1)];
  }

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
                  tooltip: appLocalizations.translate('flip_card'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}