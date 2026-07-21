import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

class WeeklySegmentControl extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final Color activeColor;
  final bool isDark;

  const WeeklySegmentControl({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.activeColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E222B) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF2D323F) : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selectedIndex == 0 ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  context.translate('distribution'),
                  style: TextStyle(
                    fontSize: AppFontSizes.size12,
                    fontWeight: FontWeight.bold,
                    color: selectedIndex == 0
                        ? Colors.white
                        : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selectedIndex == 1 ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  context.translate('trend'),
                  style: TextStyle(
                    fontSize: AppFontSizes.size12,
                    fontWeight: FontWeight.bold,
                    color: selectedIndex == 1
                        ? Colors.white
                        : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
