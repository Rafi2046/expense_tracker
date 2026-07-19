import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class CustomRoundButton extends StatelessWidget {
  final String imagePath;
  final VoidCallback onPressed;
  final double iconSize;

  const CustomRoundButton({
    super.key,
    required this.imagePath,
    required this.onPressed,
    this.iconSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? Colors.grey.shade700 : Colors.white,
          border: Border.all(
            color: isDark ? Colors.grey.shade600 : AppColors.borderColor,
            width: 1,
          ),
        ),
        child: Image.asset(
          imagePath,
          width: iconSize,
          height: iconSize,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
