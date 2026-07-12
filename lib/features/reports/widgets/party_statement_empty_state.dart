import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:flutter/material.dart';

class PartyStatementEmptyState extends StatelessWidget {
  const PartyStatementEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppImages.partyReportIcon, width: 150, height: 200),
            const SizedBox(height: 16),
            Text(
              'Select Party to View Report',
              style: AppTextStyles.reportAppBarTitle.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontSize: AppFontSizes.size15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
