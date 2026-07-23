import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class AccountCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget balance;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;

  const AccountCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.balance,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
    this.onLongPress,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.r12),
        border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFF3F4F6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppSpacing.r12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p12),
          child: Row(
            children: [
              // Icon Container (Smaller)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(AppSpacing.r12),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: AppSpacing.s12),

              // Labels
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyBold.copyWith(color: theme.colorScheme.onSurface),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      subtitle,
                      style: AppTextStyles.label,
                    ),
                  ],
                ),
              ),

              // Balance
              balance,
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.s4),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
