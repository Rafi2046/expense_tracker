import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_text_styles.dart';

class NotebookHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBack;

  const NotebookHeader({super.key, required this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: theme.cardColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(LucideIcons.arrowLeft, color: theme.colorScheme.onSurface),
        onPressed: onBack,
      ),
      title: Text(
        'Notebook',
        style: AppTextStyles.appbarTitle.copyWith(
          fontFamily: GoogleFonts.workSans().fontFamily,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
