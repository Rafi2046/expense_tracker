import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class InvoiceAllSettledWidget extends StatelessWidget {
  final bool isDark;

  const InvoiceAllSettledWidget({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF064E3B) : const Color(0xFFF0FDF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.activeGreen.withValues(alpha: isDark ? 0.3 : 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.checkCircle, color: AppColors.activeGreen, size: 44),
          const SizedBox(height: 12),
          Text(
            'All settled up',
            style: AppTextStyles.h2.copyWith(
              color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No payments needed \u2014 everyone is even',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              color: (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF6B7280))
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
