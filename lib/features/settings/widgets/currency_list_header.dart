import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';

class CurrencyListHeader extends StatelessWidget {
  final String title;
  final double letterSpacing;
  final EdgeInsetsGeometry padding;

  const CurrencyListHeader({
    super.key,
    required this.title,
    this.letterSpacing = 1.5,
    this.padding = const EdgeInsets.only(top: 22.0, bottom: 8.0),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: padding,
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.grey.shade500 : const Color(0xFF9CA3AF),
          letterSpacing: letterSpacing,
        ),
      ),
    );
  }
}
