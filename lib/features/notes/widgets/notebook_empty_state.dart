import 'package:flutter/material.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_text_styles.dart';

class NotebookEmptyState extends StatelessWidget {
  final bool isSearching;
  final bool isDark;

  const NotebookEmptyState({
    super.key,
    required this.isSearching,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.stickyNote, size: 64, color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              isSearching ? context.translate('no_matching_notes') : context.translate('no_notes_yet'),
              style: AppTextStyles.h3.copyWith(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isSearching
                  ? context.translate('try_searching_different_keywords')
                  : context.translate('tap_add_button_to_add_notes'),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
