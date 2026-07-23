import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



class CategorySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Color themeColor;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback onAddPressed;

  const CategorySearchBar({
    super.key,
    required this.controller,
    required this.themeColor,
    this.onSubmitted,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.only(left: AppSpacing.p12, right: AppSpacing.p8, top: AppSpacing.p4, bottom: AppSpacing.p4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.r12),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2D2D2D)
              : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.done,
              style: AppTextStyles.body.copyWith(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: context.translate('enter_category_name_hint'),
                hintStyle: AppTextStyles.body.copyWith(color: isDark
                      ? Colors.grey.shade600
                      : Colors.grey.shade400),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.p12),
              ),
              onSubmitted: onSubmitted,
            ),
          ),
          IconButton(
            onPressed: onAddPressed,
            icon: Icon(LucideIcons.plusCircle,
                color: themeColor, size: 30),
            padding: const EdgeInsets.all(AppSpacing.p8),
            constraints: const BoxConstraints(),
            splashRadius: 24,
          ),
        ],
      ),
    );
  }
}
