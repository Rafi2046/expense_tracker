import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';

class NotebookFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const NotebookFloatingActionButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 72),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: AppColors.activeGreen,
        elevation: 2,
        child: Icon(LucideIcons.plus, color: Colors.white, size: 28),
      ),
    );
  }
}
