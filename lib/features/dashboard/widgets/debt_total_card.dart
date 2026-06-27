import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';

class DebtTotalCard extends StatelessWidget {
  final String title;
  final double amount;
  final List<Color> gradientColors;
  final String guideText;
  final bool showGuide;
  final VoidCallback onDismissGuide;
  final IconData cardIcon;
  final bool isMasked;
  final VoidCallback onToggleMask;

  const DebtTotalCard({
    super.key,
    required this.title,
    required this.amount,
    required this.gradientColors,
    required this.guideText,
    required this.showGuide,
    required this.onDismissGuide,
    required this.cardIcon,
    required this.isMasked,
    required this.onToggleMask,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.r16),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      PrivacyMaskedText(
                        amount: amount,
                        isMasked: isMasked,
                        style: GoogleFonts.workSans(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onToggleMask();
                      },
                      child: Icon(
                        isMasked ? Symbols.visibility_off : Symbols.visibility,
                        size: 22,
                        color: Colors.white60,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Icon(
                      cardIcon,
                      color: Colors.white.withValues(alpha: 0.15),
                      size: 42,
                    ),
                  ],
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: showGuide
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 12, 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Symbols.lightbulb_outline_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                guideText,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: onDismissGuide,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Symbols.close_rounded,
                                  color: Colors.white70,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
