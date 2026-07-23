import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class SettleUpPaymentMethodSelector extends StatelessWidget {
  final ThemeData theme;
  final String fromName;
  final String toName;
  final Color fromColor;
  final Color toColor;
  final String fromInitials;
  final String toInitials;
  final String amount;
  final VoidCallback onMarkSettled;

  const SettleUpPaymentMethodSelector({
    super.key,
    required this.theme,
    required this.fromName,
    required this.toName,
    required this.fromColor,
    required this.toColor,
    required this.fromInitials,
    required this.toInitials,
    required this.amount,
    required this.onMarkSettled,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.r24),
          topRight: Radius.circular(AppSpacing.r24),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(top: AppSpacing.p12, bottom: AppSpacing.p16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.r8),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.p16),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.p16, horizontal: AppSpacing.p24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.r16),
              ),
              child: Column(
                children: [
                  Text(context.translate('settlement_amount_label'),
                    style: AppTextStyles.cardTitle.copyWith( fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Text(amount,
                    style: AppTextStyles.displayLarge.copyWith(fontFamily: GoogleFonts.jetBrainsMono().fontFamily, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        CircleAvatar(radius: 28, backgroundColor: fromColor,
                          child: Text(fromInitials, style: AppTextStyles.bodySmall.copyWith( fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        Text(fromName, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        Text(context.translate('pays_label'),
                          style: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.activeGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(LucideIcons.arrowRight, color: AppColors.activeGreen, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.s16),
                  Expanded(
                    child: Column(
                      children: [
                        CircleAvatar(radius: 28, backgroundColor: toColor,
                          child: Text(toInitials, style: AppTextStyles.bodySmall.copyWith( fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        Text(toName, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        Text(context.translate('receives_label'),
                          style: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: onMarkSettled,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.activeGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.r12)),
                    elevation: 0,
                  ),
                  child: Text(context.translate('mark_as_settled'),
                    style: AppTextStyles.bodyBold.copyWith( color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
          ],
        ),
      ),
    );
  }
}
