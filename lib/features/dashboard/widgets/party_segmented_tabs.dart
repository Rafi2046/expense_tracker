import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';

class PartySegmentedTabs extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTabChanged;

  const PartySegmentedTabs({
    super.key,
    required this.activeIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : const Color(0xFFF1F2F4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / 2;
          return Stack(
            children: [
              // Sliding active background pill
              AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOutCubic,
                alignment: activeIndex == 0
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  width: tabWidth - 4,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark ? theme.cardColor : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              // Tab labels row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onTabChanged(0),
                      child: Container(
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: Text(
                          context.translate('credit_info'),
                          style: activeIndex == 0
                              ? AppTextStyles.partyTabActive
                              : AppTextStyles.partyTabInactive.copyWith(
                                  color: isDark ? Colors.white60 : null,
                                ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onTabChanged(1),
                      child: Container(
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: Text(
                          context.translate('additional_details'),
                          style: activeIndex == 1
                              ? AppTextStyles.partyTabActive
                              : AppTextStyles.partyTabInactive.copyWith(
                                  color: isDark ? Colors.white60 : null,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
