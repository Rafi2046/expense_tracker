import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class RecentActivityDateHeader extends StatelessWidget {
  final String label;

  const RecentActivityDateHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.cardTitle,
      ),
    );
  }
}
