import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class PartySaveButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback? onPressed;
  final Color primaryColor;
  final bool isDark;
  final bool isEditing;

  const PartySaveButton({
    super.key,
    required this.isEnabled,
    required this.onPressed,
    required this.primaryColor,
    required this.isDark,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p12),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: MouseRegion(
          cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isEnabled
                    ? primaryColor
                    : (isDark ? Colors.white10 : const Color(0xFFF1F2F4)),
                elevation: isEnabled ? 1.5 : 0,
                shadowColor: primaryColor.withValues(alpha: 0.25),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.r12)),
              ),
              onPressed: isEnabled ? onPressed : null,
              child: Text(
                isEditing ? context.translate('edit_party') : context.translate('add_new_party'),
                style: AppTextStyles.partySubmitButtonText.copyWith(
                  color: isEnabled
                      ? Colors.white
                      : (isDark ? Colors.white30 : const Color(0xFFC1C7D0)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
