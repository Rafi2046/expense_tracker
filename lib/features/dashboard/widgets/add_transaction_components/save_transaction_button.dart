import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class SaveTransactionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isEditing;
  final bool isIncome;
  final Color backgroundColor;

  const SaveTransactionButton({
    super.key,
    required this.onPressed,
    required this.isEditing,
    required this.isIncome,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 1,
        ),
        onPressed: onPressed,
        child: Text(
          isEditing
              ? (isIncome ? 'Update Income' : 'Update Expense')
              : (isIncome ? 'Save Income' : 'Save Expense'),
          style: GoogleFonts.workSans(
            fontSize: AppFontSizes.size16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
