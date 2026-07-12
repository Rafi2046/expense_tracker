import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/models/transaction_models.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class IncomeCategoryBreakdown extends StatelessWidget {
  final List<TransactionItem> transactions;
  final bool isMasked;

  const IncomeCategoryBreakdown({
    super.key,
    required this.transactions,
    required this.isMasked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakdown = _computeBreakdown();

    if (breakdown.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Center(child: Text('No income data')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Income by Category',
          style: AppTextStyles.sectionHeaderTitle.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...breakdown.entries.map((entry) {
          final icon = _categoryIcon(entry.key);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.activeGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.activeGreen, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: AppFontSizes.size14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                          fontFamily: GoogleFonts.workSans().fontFamily,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${entry.value} transaction${entry.value == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: AppFontSizes.size12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          fontFamily: GoogleFonts.workSans().fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                PrivacyMaskedText(
                  amount: entry.value,
                  isMasked: isMasked,
                  style: TextStyle(
                    fontSize: AppFontSizes.size14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.activeGreen,
                    fontFamily: GoogleFonts.workSans().fontFamily,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Map<String, double> _computeBreakdown() {
    final map = <String, double>{};
    for (final tx in transactions) {
      final cat = tx.category.isNotEmpty ? tx.category : 'Other';
      map.update(cat, (v) => v + tx.amount, ifAbsent: () => tx.amount);
    }
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  IconData _categoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('salary')) return LucideIcons.landmark;
    if (lower.contains('freelance') || lower.contains('business') || lower.contains('work')) {
      return LucideIcons.briefcase;
    }
    if (lower.contains('dividend') || lower.contains('invest') || lower.contains('saving')) {
      return LucideIcons.lineChart;
    }
    return LucideIcons.building2;
  }
}
