import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/models/transaction_models.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class RecentActivityItemCard extends StatelessWidget {
  final TransactionItem transaction;
  final void Function(TransactionItem)? onTap;

  const RecentActivityItemCard({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tx = transaction;
    final isInc = tx.isIncome;
    final icon = _iconForCategory(tx.category);

    return InkWell(
      onTap: onTap != null ? () => onTap!(tx) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isInc
                    ? AppColors.activeGreen.withValues(alpha: 0.08)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFF3F4F6)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isInc
                    ? AppColors.activeGreen
                    : (isDark ? Colors.white70 : const Color(0xFF4A5568)),
                size: 17,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.note.isEmpty ? tx.category : tx.note,
                    style: GoogleFonts.workSans(
                      fontSize: AppFontSizes.size13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${tx.category}  •  ${_formatTime(tx.dateTime)}',
                    style: GoogleFonts.workSans(
                      fontSize: AppFontSizes.size10,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isInc ? '+' : '-',
                  style: GoogleFonts.workSans(
                    fontSize: AppFontSizes.size12,
                    fontWeight: FontWeight.w700,
                    color: isInc ? AppColors.activeGreen : AppColors.expensePink,
                  ),
                ),
                PrivacyMaskedText(
                  amount: tx.amount,
                  style: GoogleFonts.workSans(
                    fontSize: AppFontSizes.size12,
                    fontWeight: FontWeight.w700,
                    color: isInc ? AppColors.activeGreen : AppColors.expensePink,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }

  static IconData _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'dining':
      case 'restaurant':
        return Symbols.restaurant;
      case 'income':
      case 'salary':
        return Symbols.payments;
      case 'transport':
      case 'fuel':
      case 'travel':
        return Symbols.directions_car;
      case 'shopping':
      case 'clothing':
      case 'electronics':
        return Symbols.shopping_bag;
      case 'entertainment':
      case 'movie':
        return Symbols.movie;
      case 'utilities':
      case 'bills':
      case 'rent':
        return Symbols.receipt_long;
      case 'health':
      case 'medical':
        return Symbols.local_hospital;
      case 'education':
      case 'school':
        return Symbols.school;
      case 'transfer':
        return Symbols.swap_horiz;
      default:
        return Symbols.receipt_long;
    }
  }
}
