import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class NotificationEmptyState extends StatelessWidget {
  const NotificationEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppImages.notifications,
              width: 220,
              height: 220,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fail-safe icon fallback if image file is not physically on disk yet
                return Icon(
                  LucideIcons.bell,
                  size: 80,
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              context.translate('no_notifications'),
              style: GoogleFonts.workSans(
                fontSize: AppFontSizes.size18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.translate('all_caught_up'),
              textAlign: TextAlign.center,
              style: GoogleFonts.workSans(
                fontSize: AppFontSizes.size14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
