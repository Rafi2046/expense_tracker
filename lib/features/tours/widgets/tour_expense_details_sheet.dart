import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/models/tour_expense.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/tours/widgets/full_screen_image_viewer.dart';
import 'package:expense_tracker/features/tours/widgets/tour_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class TourExpenseDetailsSheet extends StatelessWidget {
  final TourExpense expense;
  final String payerName;
  final String currency;
  final String Function(double, String) formatAmount;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;
  final bool showDelete;

  const TourExpenseDetailsSheet({
    super.key,
    required this.expense,
    required this.payerName,
    required this.currency,
    required this.formatAmount,
    required this.onDelete,
    this.onEdit,
    this.showDelete = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final formattedDate = DateFormat('dd MMM yyyy, h:mm a').format(expense.date);

    String splitLabel;
    switch (expense.splitType) {
      case 'equal':
        splitLabel = context.translate('split_equally');
        break;
      case 'exact':
        splitLabel = context.translate('split_exact');
        break;
      case 'percentage':
        splitLabel = context.translate('split_percent');
        break;
      case 'exclusion':
        splitLabel = context.translate('split_exclusion_label');
        break;
      default:
        splitLabel = context.translate('split_equally');
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.r24),
          topRight: Radius.circular(AppSpacing.r24),
        ),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D3D) : const Color(0xFFF1F5F9),
          width: 1.2,
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.p12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(AppSpacing.r8),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p24, vertical: AppSpacing.p8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        style: AppTextStyles.h1.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (expense.category != null) ...[
                        const SizedBox(height: AppSpacing.s4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p8, vertical: AppSpacing.p4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2D2D3D) : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(AppSpacing.r8),
                          ),
                          child: Text(
                            expense.category!,
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  formatAmount(expense.amount, currency),
                  style: AppTextStyles.displayMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const Divider(indent: 24, endIndent: 24, height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p24),
            child: Column(
              children: [
                _buildDetailRow(theme, context.translate('paid_by_detail'), payerName),
                const SizedBox(height: AppSpacing.s12),
                _buildDetailRow(theme, context.translate('date_time_detail'), formattedDate),
                const SizedBox(height: AppSpacing.s12),
                _buildDetailRow(theme, context.translate('split_method_detail'), splitLabel),
                if (expense.note != null && expense.note!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.s12),
                  _buildDetailRow(theme, context.translate('note_detail'), expense.note!),
                ],
              ],
            ),
          ),
          if (expense.receiptPaths.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p24),
              child: SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: expense.receiptPaths.length,
                  separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s8),
                  itemBuilder: (ctx, i) {
                    final path = expense.receiptPaths[i];
                    final notFound = Container(
                      width: 160,
                      height: 160,
                      padding: const EdgeInsets.all(AppSpacing.p16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(AppSpacing.r12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF2D2D3D) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.imageOff, color: Colors.grey.shade400),
                          const SizedBox(height: AppSpacing.s8),
                          Text(
                            context.translate('receipt_image_not_found'),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption.copyWith(color: const Color(0xFF9CA3AF)),
                          ),
                        ],
                      ),
                    );
                    return GestureDetector(
                      onTap: () => FullScreenImageViewer.show(
                        context, expense.receiptPaths, index: i,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppSpacing.r12),
                        child: TourImage(
                          source: path,
                          width: 160,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => notFound,
                          placeholder: notFound,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.s24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (onEdit != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.p12),
                    child: ElevatedButton.icon(
                      onPressed: onEdit,
                      icon: Icon(LucideIcons.edit, color: Colors.white, size: 18),
                      label: Text(
                        context.translate('edit_expense_button'),
                        style: AppTextStyles.bodyBold.copyWith(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.p12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.r12),
                        ),
                      ),
                    ),
                  ),
                if (showDelete)
                  ElevatedButton.icon(
                    onPressed: onDelete,
                  icon: Icon(LucideIcons.trash, color: Colors.white, size: 18),
                  label: Text(
                    context.translate('delete_expense_button'),
                    style: AppTextStyles.bodyBold.copyWith(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.activeRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.p12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.r12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
