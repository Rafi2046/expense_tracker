import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class AdjustBalanceHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const AdjustBalanceHeader({
    super.key,
    required this.title,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      children: [
        Center(
          child: Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.workSans(
                fontSize: AppFontSizes.size16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            IconButton(
              icon: Icon(
                LucideIcons.x,
                color: theme.colorScheme.onSurface,
              ),
              onPressed: onClose,
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
