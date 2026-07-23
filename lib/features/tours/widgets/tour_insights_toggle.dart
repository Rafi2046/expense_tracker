import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';

/// Apple-style sliding segmented control for tour insights tabs.
class TourInsightsToggle extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const TourInsightsToggle({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  static const _swipeVelocityThreshold = 120.0;
  static const _accent = AppColors.activeGreen; // #2EBD85

  void _onHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity;
    if (velocity == null) return;

    // Swipe left → next tab; swipe right → previous tab.
    if (velocity < -_swipeVelocityThreshold && selectedIndex < 1) {
      onChanged(1);
    } else if (velocity > _swipeVelocityThreshold && selectedIndex > 0) {
      onChanged(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final labels = [
      context.translate('by_category'),
      context.translate('by_member'),
    ];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Container(
        height: AppSpacing.s40,
        padding: const EdgeInsets.all(AppSpacing.p4),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(AppSpacing.r12),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final segmentWidth = constraints.maxWidth / labels.length;
            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOutCubic,
                  left: selectedIndex * segmentWidth,
                  top: 0,
                  bottom: 0,
                  width: segmentWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(AppSpacing.r8),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < labels.length; i++)
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onChanged(i),
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 180),
                              style: AppTextStyles.label.copyWith(
                                fontWeight: FontWeight.w600,
                                color: selectedIndex == i
                                    ? Colors.white
                                    : scheme.onSurface,
                              ),
                              child: Text(
                                labels[i],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}
