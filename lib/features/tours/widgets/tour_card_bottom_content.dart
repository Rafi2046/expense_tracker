import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.displayMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.users,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.s6),
                Text(
                  '$memberCount $memberLabel',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  totalLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: AppFontSizes.size10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  totalSpentFormatted,
                  style: AppTextStyles.displayMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
