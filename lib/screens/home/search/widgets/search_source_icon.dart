import 'package:flutter/material.dart';

import '../../../../services/scryfall/scryfall_search_repository.dart';
import '../../../../theme/app_theme.dart';

class SearchSourceIcon extends StatelessWidget {
  const SearchSourceIcon({super.key, required this.source});

  final ScryfallSearchResultSource source;

  @override
  Widget build(BuildContext context) {
    final (icon, tooltip) = switch (source) {
      ScryfallSearchResultSource.localOracleCards => (Icons.auto_stories_rounded, 'Letzte Suche: Oracle Cards'),
      ScryfallSearchResultSource.localDefaultCards => (Icons.storage_rounded, 'Letzte Suche: Default Cards'),
      ScryfallSearchResultSource.localAllCards => (Icons.inventory_2_rounded, 'Letzte Suche: All Cards'),
      ScryfallSearchResultSource.remoteScryfallApi => (Icons.cloud_sync_rounded, 'Letzte Suche: online'),
    };

    return Tooltip(
      message: tooltip,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Icon(icon, color: AppTheme.vaultAmber),
      ),
    );
  }
}
