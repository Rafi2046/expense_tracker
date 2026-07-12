import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class PartySaveButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback? onPressed;
  final Color primaryColor;
  final bool isDark;

  const PartySaveButton({
    super.key,
    required this.isEnabled,
    required this.onPressed,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: isEnabled ? onPressed : null,
              child: Text(
                'Add New Party',
                style: AppTextStyles.partySubmitButtonText.copyWith(
                  fontSize: AppFontSizes.size15,
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
