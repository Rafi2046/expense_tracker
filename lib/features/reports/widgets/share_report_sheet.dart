import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';

class ShareReportSheet extends StatelessWidget {
  const ShareReportSheet({super.key});

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const ShareReportSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.r24),
          topRight: Radius.circular(AppSpacing.r24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: AppSpacing.p8, bottom: AppSpacing.p8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(AppSpacing.r12),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p8),
            child: Text(
              context.translate('share_report_title'),
              style: AppTextStyles.h3.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Divider(color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1), height: 1),

          // Share Options
          ListTile(
            onTap: () => Navigator.pop(context, 'image'),
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p4),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSpacing.r8),
              ),
              child: Icon(
                LucideIcons.image,
                color: theme.primaryColor,
                size: 18,
              ),
            ),
            title: Text(
              context.translate('share_image'),
              style: AppTextStyles.bodyBold.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Divider(color: theme.dividerTheme.color ?? const Color(0xFFF8FAFC), height: 1),
          ListTile(
            onTap: () => Navigator.pop(context, 'pdf'),
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p4),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSpacing.r8),
              ),
              child: Icon(
                LucideIcons.file,
                color: theme.primaryColor,
                size: 18,
              ),
            ),
            title: Text(
              context.translate('share_pdf'),
              style: AppTextStyles.bodyBold.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
        ],
      ),
    );
  }
}
