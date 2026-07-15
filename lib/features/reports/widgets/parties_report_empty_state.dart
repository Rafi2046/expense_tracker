import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PartiesReportEmptyState extends StatelessWidget {
  final bool isDark;

  const PartiesReportEmptyState({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60.0),
        child: Column(
          children: [
            Icon(
              LucideIcons.users,
              color: isDark ? Colors.white24 : Colors.grey.shade300,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              context.translate('no_parties_found'),
              style: AppTextStyles.reportTransactionSubtitle.copyWith(
                fontSize: AppFontSizes.size14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
