import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DashboardStatCard extends StatelessWidget {
  final String title;
  final Widget value;
  final Widget? statusText;
  final String? percentageText;
  final bool isPositive;
  final bool isTrend;
  final Color? textColor;
  final VoidCallback? onTap;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    this.statusText,
    this.percentageText,
    required this.isPositive,
    required this.isTrend,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasTrendIndicator = isTrend && percentageText != null;
    final hasStatus = !isTrend && statusText != null;
    final hasBottomContent = hasTrendIndicator || hasStatus;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.r8),
      child: Container(
        height: 78,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(
            color: Theme.of(context).dividerTheme.color ?? AppColors.dividerColor,
            width: AppSpacing.w1,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.r8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        clipBehavior: Clip.hardEdge,
                        child: value,
                      ),
                    ),
                    SizedBox(height: AppSpacing.h2),
                    Text(
                      title,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: AppFontSizes.size10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasBottomContent) ...[
                      SizedBox(height: AppSpacing.h2),
                      if (hasTrendIndicator)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPositive ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                              color: isPositive
                                  ? AppColors.activeGreen
                                  : AppColors.activeRed,
                              size: 13,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                percentageText!,
                                style: (isPositive
                                        ? AppTextStyles.cardTrendGreen
                                        : AppTextStyles.cardTrendRed)
                                    .copyWith(fontSize: AppFontSizes.size10),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      else
                        DefaultTextStyle(
                          style: DefaultTextStyle.of(context).style.copyWith(
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                          child: statusText!,
                        ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.p8),
              Icon(
                LucideIcons.chevronRight,
                color: AppColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
