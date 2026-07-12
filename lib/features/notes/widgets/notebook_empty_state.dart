import 'package:flutter/material.dart';
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
              isSearching ? 'No matching notes found' : 'No notes yet',
              style: AppTextStyles.h3.copyWith(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isSearching
                  ? 'Try searching for different keywords.'
                  : 'Tap the "+" button to add your business plans or general notes.',
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
