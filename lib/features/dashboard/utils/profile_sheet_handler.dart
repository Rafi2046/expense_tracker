import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/providers/profile_provider.dart';

mixin ProfileSheetHandler<T extends StatefulWidget> on State<T> {
  TextEditingController get nameController;
  String get profileId;

  Future<void> confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Delete Profile?',
            style: TextStyle(
              fontSize: AppFontSizes.size18,
              fontWeight: FontWeight.w800,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          content: Text(
            'Are you sure? All data in this profile will be permanently lost.',
            style: TextStyle(
              fontSize: AppFontSizes.size14,
              color: theme.textTheme.bodySmall?.color,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'Delete',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFDC3545),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      final provider = context.read<ProfileProvider>();
      await provider.deleteProfile(profileId);

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> saveName() async {
    final newName = nameController.text.trim();
    if (newName.isEmpty) {
      if (!mounted) return;
      Navigator.pop(context);
      return;
    }

    final provider = context.read<ProfileProvider>();
    await provider.updateProfileName(profileId, newName);
    if (mounted) {
      Navigator.pop(context);
    }
  }
}
