import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

class SettleUpPaymentTile extends StatelessWidget {
  final ThemeData theme;
  final String fromName;
  final String toName;
  final Color fromColor;
  final Color toColor;
  final String fromInitials;
  final String toInitials;
  final String amount;
  final VoidCallback onMarkSettled;
  final VoidCallback onTap;

  const SettleUpPaymentTile({
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
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(radius: 20, backgroundColor: fromColor,
                    child: Text(fromInitials, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700, color: AppColors.white)),
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    width: 44,
                    child: Text(
                      fromName,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(fontSize: AppFontSizes.size10, fontWeight: FontWeight.w500, color: isDark ? Colors.white70 : const Color(0xFFDC3545)),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    Icon(LucideIcons.arrowLeftRight, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                    const SizedBox(height: 2),
                    Text(
                      amount,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: AppFontSizes.size16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.activeGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(radius: 20, backgroundColor: toColor,
                    child: Text(toInitials, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700, color: AppColors.white)),
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    width: 44,
                    child: Text(
                      toName,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(fontSize: AppFontSizes.size10, fontWeight: FontWeight.w500, color: AppColors.activeGreen),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              SizedBox(
                height: 36,
                child: FilledButton(
                  onPressed: onMarkSettled,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.activeGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    elevation: 0,
                  ),
                  child: Text(context.translate('settle_button'), style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700, color: AppColors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
