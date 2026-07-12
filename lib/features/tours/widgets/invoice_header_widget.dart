import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';

class InvoiceHeaderWidget extends StatelessWidget {
  final String tourName;
  final String formattedDate;
  final String currency;

  const InvoiceHeaderWidget({
    super.key,
    required this.tourName,
    required this.formattedDate,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'INVOICE',
              style: GoogleFonts.jetBrainsMono(
                fontSize: AppFontSizes.size10,
                fontWeight: FontWeight.w800,
                color: AppColors.activeGreen,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              tourName,
              style: AppTextStyles.displayLarge.copyWith(
                letterSpacing: -0.5,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formattedDate,
              style: AppTextStyles.caption.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              currency,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
