import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'year_selector.dart';

class MonthCell extends StatelessWidget {
  const MonthCell({
    super.key,
    required this.month,
    required this.isSelected,
    required this.isCurrent,
    required this.onTap,
    required this.locale,
  });

  final DateTime month;
  final bool isSelected;
  final bool isCurrent;
  final VoidCallback onTap;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 68,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF4A3482), Color(0xFF6A53A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? null
              : isCurrent
                  ? (isDark ? Colors.grey.shade800 : const Color(0xFFECEFF1))
                  : (isDark ? Theme.of(context).cardColor : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : isCurrent
                    ? (isDark ? Colors.grey.shade700 : const Color(0xFFCFD8DC))
                    : (isDark
                        ? (Theme.of(context).dividerTheme.color ?? const Color(0xFF2D2D2D))
                        : const Color(0xFFF1F1F1)),
            width: 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6A53A1).withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('MMM', locale).format(month).toUpperCase(),
              style: AppTextStyles.label.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 1),
            YearSelector(
              year: DateFormat('yyyy', locale).format(month),
              isSelected: isSelected,
            ),
          ],
        ),
      ),
    );
  }
}
