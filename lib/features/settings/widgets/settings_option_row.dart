import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingsOptionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingText;
  final IconData? trailingIcon;
  final Color? color;
  final Color? iconColor;
  final VoidCallback onTap;

  const SettingsOptionRow({
    super.key,
    required this.icon,
    required this.title,
    this.trailingText,
    this.trailingIcon,
    this.color,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultColor = color ?? theme.colorScheme.onSurface;
    final resolvedIconColor = iconColor ?? (isDark ? Colors.white70 : Colors.grey.shade600);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: resolvedIconColor, size: 22),
            const SizedBox(width: 16),

            // Title
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w600,
                  color: defaultColor,
                ),
              ),
            ),

            // Trailing Text (if any)
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 6),
            ],

            // Chevron Arrow
            Icon(
              trailingIcon ?? LucideIcons.chevronRight,
              color: color ?? (isDark ? Colors.white60 : Colors.grey.shade400),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
