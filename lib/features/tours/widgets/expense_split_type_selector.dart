import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

class ExpenseSplitTypeSelector extends StatelessWidget {
  final ThemeData theme;
  final String splitType;
  final ValueChanged<String> onSplitTypeChanged;

  static const _types = ['equal', 'exact', 'percentage', 'exclusion'];
  static const _labels = ['equal_split_label', 'exact_split_label', 'percent_split_label', 'exclude_split_label'];
  static const _icons = [
    LucideIcons.gripHorizontal,
    LucideIcons.pin,
    LucideIcons.percent,
    LucideIcons.userX,
  ];

  const ExpenseSplitTypeSelector({
    super.key,
    required this.theme,
    required this.splitType,
    required this.onSplitTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(_types.length, (i) {
          final active = splitType == _types[i];
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: i > 0 ? 4 : 0),
              child: GestureDetector(
                onTap: () => onSplitTypeChanged(_types[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? AppColors.activeGreen : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: active
                        ? [BoxShadow(color: AppColors.activeGreen.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Icon(_icons[i], size: 16, color: active ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                      const SizedBox(height: 2),
                      Text(
                        context.translate(_labels[i]),
                        style: AppTextStyles.caption.copyWith(
                          fontSize: AppFontSizes.size10,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                          color: active ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
