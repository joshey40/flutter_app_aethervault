import 'package:flutter/material.dart';

import '../search_sort_mode.dart';

class SearchResultsHeader extends StatelessWidget {
  const SearchResultsHeader({
    super.key,
    required this.count,
    required this.sortMode,
    required this.onSortModeChanged,
  });

  final int count;
  final SearchSortMode sortMode;
  final ValueChanged<SearchSortMode> onSortModeChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$count Treffer',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        PopupMenuButton<SearchSortMode>(
          tooltip: 'Sortierung ändern',
          initialValue: sortMode,
          onSelected: onSortModeChanged,
          itemBuilder: (context) => [
            for (final mode in SearchSortMode.values)
              PopupMenuItem(
                value: mode,
                child: Row(
                  children: [
                    if (mode == sortMode) const Icon(Icons.check_rounded, size: 18) else const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Text(mode.label),
                  ],
                ),
              ),
          ],
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                sortMode.label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.sort_rounded, size: 18),
            ],
          ),
        ),
      ],
    );
  }
}
