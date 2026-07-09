import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class InlineGoogleNotice extends StatelessWidget {
  const InlineGoogleNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor, width: 1.0),
          ),
          child: Column(
            children: [
              Icon(
                Symbols.g_mobiledata_rounded,
                color: theme.primaryColor,
                size: 36,
              ),
              const SizedBox(height: 8),
              Text(
                'Google Sign-in Active',
                style: GoogleFonts.workSans(
                  fontSize: AppFontSizes.size14,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your account password is managed securely by Google. You cannot change your Google account credentials inside this app.',
                textAlign: TextAlign.center,
                style: GoogleFonts.workSans(
                  fontSize: AppFontSizes.size12,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
