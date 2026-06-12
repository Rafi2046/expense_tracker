import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileNameInputField extends StatelessWidget {
  final TextEditingController controller;

  const ProfileNameInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(
        fontSize: 16,
        color: Colors.black,
        fontFamily: GoogleFonts.workSans().fontFamily,
      ),
      decoration: InputDecoration(
        labelText: 'Your Name',
        labelStyle: TextStyle(
          color: Colors.grey.shade600,
          fontFamily: GoogleFonts.workSans().fontFamily,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.activeGreen,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.activeGreen, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
