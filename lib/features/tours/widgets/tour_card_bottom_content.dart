import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TourCardBottomContent extends StatelessWidget {
  final String name;
  final int memberCount;
  final String totalSpentFormatted;
  final String totalLabel;
  final String memberLabel;

  const TourCardBottomContent({
    super.key,
    required this.name,
    required this.memberCount,
    required this.totalSpentFormatted,
    required this.totalLabel,
    required this.memberLabel,
  });

  @override
  Widget build(BuildContext context) {
    // Full-width name so a reasonably long tour title (≈40–50 chars)
    // can wrap across up to 3 lines without competing with the amount column.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.displayMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    LucideIcons.users,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Flexible(
                    child: Text(
                      '$memberCount $memberLabel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
            // Flexible + Align keeps short amounts on the right, and lets
            // FittedBox shrink long amounts instead of overflowing.
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      totalLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.h4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        totalSpentFormatted,
                        maxLines: 1,
                        textAlign: TextAlign.end,
                        style: AppTextStyles.displayMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
