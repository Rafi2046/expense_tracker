import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/models/tour_expense.dart';
import 'package:expense_tracker/features/tours/widgets/full_screen_image_viewer.dart';
import 'package:expense_tracker/features/tours/widgets/invoice_format_utils.dart';
import 'package:expense_tracker/features/tours/widgets/tour_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class InvoiceReceiptsGridWidget extends StatelessWidget {
  final List<TourExpense> expenses;
  final bool isDark;

  const InvoiceReceiptsGridWidget({
    super.key,
    required this.expenses,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final allPaths = <String>[];
    final expenseMap = <String, TourExpense>{};
    for (final e in expenses) {
      for (final p in e.receiptPaths) {
        if (p.isEmpty) continue;
        // Include Base64 / network / existing legacy files; skip unusable values.
        if (TourImageResolver.provider(p) == null) continue;
        allPaths.add(p);
        expenseMap[p] = e;
      }
    }
    if (allPaths.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (var i = 0; i < allPaths.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _ReceiptCard(
                    path: allPaths[i],
                    expense: expenseMap[allPaths[i]]!,
                    allPaths: allPaths,
                    index: i,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                if (i + 1 < allPaths.length)
                  Expanded(
                    child: _ReceiptCard(
                      path: allPaths[i + 1],
                      expense: expenseMap[allPaths[i + 1]]!,
                      allPaths: allPaths,
                      index: i + 1,
                      isDark: isDark,
                    ),
                  )
                else
                  const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
      ],
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  final String path;
  final TourExpense expense;
  final List<String> allPaths;
  final int index;
  final bool isDark;

  const _ReceiptCard({
    required this.path,
    required this.expense,
    required this.allPaths,
    required this.index,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final errorPlaceholder = Container(
      height: 180,
      color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
      child: Center(
        child: Icon(
          LucideIcons.imageOff,
          color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB),
          size: 36,
        ),
      ),
    );

    return GestureDetector(
      onTap: () => FullScreenImageViewer.show(context, allPaths, index: index),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF2D2D3D) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
              child: TourImage(
                source: path,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => errorPlaceholder,
                placeholder: errorPlaceholder,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatShortDate(expense.date),
                    style: AppTextStyles.caption.copyWith(
                      fontSize: AppFontSizes.size10,
                      color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                    ),
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
