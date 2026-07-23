import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



class WeeklyStatCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  final bool isDark;

  const WeeklyStatCard({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.p12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.r12),
        border: Border.all(
          color: isDark ? const Color(0xFF2D323F) : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 14),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          child,
        ],
      ),
    );
  }
}
