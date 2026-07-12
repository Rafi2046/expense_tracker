import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isEditing;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final bool isDark;

  const ProfileAppBar({
    super.key,
    required this.isEditing,
    required this.onBack,
    required this.onEdit,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: theme.cardColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(LucideIcons.arrowLeft, color: theme.colorScheme.onSurface, size: 20),
        onPressed: onBack,
      ),
      title: Text(
        isEditing ? 'Edit Profile' : 'Profile Details',
        style: AppTextStyles.h1.copyWith(color: theme.colorScheme.onSurface),
      ),
      actions: [
        if (!isEditing)
          TextButton.icon(
            onPressed: onEdit,
            icon: Icon(LucideIcons.edit, size: 16, color: isDark ? const Color(0xFF8E75C8) : const Color(0xFF6A53A1)),
            label: Text(
              'Edit',
              style: AppTextStyles.bodyBold.copyWith(
                color: isDark ? const Color(0xFF8E75C8) : const Color(0xFF6A53A1),
              ),
            ),
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF1F1F1),
          height: 1.0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1.0);
}
