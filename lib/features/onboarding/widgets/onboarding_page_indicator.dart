import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';

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

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive
                ? AppColors.activeGreen
                : (isDark ? Colors.white24 : Colors.grey.shade300),
          ),
        );
      }),
    );
  }
}
