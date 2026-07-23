import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/tours/widgets/full_screen_image_viewer.dart';
import 'package:expense_tracker/features/tours/widgets/tour_image.dart';

class ExpenseReceiptPicker extends StatelessWidget {
  final ThemeData theme;
  final List<String> receiptPaths;
  final VoidCallback onPick;
  final void Function(int index) onClear;

  const ExpenseReceiptPicker({
    super.key,
    required this.theme,
    required this.receiptPaths,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (receiptPaths.isEmpty) return _buildAddButton(context);

    return Wrap(
      spacing: AppSpacing.s8,
      runSpacing: AppSpacing.s8,
      alignment: WrapAlignment.start,
      runAlignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        for (var i = 0; i < receiptPaths.length; i++)
          _buildThumbnail(context, i),
        _buildGridAddButton(context),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: onPick,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.p16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.r16),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.receipt, size: 18,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            const SizedBox(width: AppSpacing.s8),
            Text(
              context.translate('add_receipt'),
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridAddButton(BuildContext context) {
    return GestureDetector(
      onTap: onPick,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.r16),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.plus, size: 22,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.25)),
            const SizedBox(height: AppSpacing.h4),
            Text(
              context.translate('add'),
              style: AppTextStyles.caption.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context, int index) {
    return GestureDetector(
      onTap: () => FullScreenImageViewer.show(context, receiptPaths, index: index),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.r12),
            child: TourImage(
              source: receiptPaths[index],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppSpacing.r12),
                ),
                child: Icon(LucideIcons.imageOff, size: 28,
                    color: Colors.grey.shade400),
              ),
              placeholder: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppSpacing.r12),
                ),
                child: Icon(LucideIcons.imageOff, size: 28,
                    color: Colors.grey.shade400),
              ),
            ),
          ),
          Positioned(
            top: AppSpacing.s4,
            right: AppSpacing.s4,
            child: GestureDetector(
              onTap: () => onClear(index),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.p4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.x, size: 10, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
