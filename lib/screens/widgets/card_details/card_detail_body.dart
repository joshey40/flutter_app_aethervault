import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../services/card_database/database.dart';

class CardDetailBody extends StatelessWidget {
  const CardDetailBody({
    required this.card,
    this.actions,
    this.footer,
    super.key,
  });

  final ScryfallCard card;
  final Widget? actions;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (card.imageNormal != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: CachedNetworkImage(
                imageUrl: card.imageNormal!,
                fit: BoxFit.contain,
              ),
            ),
          const SizedBox(height: 16.0),
          Text(card.name, style: textTheme.titleLarge),
          const SizedBox(height: 4.0),
          Text(card.typeLine, style: textTheme.bodyMedium),
          const SizedBox(height: 12.0),
          if (card.oracleText != null)
            Text(card.oracleText!, style: textTheme.bodyMedium),
          if (card.power != null && card.toughness != null) ...[
            const SizedBox(height: 8.0),
            Text('${card.power}/${card.toughness}', style: textTheme.bodyLarge),
          ],
          if (actions != null) ...[
            const SizedBox(height: 20.0),
            actions!,
          ],
          if (footer != null) ...[
            const SizedBox(height: 20.0),
            footer!,
          ],
        ],
      ),
    );
  }
}