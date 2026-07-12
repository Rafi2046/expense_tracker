import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

class TourCardStatusBadge extends StatelessWidget {
  final bool isCompleted;

  const TourCardStatusBadge({
    super.key,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = isCompleted ? const Color(0xFF9CA3AF) : const Color(0xFF4ADE80);
    final label = isCompleted ? context.translate('completed') : context.translate('active');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isCompleted ? 0.1 : 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: isCompleted ? 0.12 : 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: isCompleted ? 0.6 : 0.9),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
