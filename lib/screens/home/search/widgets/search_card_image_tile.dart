import 'package:flutter/material.dart';

import '../../../../services/localization_service.dart';
import '../../../../services/scryfall/scryfall_card_print.dart';
import '../../../../theme/app_theme.dart';

class SearchCardImageTile extends StatefulWidget {
  const SearchCardImageTile({
    super.key,
    required this.card,
    this.onTap,
    this.onAddToDeck,
  });

  final ScryfallCardPrint card;
  final VoidCallback? onTap;
  final VoidCallback? onAddToDeck;

  @override
  State<SearchCardImageTile> createState() => _SearchCardImageTileState();
}

class _SearchCardImageTileState extends State<SearchCardImageTile> {
  int _faceIndex = 0;

  @override
  void didUpdateWidget(covariant SearchCardImageTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.card.id != widget.card.id) {
      _faceIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final imageUrls = card.displayImageNormals.isNotEmpty
        ? card.displayImageNormals
        : card.displayImageSmalls;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placeholderColor = isDark ? AppTheme.vaultSurfaceLight : AppTheme.vaultFog;
    final selectedUrl = imageUrls.isEmpty ? null : imageUrls[_faceIndex.clamp(0, imageUrls.length - 1)];

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Material(
        color: placeholderColor,
        child: InkWell(
          onTap: widget.onTap ?? widget.onAddToDeck,
          onLongPress: widget.onAddToDeck,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: placeholderColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.25 : 0.10),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: selectedUrl == null
                      ? _MissingImageCard(card: card)
                      : _NetworkCardImage(url: selectedUrl, card: card),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.58),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 18, 8, 8),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Material(
                        color: Colors.black.withOpacity(0.62),
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: widget.onAddToDeck,
                          child: Padding(
                            padding: const EdgeInsets.all(7),
                            child: Icon(
                              Icons.playlist_add,
                              color: Colors.white,
                              size: 19,
                              semanticLabel: appLocalizations.translate('decks.addToDeck'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (imageUrls.length > 1)
                Positioned(
                  top: 34,
                  right: 7,
                  child: Material(
                    color: Colors.black.withOpacity(0.58),
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => setState(() => _faceIndex = (_faceIndex + 1) % imageUrls.length),
                      child: const Padding(
                        padding: EdgeInsets.all(7),
                        child: Icon(Icons.flip_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NetworkCardImage extends StatelessWidget {
  const _NetworkCardImage({required this.url, required this.card});

  final String url;
  final ScryfallCardPrint card;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _MissingImageCard(card: card),
    );
  }
}

class _MissingImageCard extends StatelessWidget {
  const _MissingImageCard({required this.card});

  final ScryfallCardPrint card;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.style_outlined, size: 32),
          const SizedBox(height: 10),
          Text(
            card.name,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
