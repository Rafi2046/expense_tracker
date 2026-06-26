import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionAmountInput extends StatelessWidget {
  final TextEditingController controller;
  final Color themeColor;
  final String currencySymbol;

  const TransactionAmountInput({
    super.key,
    required this.controller,
    required this.themeColor,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SizedBox(
        width: 260,
        child: TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.center,
          style: GoogleFonts.workSans(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: themeColor,
          ),
          decoration: InputDecoration(
            prefixText: '$currencySymbol ',
            prefixStyle: GoogleFonts.workSans(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: themeColor.withValues(alpha: 0.6),
            ),
            hintText: '0.00',
            hintStyle: GoogleFonts.workSans(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white12 : Colors.grey.shade300,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
