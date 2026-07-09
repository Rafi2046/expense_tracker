import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingsDropdownOptionRow<T> extends StatelessWidget {
  final IconData icon;
  final String title;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final Color? iconBgColor;
  final Color? iconColor;

  const SettingsDropdownOptionRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
    this.iconBgColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = AppTextStyles.label.copyWith(
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurface,
    );

    final dropdownStyle = AppTextStyles.caption.copyWith(
      color: theme.brightness == Brightness.dark
          ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
          : AppColors.textMuted,
      fontWeight: FontWeight.w500,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Squircle leading icon container
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconBgColor ??
                  (theme.brightness == Brightness.dark
                      ? const Color(0xFF2D2D2D)
                      : const Color(0xFFF3F4F6)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor ??
                  (theme.brightness == Brightness.dark
                      ? Colors.white70
                      : const Color(0xFF4B5563)),
              size: 14,
            ),
          ),
          const SizedBox(width: 10),

          // Title
          Expanded(
            child: Text(
              title,
              style: textStyle,
            ),
          ),

          // Dropdown Button
          DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              icon: Icon(
                LucideIcons.chevronDown,
                color: theme.brightness == Brightness.dark
                    ? Colors.white60
                    : Colors.grey.shade400,
                size: 14,
              ),
              dropdownColor: theme.brightness == Brightness.dark
                  ? theme.cardColor
                  : Colors.white,
              style: dropdownStyle,
            ),
          ),
        ],
      ),
    );
  }
}
