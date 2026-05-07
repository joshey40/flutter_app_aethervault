import 'package:flutter/material.dart';

class ResultList extends StatelessWidget {
  const ResultList({
    super.key,
    required this.loadingData,
    required this.searching,
    required this.results,
    required this.isGridView,
    required this.scrollController,
    required this.gridItemBuilder,
    required this.listItemBuilder,
    required this.tryExamplesBuilder,
    required this.noResultsBuilder,
  });

  final bool loadingData;
  final bool searching;
  final List<dynamic>? results;
  final bool isGridView;
  final ScrollController scrollController;
  final Widget Function(BuildContext, int) gridItemBuilder;
  final Widget Function(BuildContext, int) listItemBuilder;
  final Widget Function(BuildContext) tryExamplesBuilder;
  final Widget Function(BuildContext) noResultsBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (loadingData) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text('Preparing…', style: theme.textTheme.bodySmall),
          ],
        ),
      );
    }

    if (searching) return const Center(child: CircularProgressIndicator());

    if (results == null) {
      return Center(child: tryExamplesBuilder(context));
    }

    if (results!.isEmpty) return Center(child: noResultsBuilder(context));

    return isGridView
        ? GridView.builder(
            controller: scrollController,
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 63 / 88,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: results!.length,
            itemBuilder: gridItemBuilder,
          )
        : ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.zero,
            itemCount: results!.length,
            itemBuilder: listItemBuilder,
          );
  }
}
