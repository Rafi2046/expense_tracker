import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/models/transaction_models.dart';
import 'package:expense_tracker/features/dashboard/widgets/dashboard_recent_activity.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class DashboardTransactionList extends StatelessWidget {
  final bool isLoading;
  final List<TransactionItem> transactions;
  final VoidCallback onViewAllTap;
  final void Function(TransactionItem) onTransactionTap;

  const DashboardTransactionList({
    super.key,
    required this.isLoading,
    required this.transactions,
    required this.onViewAllTap,
    required this.onTransactionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildSkeleton(context);
    }

    return DashboardRecentActivity(
      items: transactions.take(3).map((tx) {
        return RecentActivityItem(
          title: tx.note.isEmpty ? tx.category : tx.note,
          category: tx.category,
          timeText: _getRelativeTime(tx.dateTime),
          amount: tx.amount,
          isIncome: tx.isIncome,
          icon: _getCategoryIcon(tx.category),
          transaction: tx,
        );
      }).toList(),
      onViewAllTap: onViewAllTap,
      onItemTap: (item) {
        final tx = item.transaction;
        if (tx != null) {
          onTransactionTap(tx);
        }
      },
    );
  }

  static String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }

  static IconData _getCategoryIcon(String category) {
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

  static Widget _buildSkeleton(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: AppTextStyles.bodyBold.copyWith(
                  color: theme.colorScheme.onSurface),
              ),
              Text(
                'View All',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        Skeletonizer(
          enabled: true,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(AppSpacing.r12),
            ),
            child: Column(
              children: List.generate(5, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.p12,
                    vertical: AppSpacing.p12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.08,
                          ),
                          borderRadius: BorderRadius.circular(AppSpacing.r12),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transaction Title',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface),
                            ),
                            const SizedBox(height: AppSpacing.s4),
                            Text(
                              'Category  •  Today',
                              style: AppTextStyles.caption.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '+৳0,000',
                        style: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
