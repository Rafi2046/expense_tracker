import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionSaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color themeColor;
  final String title;

  const TransactionSaveButton({
    super.key,
    required this.onPressed,
    required this.themeColor,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: themeColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 1,
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: GoogleFonts.workSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
