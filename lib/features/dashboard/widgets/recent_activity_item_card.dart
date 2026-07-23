import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/models/transaction_models.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p12),
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
                borderRadius: BorderRadius.circular(AppSpacing.r12),
              ),
              child: Icon(
                icon,
                color: isInc
                    ? AppColors.activeGreen
                    : (isDark ? Colors.white70 : const Color(0xFF4A5568)),
                size: 17,
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.note.isEmpty ? tx.category : tx.note,
                    style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    '${tx.category}  •  ${_formatTime(tx.dateTime)}',
                    style: AppTextStyles.caption.copyWith(color: Colors.grey.shade400,
                      fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isInc ? '+' : '-',
                  style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700,
                    color: isInc ? AppColors.activeGreen : AppColors.expensePink),
                ),
                PrivacyMaskedText(
                  amount: tx.amount,
                  style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700,
                    color: isInc ? AppColors.activeGreen : AppColors.expensePink),
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
        return LucideIcons.utensilsCrossed;
      case 'income':
      case 'salary':
        return LucideIcons.creditCard;
      case 'transport':
      case 'fuel':
      case 'travel':
        return LucideIcons.car;
      case 'shopping':
      case 'clothing':
      case 'electronics':
        return LucideIcons.shoppingBag;
      case 'entertainment':
      case 'movie':
        return LucideIcons.clapperboard;
      case 'utilities':
      case 'bills':
      case 'rent':
        return LucideIcons.receipt;
      case 'health':
      case 'medical':
        return LucideIcons.heartPulse;
      case 'education':
      case 'school':
        return LucideIcons.graduationCap;
      case 'transfer':
        return LucideIcons.arrowLeftRight;
      default:
        return LucideIcons.receipt;
    }
  }
}
