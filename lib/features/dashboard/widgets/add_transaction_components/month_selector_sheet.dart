import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';


class MonthSelectorSheet extends StatelessWidget {
  final List<DateTime> months;
  final String? selectedMonth;
  final ValueChanged<String> onSelect;

  const MonthSelectorSheet({
    super.key,
    required this.months,
    required this.selectedMonth,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.r24),
          topRight: Radius.circular(AppSpacing.r24),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p24, vertical: AppSpacing.p16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(AppSpacing.r12),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.h16),
          Text(
            context.translate('select_income_month'),
            style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: AppSpacing.h16),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.40,
            child: ListView.separated(
              itemCount: months.length,
              separatorBuilder: (_, _) => Divider(
                color: theme.dividerTheme.color ?? const Color(0xFFF5F5F5),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final monthDate = months[index];
                final label = context.formatDate(monthDate, pattern: 'MMMM yyyy');
                final isSelected = selectedMonth == label;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    label,
                    style: AppTextStyles.body.copyWith(fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: theme.colorScheme.onSurface),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          LucideIcons.checkCircle,
                          color: AppColors.activeGreen,
                        )
                      : null,
                  onTap: () => onSelect(label),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.h8),
        ],
      ),
    );
  }
}
