import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';

class WeeklySegmentControl extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final Color activeColor;
  final bool isDark;

  const WeeklySegmentControl({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.activeColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: AppSpacing.s48,
      padding: const EdgeInsets.all(AppSpacing.p4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.r24),
        border: Border.all(color: scheme.outline, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selectedIndex == 0 ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.r16),
                ),
                child: Text(
                  context.translate('distribution'),
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.bold,
                    color: selectedIndex == 0
                        ? scheme.onPrimary
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selectedIndex == 1 ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.r16),
                ),
                child: Text(
                  context.translate('trend'),
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.bold,
                    color: selectedIndex == 1
                        ? scheme.onPrimary
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
