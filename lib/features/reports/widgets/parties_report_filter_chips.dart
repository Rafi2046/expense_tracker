import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



enum PartiesFilter { all, debtors, creditors }

class PartiesReportFilterChips extends StatelessWidget {
  final PartiesFilter selectedFilter;
  final ValueChanged<PartiesFilter> onFilterChanged;

  const PartiesReportFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildChip(context, PartiesFilter.all, context.translate('all')),
        const SizedBox(width: AppSpacing.s8),
        _buildChip(context, PartiesFilter.debtors, context.translate('debtors')),
        const SizedBox(width: AppSpacing.s8),
        _buildChip(context, PartiesFilter.creditors, context.translate('creditors')),
      ],
    );
  }

  Widget _buildChip(BuildContext context, PartiesFilter filter, String label) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = selectedFilter == filter;

    return GestureDetector(
      onTap: () => onFilterChanged(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor
              : (isDark ? Colors.white10 : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(AppSpacing.r24),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : theme.colorScheme.onSurface),
        ),
      ),
    );
  }
}
