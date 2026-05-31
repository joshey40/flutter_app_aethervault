import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

class CompactSearchBar extends StatefulWidget {
  const CompactSearchBar({
    super.key,
    required this.controller,
    required this.isSearching,
    required this.onSearch,
  });

  final TextEditingController controller;
  final bool isSearching;
  final Future<void> Function() onSearch;

  @override
  State<CompactSearchBar> createState() => _CompactSearchBarState();
}

class _CompactSearchBarState extends State<CompactSearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant CompactSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppTheme.vaultSurfaceLight : AppTheme.vaultFog;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor.withOpacity(0.65)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded),
                  hintText: 'Kartensuche: t:dragon, o:draw, arcane signet...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  suffixIcon: widget.controller.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Eingabe löschen',
                          onPressed: () => widget.controller.clear(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => widget.onSearch(),
              ),
            ),
            const SizedBox(width: 6),
            FilledButton(
              onPressed: widget.isSearching ? null : widget.onSearch,
              style: FilledButton.styleFrom(
                minimumSize: const Size(48, 48),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: widget.isSearching
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_forward_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
