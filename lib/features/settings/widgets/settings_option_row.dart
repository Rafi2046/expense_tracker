import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsOptionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingText;
  final IconData? trailingIcon;
  final Color? color;
  final Color? iconBgColor;
  final Color? iconColor;
  final VoidCallback onTap;

  const SettingsOptionRow({
    super.key,
    required this.icon,
    required this.title,
    this.trailingText,
    this.trailingIcon,
    this.color,
    this.iconBgColor,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final defaultColor = color ?? Colors.black87;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // Squircle leading icon container
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor ?? const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor ?? color ?? const Color(0xFF4B5563),
                size: 18,
              ),
            ),
            const SizedBox(width: 16),

            // Title
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.workSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: defaultColor,
                ),
              ),
            ),

            // Trailing Text (if any)
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: GoogleFonts.workSans(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
            ],

            // Chevron Arrow
            Icon(
              trailingIcon ?? Icons.chevron_right_rounded,
              color: color ?? Colors.grey.shade400,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
