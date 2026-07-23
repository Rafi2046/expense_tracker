import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class RecentActivityDateHeader extends StatelessWidget {
  final String label;

  const RecentActivityDateHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.p4, bottom: AppSpacing.p4),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.cardTitle,
      ),
    );
  }
}
