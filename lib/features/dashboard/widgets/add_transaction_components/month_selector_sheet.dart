import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
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
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.h16),
          Text(
            'Select Income Month',
            style: GoogleFonts.workSans(
              fontSize: AppFontSizes.size18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.h16),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.40,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: months.length,
              separatorBuilder: (_, _) => Divider(
                color: theme.dividerTheme.color ?? const Color(0xFFF5F5F5),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final monthDate = months[index];
                final label = DateFormat('MMMM yyyy').format(monthDate);
                final isSelected = selectedMonth == label;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    label,
                    style: GoogleFonts.workSans(
                      fontSize: AppFontSizes.size15,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: theme.colorScheme.onSurface,
                    ),
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
