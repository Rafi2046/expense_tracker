import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TourCreateButton extends StatelessWidget {
  final VoidCallback onPressed;

  const TourCreateButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset + 64),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: AppColors.activeGreen,
        foregroundColor: AppColors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(LucideIcons.plus, size: 28),
      ),
    );
  }
}
