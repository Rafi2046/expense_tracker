import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CurrencySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const CurrencySearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(LucideIcons.search, color: isDark ? Colors.grey.shade500 : const Color(0xFF9CA3AF), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              style: AppTextStyles.partyFormLabel.copyWith(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: context.translate('search_currency'),
                hintStyle: AppTextStyles.body.copyWith(
                  color: isDark ? Colors.grey.shade600 : const Color(0xFF9CA3AF),
                ),
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
