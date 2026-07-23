import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class CreateTourSubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? label;

  const CreateTourSubmitButton({super.key, required this.onPressed, this.label});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.activeGreen,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.r12)),
        elevation: 0,
      ),
      child: Text(
        label ?? context.translate('create_tour_button'),
        style: AppTextStyles.h3.copyWith(
          color: AppColors.white,
        ),
      ),
    );
  }
}
