import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../screens/widgets/card_details/card_deatail_sheet.dart';
import '../card_database/database.dart';
import '../localization_service.dart';

// =============================================================================
// Card detail route
// =============================================================================

/// Loads the selected card and presents its search-specific detail actions.
class CardDetailRoute extends StatefulWidget {
  const CardDetailRoute({required this.cardId, super.key});

  final String cardId;

  @override
  State<CardDetailRoute> createState() => _CardDetailRouteState();
}

class _CardDetailRouteState extends State<CardDetailRoute> {
  late final Future<_CardDetailData?> _cardFuture;

  @override
  void initState() {
    super.initState();
    _cardFuture = _loadCard();
  }

  /// Loads the selected card, its printed variants, and all variant faces.
  Future<_CardDetailData?> _loadCard() async {
    final database = AppDatabase();
    final card = await database.getCardById(widget.cardId);
    if (card == null) return null;

    final variants = card.oracleId == null
        ? <ScryfallCard>[card]
        : await database.getCardVariantsByOracleId(card.oracleId!);
    final facesByCardId = <String, List<ScryfallCardFace>>{};
    for (final variant in variants) {
      facesByCardId[variant.scryfallId] = await database.getCardFacesByCardId(
        variant.scryfallId,
      );
    }

    return _CardDetailData(
      card: card,
      faces: facesByCardId[card.scryfallId] ?? const [],
      variants: variants,
      variantFaces: facesByCardId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.translate('card_detail.title')),
        leading: IconButton(
          tooltip: appLocalizations.translate('back'),
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<_CardDetailData?>(
        future: _cardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${appLocalizations.translate('card_detail.load_error')}: ${snapshot.error}',
              ),
            );
          }

          final data = snapshot.data;
          if (data == null) {
            return Center(
              child: Text(appLocalizations.translate('card_detail.not_found')),
            );
          }

          return CardDetailSheet(
            card: data.card,
            faces: data.faces,
            variants: data.variants,
            variantFaces: data.variantFaces,
            showSearchActions: true,
          );
        },
      ),
    );
  }
}

class _CardDetailData {
  const _CardDetailData({
    required this.card,
    required this.faces,
    required this.variants,
    required this.variantFaces,
  });

  final ScryfallCard card;
  final List<ScryfallCardFace> faces;
  final List<ScryfallCard> variants;
  final Map<String, List<ScryfallCardFace>> variantFaces;
}
