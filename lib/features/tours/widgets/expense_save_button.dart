import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';

class ExpenseSaveButton extends StatelessWidget {
  final ThemeData theme;
  final double bottomInset;
  final bool isSaving;
  final bool hasError;
  final VoidCallback onSave;

  const ExpenseSaveButton({
    super.key,
    required this.theme,
    required this.bottomInset,
    required this.isSaving,
    required this.hasError,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final canSave = !isSaving && !hasError;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.p24,
        AppSpacing.p12,
        AppSpacing.p24,
        bottomInset + AppSpacing.p12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: AppSpacing.authFieldHeight,
        child: FilledButton(
          onPressed: canSave ? onSave : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.activeGreen,
            elevation: 0,
          ),
          child: isSaving
              ? const SizedBox(
                  width: AppSpacing.s24,
                  height: AppSpacing.s24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.check, size: 20, color: Colors.white),
                    const SizedBox(width: AppSpacing.s8),
                    Text(
                      'Save Expense',
                      style: AppTextStyles.bodyBold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
