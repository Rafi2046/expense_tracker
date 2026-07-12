import 'package:flutter/material.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TourCardMenuButton extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleComplete;

  const TourCardMenuButton({
    super.key,
    required this.isCompleted,
    this.onDelete,
    this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onSelected: (value) {
        if (value == 'toggleComplete') onToggleComplete?.call();
        if (value == 'delete') onDelete?.call();
      },
      itemBuilder: (context) => [
        if (onToggleComplete != null)
          PopupMenuItem(
            value: 'toggleComplete',
            child: Row(
              children: [
                Icon(
                  isCompleted ? LucideIcons.circle : LucideIcons.checkCircle,
                  size: 18,
                  color: isCompleted ? const Color(0xFF6B7280) : const Color(0xFF4ADE80),
                ),
                const SizedBox(width: 8),
                Text(
                  isCompleted ? context.translate('mark_as_active') : context.translate('mark_as_completed'),
                  style: TextStyle(
                    color: isCompleted ? const Color(0xFF6B7280) : const Color(0xFF4ADE80),
                  ),
                ),
              ],
            ),
          ),
        if (onDelete != null)
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                const Icon(LucideIcons.trash, size: 18, color: Color(0xFFDC2626)),
                const SizedBox(width: 8),
                Text(context.translate('delete_tour'),
                    style: const TextStyle(color: Color(0xFFDC2626))),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        child: const Icon(
          LucideIcons.moreHorizontal,
          size: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}
