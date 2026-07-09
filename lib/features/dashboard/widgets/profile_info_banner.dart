import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ProfileInfoBanner extends StatelessWidget {
  const ProfileInfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.onSurface.withValues(alpha: 0.06)
            : const Color(0xFFF4F5FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            LucideIcons.info,
            color: theme.textTheme.bodySmall?.color,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'You can also create & manage multiple profiles from the homepage later.',
              style: GoogleFonts.workSans(
                fontSize: AppFontSizes.size12,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
