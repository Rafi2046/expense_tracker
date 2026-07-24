import 'package:flutter/material.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/constants/app_images.dart';
import '../../../core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


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
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 220,
              height: 220,
              child: Image.asset(
                AppImages.noNotesIcon,
                width: 220,
                height: 220,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              isSearching
                  ? context.translate('no_matching_notes')
                  : context.translate('no_notes_yet'),
              style: AppTextStyles.h3.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              isSearching
                  ? context.translate('try_searching_different_keywords')
                  : context.translate('tap_add_button_to_add_notes'),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
