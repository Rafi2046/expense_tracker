import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class OverallBalanceCard extends StatelessWidget {
  final double totalBalance;
  final bool isMasked;
  final VoidCallback onToggleMask;

  const OverallBalanceCard({
    super.key,
    required this.totalBalance,
    required this.isMasked,
    required this.onToggleMask,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0C4E3C), Color(0xFF1E8262)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C4E3C).withValues(alpha: 0.18),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Overall Account Balance',
                  style: GoogleFonts.workSans(
                    fontSize: AppFontSizes.size12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onToggleMask();
                },
                child: Icon(
                  isMasked ? Symbols.visibility_off : Symbols.visibility,
                  size: 18,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          PrivacyMaskedText(
            amount: totalBalance,
            isMasked: isMasked,
            style: GoogleFonts.workSans(
              fontSize: AppFontSizes.size24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
