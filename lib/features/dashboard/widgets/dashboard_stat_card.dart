import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? statusText;
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
    final cornerColor = isPositive
        ? AppColors.selectionGreenBg
        : const Color(0xFFFFECEE);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.dividerColor, width: 1.0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // Scaled-down top-right corner color block with arrow icon
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: cornerColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(24),
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 8,
                      color: isPositive
                          ? AppColors.activeGreen
                          : AppColors.activeRed,
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 10.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Value (Large Text) on Top - scaled from 22 to 17
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style:
                          (isPositive
                                  ? AppTextStyles.cardValueGreen
                                  : AppTextStyles.cardValueRed)
                              .copyWith(fontSize: 17, color: textColor),
                    ),
                  ),
                  const SizedBox(height: 2), // reduced from 4
                  // Title (Small Mixed Case Text) on Bottom - scaled from 12 to 10.5
                  Text(
                    title,
                    style: AppTextStyles.cardTitle.copyWith(
                      fontSize: 10.5,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Trend / Status indicator if present
                  if ((isTrend && percentageText != null) ||
                      (!isTrend && statusText != null))
                    const SizedBox(height: 4), // reduced from 6
                  if (isTrend && percentageText != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive ? Icons.trending_up : Icons.trending_down,
                          color: isPositive
                              ? AppColors.activeGreen
                              : AppColors.activeRed,
                          size: 13, // reduced from 16
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            percentageText!,
                            style:
                                (isPositive
                                        ? AppTextStyles.cardTrendGreen
                                        : AppTextStyles.cardTrendRed)
                                    .copyWith(
                                      fontSize: 10.5, // reduced from 13
                                    ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  else if (!isTrend && statusText != null)
                    Text(
                      statusText!,
                      style: AppTextStyles.cardStatusText.copyWith(
                        fontSize: 10.5, // reduced from 13
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
