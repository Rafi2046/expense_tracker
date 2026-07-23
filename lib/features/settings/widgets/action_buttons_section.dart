import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class ActionButtonsSection extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const ActionButtonsSection({
    super.key,
    required this.isLoading,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF1F1F1);

    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: context.translate('cancel'),
            onPressed: isLoading ? () {} : onCancel,
            backgroundColor: isDark ? theme.cardColor : Colors.white,
            textColor: theme.colorScheme.onSurface,
            showBorder: true,
            borderColor: borderColor,
          ),
        ),
        const SizedBox(width: AppSpacing.s12),
        Expanded(
          child: CustomButton(
            text: isLoading ? context.translate('saving') : context.translate('save'),
            onPressed: isLoading ? () {} : onSave,
            backgroundColor: isDark ? const Color(0xFF8E75C8) : const Color(0xFF6A53A1),
            textColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
