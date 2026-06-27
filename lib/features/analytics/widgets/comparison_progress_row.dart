import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ComparisonProgressRow extends StatelessWidget {
  final String label;
  final double amount;
  final double progress;
  final Color progressColor;
  final bool isMasked;

  const ComparisonProgressRow({
    super.key,
    required this.label,
    required this.amount,
    required this.progress,
    required this.progressColor,
    this.isMasked = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.workSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white60 : const Color(0xFF4A5568),
              ),
            ),
            PrivacyMaskedText(
              amount: amount,
              isMasked: isMasked,
              style: GoogleFonts.workSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark ? Colors.grey.shade800 : const Color(0xFFF0F0F0),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
