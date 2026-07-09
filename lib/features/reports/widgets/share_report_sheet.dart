import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';

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
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
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
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
            child: Text(
              'Share Report',
              style: AppTextStyles.h3.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Divider(color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1), height: 1),

          // Share Options
          ListTile(
            onTap: () => Navigator.pop(context, 'image'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Symbols.image,
                color: theme.primaryColor,
                size: 18,
              ),
            ),
            title: Text(
              'Share Image',
              style: AppTextStyles.bodyBold.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Divider(color: theme.dividerTheme.color ?? const Color(0xFFF8FAFC), height: 1),
          ListTile(
            onTap: () => Navigator.pop(context, 'pdf'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Symbols.picture_as_pdf,
                color: theme.primaryColor,
                size: 18,
              ),
            ),
            title: Text(
              'Share PDF',
              style: AppTextStyles.bodyBold.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
