import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class PremiumUpgradeSheet extends StatelessWidget {
  const PremiumUpgradeSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PremiumUpgradeSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                _PremiumHeader(),
                SizedBox(height: 28),
                _FeatureList(),
                SizedBox(height: 28),
                _PricingSection(),
                SizedBox(height: 24),
                _CallToActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumHeader extends StatelessWidget {
  const _PremiumHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Symbols.close,
              color: Colors.white.withValues(alpha: 0.6),
              size: 24,
            ),
          ),
        ),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF2EBD85), Color(0xFF1A8C5E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2EBD85).withValues(alpha: 0.4),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(
            Symbols.diamond_rounded,
            color: Colors.white,
            size: 40,
            weight: 400,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Go Premium',
          style: GoogleFonts.workSans(
            fontSize: AppFontSizes.size28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Unlock the full power of your finance tracker',
          style: GoogleFonts.workSans(
            fontSize: AppFontSizes.size14,
            color: Colors.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _FeatureList extends StatelessWidget {
  const _FeatureList();

  static const _features = [
    (Symbols.group_add_rounded, 'Unlimited Profiles'),
    (Symbols.analytics_rounded, 'Advanced Analytics & Reports'),
    (Symbols.description_rounded, 'Export PDF Reports'),
    (Symbols.cloud_sync_rounded, 'Priority Cloud Sync'),
    (Symbols.support_agent_rounded, 'Priority Support'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _features
          .map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _FeatureItem(icon: f.$1, text: f.$2),
            ),
          )
          .toList(),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF2EBD85).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF2EBD85), size: 18),
        ),
        const SizedBox(width: 14),
        Text(
          text,
          style: GoogleFonts.workSans(
            fontSize: AppFontSizes.size15,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}

class _PricingSection extends StatelessWidget {
  const _PricingSection();

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

class _CallToActionButtons extends StatelessWidget {
  const _CallToActionButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2EBD85), Color(0xFF1A8C5E)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2EBD85).withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Premium coming soon!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Upgrade to Premium',
                style: GoogleFonts.workSans(
                  fontSize: AppFontSizes.size18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Maybe Later',
            style: GoogleFonts.workSans(
              fontSize: AppFontSizes.size14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }
}
