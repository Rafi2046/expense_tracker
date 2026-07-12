import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class DebtSheetHeader extends StatelessWidget {
  final String titleText;
  final VoidCallback onClose;

  const DebtSheetHeader({
    super.key,
    required this.titleText,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titleText,
          style: GoogleFonts.workSans(
            fontSize: AppFontSizes.size18,
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
    );
  }
}
