import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:expense_tracker/features/settings/widgets/delete_account_cancel_link.dart';

class DeleteConfirmationBody extends StatefulWidget {
  final TextEditingController controller;
  final bool canDelete;
  final bool isDeleting;
  final VoidCallback onDelete;
  final VoidCallback onCancel;

  const DeleteConfirmationBody({
    super.key,
    required this.controller,
    required this.canDelete,
    required this.isDeleting,
    required this.onDelete,
    required this.onCancel,
  });

  @override
  State<DeleteConfirmationBody> createState() => _DeleteConfirmationBodyState();
}

class _DeleteConfirmationBodyState extends State<DeleteConfirmationBody> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFF2D2D2D) : AppColors.dividerColor;

    return Column(
      children: [
        Text(
          'Are you absolutely sure? This action cannot be undone.\n'
          'It will permanently delete your account,\n'
          'cloud backups, and all local data.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: AppFontSizes.size14,
            color: isDark ? Colors.grey.shade400 : AppColors.loginSubTitle,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Type DELETE to confirm',
          style: AppTextStyles.label.copyWith(
            color: AppColors.activeRed,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          textAlign: TextAlign.center,
          style: GoogleFonts.jetBrainsMono(
            fontSize: AppFontSizes.size18,
            fontWeight: FontWeight.w800,
            color: AppColors.activeRed,
            letterSpacing: 4,
          ),
          decoration: InputDecoration(
            hintText: 'DELETE',
            hintStyle: GoogleFonts.jetBrainsMono(
              fontSize: AppFontSizes.size18,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              letterSpacing: 4,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.canDelete ? AppColors.activeRed : borderColor,
                width: 2,
              ),
            ),
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.shade50,
            filled: true,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: widget.isDeleting ? 'Deleting...' : 'Delete',
            onPressed: widget.canDelete && !widget.isDeleting
                ? widget.onDelete
                : () {},
            backgroundColor: widget.canDelete
                ? AppColors.activeRed
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
            textColor: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        DeleteAccountCancelLink(onTap: widget.onCancel),
      ],
    );
  }
}
