import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class AdditionalDetailsForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController addressController;
  final TextEditingController vatController;

  const AdditionalDetailsForm({
    super.key,
    required this.emailController,
    required this.addressController,
    required this.vatController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Party Email
        TextFormField(
          controller: emailController,
          style: AppTextStyles.partyFormInput,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Party Email',
            hintStyle: AppTextStyles.partyFormHint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade100),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.activeGreen,
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Party Address
        TextFormField(
          controller: addressController,
          style: AppTextStyles.partyFormInput,
          decoration: InputDecoration(
            hintText: 'Party Address',
            hintStyle: AppTextStyles.partyFormHint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade100),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.activeGreen,
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // VAT Number
        TextFormField(
          controller: vatController,
          style: AppTextStyles.partyFormInput,
          decoration: InputDecoration(
            hintText: 'VAT Number',
            hintStyle: AppTextStyles.partyFormHint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade100),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.activeGreen,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
