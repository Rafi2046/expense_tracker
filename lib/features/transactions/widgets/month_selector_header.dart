import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'month_grid.dart';

class MonthSelectorHeader extends StatelessWidget {
  const MonthSelectorHeader({
    super.key,
    required this.scrollController,
    required this.months,
    required this.selectedIndex,
    required this.locale,
    required this.onMonthTap,
    required this.onFilterTap,
  });

  final ScrollController scrollController;
  final List<DateTime> months;
  final int selectedIndex;
  final String locale;
  final ValueChanged<int> onMonthTap;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: MonthGrid(
            scrollController: scrollController,
            months: months,
            selectedIndex: selectedIndex,
            locale: locale,
            onMonthTap: onMonthTap,
          ),
        ),
        const SizedBox(width: AppSpacing.s12),
        Container(
          width: 44,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? (Theme.of(context).dividerTheme.color ?? const Color(0xFF2D2D2D))
                  : const Color(0xFFF1F1F1),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.01),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(LucideIcons.slidersHorizontal, size: 18),
            color: isDark ? Colors.white70 : const Color(0xFF31394D),
            onPressed: onFilterTap,
          ),
        ),
      ],
    );
  }
}
