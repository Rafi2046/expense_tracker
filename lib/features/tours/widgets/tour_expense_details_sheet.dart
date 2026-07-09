import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/models/tour_expense.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';

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
        splitLabel = 'Split equally';
        break;
      case 'exact':
        splitLabel = 'Split by exact amounts';
        break;
      case 'percentage':
        splitLabel = 'Split by percentages';
        break;
      case 'exclusion':
        splitLabel = 'Split with exclusions';
        break;
      default:
        splitLabel = 'Split equally';
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
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
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (expense.category != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2D2D3D) : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            expense.category!,
                            style: TextStyle(
                              fontSize: 11,
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
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const Divider(indent: 24, endIndent: 24, height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _buildDetailRow(theme, 'Paid by', payerName),
                const SizedBox(height: 12),
                _buildDetailRow(theme, 'Date & Time', formattedDate),
                const SizedBox(height: 12),
                _buildDetailRow(theme, 'Split Method', splitLabel),
                if (expense.note != null && expense.note!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(theme, 'Note', expense.note!),
                ],
              ],
            ),
          ),
          if (expense.receiptPath != null) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2D2D3D) : const Color(0xFFE2E8F0),
                  ),
                ),
                clipBehavior: Clip.hardEdge,
                child: Image.file(
                  File(expense.receiptPath!),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    padding: const EdgeInsets.all(16),
                    color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF8F9FA),
                    child: Row(
                      children: [
                        Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade400),
                        const SizedBox(width: 12),
                        const Text(
                          'Receipt image path not found',
                          style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (onEdit != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                      label: const Text(
                        'Edit Expense',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                if (showDelete)
                  ElevatedButton.icon(
                    onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 18),
                  label: const Text(
                    'Delete Expense',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.activeRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
