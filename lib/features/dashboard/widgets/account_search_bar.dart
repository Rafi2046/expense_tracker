import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

class AccountSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String searchQuery;
  final bool hasActiveFilters;
  final Function(String query) onSearchChanged;
  final VoidCallback onResetFilters;

  const AccountSearchBar({
    super.key,
    required this.controller,
    required this.searchQuery,
    required this.hasActiveFilters,
    required this.onSearchChanged,
    required this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 38,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Icon(LucideIcons.search, color: Colors.grey, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: TextStyle(fontSize: AppFontSizes.size13, color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: context.translate('search_transactions'),
                      hintStyle: TextStyle(color: Colors.grey, fontSize: AppFontSizes.size13),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: onSearchChanged,
                  ),
                ),
                if (searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      controller.clear();
                      onSearchChanged('');
                    },
                    child: Icon(LucideIcons.x, color: Colors.grey, size: 16),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Filter icon button
        Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1)),
          ),
          child: IconButton(
            icon: Icon(LucideIcons.filter, color: theme.colorScheme.onSurface, size: 18),
            padding: EdgeInsets.zero,
            onPressed: () {
              if (hasActiveFilters) {
                controller.clear();
                onResetFilters();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.translate('filters_reset'))),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.translate('use_search_or_change_date'))),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
