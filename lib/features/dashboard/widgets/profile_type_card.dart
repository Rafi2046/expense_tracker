import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



class ProfileTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const ProfileTypeCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.p12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2EBD85).withValues(alpha: 0.12)
              : theme.cardColor,
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2EBD85)
                : theme.dividerColor,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.r12),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF2EBD85)
                    : (isDark
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.1)
                        : Colors.grey.shade100),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                        : Colors.grey.shade600),
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600,
                      color: theme.textTheme.titleMedium?.color),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    subtitle,
                    style: AppTextStyles.label.copyWith(color: theme.textTheme.bodySmall?.color),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(LucideIcons.checkCircle, color: Color(0xFF2EBD85), size: 22),
          ],
        ),
      ),
    );
  }
}
