import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';

class ProfileSaveButton extends StatelessWidget {
  final bool isLoading;
  final bool isDark;
  final Color primaryColor;
  final Color borderColor;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const ProfileSaveButton({
    super.key,
    required this.isLoading,
    required this.isDark,
    required this.primaryColor,
    required this.borderColor,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            text: isLoading ? context.translate('saving') : context.translate('save'),
            onPressed: isLoading ? () {} : onSave,
            backgroundColor: primaryColor,
            textColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
