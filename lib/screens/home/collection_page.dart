import 'package:flutter/material.dart';

import '../../services/localization_service.dart';

class CollectionPage extends StatelessWidget {
  const CollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(appLocalizations.translate('collection.title'), style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(appLocalizations.translate('collection.subtitle')),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appLocalizations.translate('collection.filtersTitle'), style: theme.textTheme.titleLarge),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilterChip(label: Text(appLocalizations.translate('collection.filterCreatures')), selected: true, onSelected: (_) {}),
                      FilterChip(label: Text(appLocalizations.translate('collection.filterArtifacts')), selected: false, onSelected: (_) {}),
                      FilterChip(label: Text(appLocalizations.translate('collection.filterInstants')), selected: false, onSelected: (_) {}),
                      FilterChip(label: Text(appLocalizations.translate('collection.filterRares')), selected: false, onSelected: (_) {}),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appLocalizations.translate('collection.placeholderTitle'), style: theme.textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Text(appLocalizations.translate('collection.placeholderBody')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
