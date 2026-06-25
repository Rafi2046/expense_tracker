import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FinancialHealthBanner extends StatelessWidget {
  const FinancialHealthBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -20,
            right: -20,
            child: Icon(
              Icons.trending_up_rounded,
              color: Colors.white.withValues(alpha: 0.08),
              size: 140,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Financial Health',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: GoogleFonts.workSans().fontFamily,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your income has increased by 8% this quarter.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontFamily: GoogleFonts.workSans().fontFamily,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
