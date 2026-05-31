import 'package:flutter/material.dart';

import '../../../../services/scryfall/bulk_data_type.dart';
import '../../../../theme/app_theme.dart';

enum SearchIndexStatus { ready, preparing, missing }

class SearchIndexStatusIcons extends StatelessWidget {
  const SearchIndexStatusIcons({
    super.key,
    required this.checking,
    required this.statuses,
    required this.onRefresh,
  });

  final bool checking;
  final Map<ScryfallBulkDataType, SearchIndexStatus> statuses;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (checking) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return PopupMenuButton<void>(
      tooltip: 'Scryfall-Indexstatus',
      icon: const Icon(Icons.storage_rounded),
      onSelected: (_) => onRefresh(),
      itemBuilder: (context) => [
        for (final type in ScryfallBulkDataType.values)
          PopupMenuItem<void>(
            enabled: false,
            child: Row(
              children: [
                _IndexStatusIcon(status: statuses[type] ?? SearchIndexStatus.missing),
                const SizedBox(width: 10),
                Expanded(child: Text(type.userFacingName)),
                Text(_statusLabel(statuses[type] ?? SearchIndexStatus.missing)),
              ],
            ),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem<void>(
          value: null,
          child: Row(
            children: [
              Icon(Icons.refresh_rounded),
              SizedBox(width: 10),
              Text('Status aktualisieren'),
            ],
          ),
        ),
      ],
    );
  }

  static String _statusLabel(SearchIndexStatus status) {
    switch (status) {
      case SearchIndexStatus.ready:
        return 'bereit';
      case SearchIndexStatus.preparing:
        return 'wird vorbereitet';
      case SearchIndexStatus.missing:
        return 'fehlt';
    }
  }
}

class _IndexStatusIcon extends StatelessWidget {
  const _IndexStatusIcon({required this.status});

  final SearchIndexStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case SearchIndexStatus.ready:
        return const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20);
      case SearchIndexStatus.preparing:
        return const Icon(Icons.pending_rounded, color: AppTheme.vaultAmber, size: 20);
      case SearchIndexStatus.missing:
        return Icon(Icons.error_rounded, color: Theme.of(context).colorScheme.error, size: 20);
    }
  }
}
