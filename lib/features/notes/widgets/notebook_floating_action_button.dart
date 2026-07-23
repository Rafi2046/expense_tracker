import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class NotebookFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const NotebookFloatingActionButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.p48 + AppSpacing.p24),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: AppColors.activeGreen,
        elevation: 2,
        child: Icon(LucideIcons.plus, color: Colors.white, size: 28),
      ),
    );
  }
}
