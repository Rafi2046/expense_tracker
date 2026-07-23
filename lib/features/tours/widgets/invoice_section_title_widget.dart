import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';


class InvoiceSectionTitleWidget extends StatelessWidget {
  final String title;

  const InvoiceSectionTitleWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.caption.copyWith(fontFamily: GoogleFonts.jetBrainsMono().fontFamily, fontWeight: FontWeight.w700,
        color: const Color(0xFF9CA3AF),
        letterSpacing: 2,
      ),
    );
  }
}
