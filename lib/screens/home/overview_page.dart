import 'package:flutter/material.dart';

import '../../models/vault_user.dart';
import '../../services/localization_service.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key, required this.user});

  final VaultUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 220,
          backgroundColor: theme.scaffoldBackgroundColor,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primary.withValues(alpha: 0.20),
                    theme.scaffoldBackgroundColor,
                    secondary.withValues(alpha: 0.14),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 64, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      appLocalizations.translate('overview.greeting').replaceAll('{name}', user.displayName),
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      appLocalizations.translate('overview.subtitle'),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed([
              const _SummaryGrid(),
              const SizedBox(height: 20),
              _QuickActions(theme: theme),
            ]),
          ),
        ),
      ],
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: const [
        _SummaryCard(
          icon: Icons.auto_awesome,
          titleKey: 'overview.activeDecks',
          value: '8',
        ),
        _SummaryCard(
          icon: Icons.inventory_2_outlined,
          titleKey: 'overview.collectionSize',
          value: '2,184',
        ),
        _SummaryCard(
          icon: Icons.bar_chart_outlined,
          titleKey: 'overview.favoriteFormat',
          value: 'Commander',
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.titleKey,
    required this.value,
  });

  final IconData icon;
  final String titleKey;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: MediaQuery.sizeOf(context).width < 600 ? double.infinity : 180,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(height: 18),
              Text(
                value,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(appLocalizations.translate(titleKey)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appLocalizations.translate('overview.quickActionsTitle'),
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.add),
                  label: Text(appLocalizations.translate('overview.addDeck')),
                  onPressed: () {},
                ),
                ActionChip(
                  avatar: const Icon(Icons.search),
                  label: Text(appLocalizations.translate('overview.findCards')),
                  onPressed: () {},
                ),
                ActionChip(
                  avatar: const Icon(Icons.sync),
                  label: Text(appLocalizations.translate('overview.syncCollection')),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
