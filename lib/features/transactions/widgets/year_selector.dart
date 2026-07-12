import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class YearSelector extends StatelessWidget {
  const YearSelector({
    super.key,
    required this.year,
    required this.isSelected,
  });

  final String year;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      year,
      style: AppTextStyles.caption.copyWith(
        fontSize: AppFontSizes.size9,
        fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
        color: isSelected ? Colors.white70 : (isDark ? Colors.grey.shade400 : Colors.grey.shade500),
      ),
    );
  }
}
