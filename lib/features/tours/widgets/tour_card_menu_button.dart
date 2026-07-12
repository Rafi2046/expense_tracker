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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final markActiveLabel = context.translate('mark_as_active', listen: false);
    final markCompletedLabel = context.translate('mark_as_completed', listen: false);
    final deleteLabel = context.translate('delete_tour', listen: false);

    final greyColor = isDark ? Colors.white70 : const Color(0xFF6B7280);
    final greenColor = const Color(0xFF4ADE80);
    final redColor = const Color(0xFFEF4444);

    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onSelected: (value) {
        if (value == 'toggleComplete') onToggleComplete?.call();
        if (value == 'delete') onDelete?.call();
      },
      itemBuilder: (_) => [
        if (onToggleComplete != null)
          PopupMenuItem(
            value: 'toggleComplete',
            child: Row(
              children: [
                Icon(
                  isCompleted ? LucideIcons.circle : LucideIcons.checkCircle,
                  size: 18,
                  color: isCompleted ? greyColor : greenColor,
                ),
                const SizedBox(width: 8),
                Text(
                  isCompleted ? markActiveLabel : markCompletedLabel,
                  style: TextStyle(
                    color: isCompleted ? greyColor : greenColor,
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
                Icon(LucideIcons.trash, size: 18, color: redColor),
                const SizedBox(width: 8),
                Text(deleteLabel,
                    style: TextStyle(color: redColor)),
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
