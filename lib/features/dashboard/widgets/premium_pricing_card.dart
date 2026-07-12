import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class PremiumPricingCard extends StatelessWidget {
  const PremiumPricingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _PricingOption(
              amount: '৳150',
              period: '/ month',
              highlighted: false,
            ),
          ),
          _Divider(),
          Expanded(
            child: _PricingOption(
              amount: '৳1,500',
              period: '/ year (save 17%)',
              highlighted: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _PricingOption extends StatelessWidget {
  final String amount;
  final String period;
  final bool highlighted;

  const _PricingOption({
    required this.amount,
    required this.period,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlighted ? const Color(0xFF2EBD85) : Colors.white;
    final periodColor = highlighted
        ? const Color(0xFF2EBD85).withValues(alpha: 0.8)
        : Colors.white.withValues(alpha: 0.6);

    return Column(
      children: [
        Text(
          amount,
          style: GoogleFonts.workSans(
            fontSize: AppFontSizes.size24,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          period,
          style: GoogleFonts.workSans(
            fontSize: AppFontSizes.size13,
            color: periodColor,
            fontWeight: highlighted ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withValues(alpha: 0.15),
    );
  }
}
