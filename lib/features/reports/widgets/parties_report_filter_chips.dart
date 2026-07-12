import 'package:flutter/material.dart';

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
        _buildChip(context, PartiesFilter.all, 'All'),
        const SizedBox(width: 8),
        _buildChip(context, PartiesFilter.debtors, 'Debtors'),
        const SizedBox(width: 8),
        _buildChip(context, PartiesFilter.creditors, 'Creditors'),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor
              : (isDark ? Colors.white10 : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
