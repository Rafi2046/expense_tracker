import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PartyStatementNoTransactions extends StatelessWidget {
  const PartyStatementNoTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.receipt,
                color: theme.brightness == Brightness.dark
                    ? Colors.white12
                    : Colors.grey.shade200,
                size: 72),
            const SizedBox(height: 16),
            Text(
              context.translate('no_transactions_found'),
              style: AppTextStyles.reportTransactionSubtitle.copyWith(
                fontSize: AppFontSizes.size15,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
