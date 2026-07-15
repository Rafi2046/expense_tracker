import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/features/dashboard/widgets/premium_header_section.dart';
import 'package:expense_tracker/features/dashboard/widgets/premium_feature_list.dart';
import 'package:expense_tracker/features/dashboard/widgets/premium_pricing_card.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

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
              children: [
                PremiumHeaderSection(
                  onClose: () => Navigator.pop(context),
                ),
                const SizedBox(height: 28),
                const PremiumFeatureList(),
                const SizedBox(height: 28),
                const PremiumPricingCard(),
                const SizedBox(height: 24),
                const _CallToActionButtons(),
              ],
            ),
          ),
        ),
      ),
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
                  SnackBar(content: Text(context.translate('premium_coming_soon'))),
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
                context.translate('upgrade_to_premium'),
                style: TextStyle(
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
            context.translate('maybe_later'),
            style: TextStyle(
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
