import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
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
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(context.translate('settlement_amount_label'),
                    style: AppTextStyles.cardTitle.copyWith(fontSize: AppFontSizes.size10, fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 6),
                  Text(amount,
                    style: GoogleFonts.jetBrainsMono(fontSize: AppFontSizes.size36, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        CircleAvatar(radius: 28, backgroundColor: fromColor,
                          child: Text(fromInitials, style: AppTextStyles.bodySmall.copyWith(fontSize: AppFontSizes.size14, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                        const SizedBox(height: 6),
                        Text(fromName, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                        ),
                        const SizedBox(height: 2),
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        CircleAvatar(radius: 28, backgroundColor: toColor,
                          child: Text(toInitials, style: AppTextStyles.bodySmall.copyWith(fontSize: AppFontSizes.size14, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                        const SizedBox(height: 6),
                        Text(toName, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                        ),
                        const SizedBox(height: 2),
                        Text(context.translate('receives_label'),
                          style: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: onMarkSettled,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.activeGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(context.translate('mark_as_settled'),
                    style: AppTextStyles.bodyBold.copyWith(fontSize: AppFontSizes.size15, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
