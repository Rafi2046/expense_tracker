import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';

class ProfileDialogHeader extends StatelessWidget {
  final String title;

  const ProfileDialogHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: AppTextStyles.h1.copyWith(color: Theme.of(context).colorScheme.onSurface),
    );
  }
}