import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({super.key, required this.onExampleTap});

  final Future<void> Function(String query) onExampleTap;

  @override
  Widget build(BuildContext context) {
    final examples = const [
      'arcane signet',
      't:dragon',
      'o:draw mv<=3',
      'ci:uw t:legendary',
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: AppTheme.vaultAmber.withOpacity(0.14),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.auto_awesome_rounded, size: 34, color: AppTheme.vaultAmber),
          ),
          const SizedBox(height: 16),
          Text(
            'Was suchst du?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Name eingeben oder Scryfall-Filter nutzen.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.64),
                ),
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final example in examples)
                ActionChip(
                  avatar: const Icon(Icons.search_rounded, size: 16),
                  label: Text(example),
                  onPressed: () => onExampleTap(example),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
