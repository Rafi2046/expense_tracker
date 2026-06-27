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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  themeColor.withValues(alpha: 0.08),
                  themeColor.withValues(alpha: 0.03),
                ]
              : [
                  themeColor.withValues(alpha: 0.04),
                  themeColor.withValues(alpha: 0.015),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: themeColor.withValues(alpha: isDark ? 0.15 : 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // ── "Amount" floating label ──
          Text(
            'AMOUNT',
            style: GoogleFonts.workSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: themeColor.withValues(alpha: 0.5),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),

          // ── The actual input ──
          Center(
            child: IntrinsicWidth(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  // Currency prefix
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      currencySymbol,
                      style: GoogleFonts.workSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: themeColor.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                  // Amount field
                  IntrinsicWidth(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 80, maxWidth: 220),
                      child: TextFormField(
                        controller: controller,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.workSans(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: themeColor,
                          letterSpacing: -1,
                        ),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: GoogleFonts.workSans(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.grey.shade200,
                            letterSpacing: -1,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
