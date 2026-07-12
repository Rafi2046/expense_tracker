import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';

class DeleteAccountCancelLink extends StatelessWidget {
  final VoidCallback onTap;

  const DeleteAccountCancelLink({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          'Cancel',
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
