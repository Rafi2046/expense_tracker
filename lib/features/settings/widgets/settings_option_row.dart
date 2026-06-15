import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsOptionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingText;
  final Color? color;
  final VoidCallback onTap;

  const SettingsOptionRow({
    super.key,
    required this.icon,
    required this.title,
    this.trailingText,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final defaultColor = color ?? Colors.black87;
    final leadingIconColor = color ?? const Color(0xFF31394D);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            // Leading Icon
            Icon(
              icon,
              color: leadingIconColor,
              size: 22,
            ),
            const SizedBox(width: 16),

            // Title
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: defaultColor,
                  fontFamily: GoogleFonts.workSans().fontFamily,
                ),
              ),
            ),

            // Trailing Text (if any)
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  fontFamily: GoogleFonts.workSans().fontFamily,
                ),
              ),
              const SizedBox(width: 4),
            ],

            // Chevron Arrow
            Icon(
              Icons.chevron_right,
              color: color ?? AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
