import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';


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
            padding: const EdgeInsets.all(AppSpacing.p16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold,
                          color: Colors.white70,
                          letterSpacing: 1.0),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      PrivacyMaskedText(
                        amount: amount,
                        isMasked: isMasked,
                        style: AppTextStyles.displayLarge.copyWith(fontWeight: FontWeight.bold,
                          color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onToggleMask();
                      },
                      child: Icon(
                        isMasked ? LucideIcons.shield : LucideIcons.shieldOff,
                        size: 22,
                        color: Colors.white60,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s12),
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
                        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.p16),
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.p16, AppSpacing.p12, AppSpacing.p12, AppSpacing.p16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              LucideIcons.lightbulb,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: AppSpacing.s8),
                            Expanded(
                              child: Text(
                                guideText,
                                style: AppTextStyles.label.copyWith(color: Colors.white.withValues(alpha: 0.9),
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s8),
                            GestureDetector(
                              onTap: onDismissGuide,
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.p4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  LucideIcons.x,
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
