import 'package:material_ui/material_ui.dart';
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
  late final Future<CardDetailData?> _cardFuture;

  @override
  void initState() {
    super.initState();
    _cardFuture = loadCardDetailData(widget.cardId);
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
      body: FutureBuilder<CardDetailData?>(
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

/// A card with everything the detail sheet needs.
class CardDetailData {
  const CardDetailData({
    required this.card,
    required this.faces,
    required this.variants,
    required this.variantFaces,
  });

  final ScryfallCard card;
  final List<ScryfallCardFace> faces;

  /// All printings (every set and language) of the card.
  final List<ScryfallCard> variants;
  final Map<String, List<ScryfallCardFace>> variantFaces;
}

/// Loads a card, its printed variants, and all variant faces.
/// Null if the card is not in the local Scryfall data.
Future<CardDetailData?> loadCardDetailData(String cardId) async {
  final database = AppDatabase();
  final card = await database.getCardById(cardId);
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

  return CardDetailData(
    card: card,
    faces: facesByCardId[card.scryfallId] ?? const [],
    variants: variants,
    variantFaces: facesByCardId,
  );
}
