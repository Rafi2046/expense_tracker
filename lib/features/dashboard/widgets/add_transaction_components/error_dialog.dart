import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorDialog extends StatelessWidget {
  final String message;

  const ErrorDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Symbols.error_outline, color: AppColors.activeRed),
          const SizedBox(width: AppSpacing.w8),
          Text(
            'Missing Info',
            style: GoogleFonts.workSans(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      content: Text(message, style: GoogleFonts.workSans(fontSize: 16)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'OK',
            style: GoogleFonts.workSans(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
