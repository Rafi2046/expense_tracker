import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class OnboardingPageIndicator extends StatelessWidget {
  final int itemCount;
  final int currentPage;

  const OnboardingPageIndicator({
    super.key,
    required this.itemCount,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.grey.shade200;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p8, vertical: AppSpacing.p8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.r24),
        color: trackColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(itemCount, (index) {
          final isActive = index == currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.p4),
            width: isActive ? 32 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.r8),
              gradient: isActive
                  ? const LinearGradient(
                      colors: [
                        AppColors.activeGreen,
                        Color(0xFF36D399),
                      ],
                    )
                  : null,
              color: isActive
                  ? null
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.18)
                      : Colors.grey.shade400),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.activeGreen.withValues(alpha: 0.4),
                        blurRadius: 6,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
          );
        }),
      ),
    );
  }
}
