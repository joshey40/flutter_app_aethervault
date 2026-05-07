import 'package:flutter/material.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    required this.controller,
    required this.enabled,
    required this.onClear,
    required this.onSubmitted,
    required this.onChanged,
    this.onOpenFilter,
    this.onOpenSyntax,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onClear;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String> onChanged;
  final VoidCallback? onOpenFilter;
  final VoidCallback? onOpenSyntax;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            enabled: enabled,
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: onClear,
                    )
                  : null,
            ),
            onSubmitted: onSubmitted,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.tune),
          tooltip: 'Filter',
          onPressed: onOpenFilter,
        ),
        IconButton(
          icon: const Icon(Icons.help_outline),
          tooltip: 'Search Syntax',
          onPressed: onOpenSyntax,
        ),
      ],
    );
  }
}
