import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalculatorLegendItem extends StatelessWidget {
  final String label;
  final Color color;
  final double ratio;

  const CalculatorLegendItem({
    super.key,
    required this.label,
    required this.color,
    required this.ratio,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label (${(ratio * 100).toStringAsFixed(0)}%)',
          style: GoogleFonts.workSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
