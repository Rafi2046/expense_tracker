import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/note_provider.dart';

String _formatDate(DateTime dt) {
  final months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
}

Widget _buildCategoryBadge(BuildContext context, String category) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  Color bg = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF1EFF5);
  Color fg = isDark ? Colors.white70 : Colors.black87;

  if (category == 'Business') {
    bg = isDark ? const Color(0xFF10B981).withValues(alpha: 0.15) : const Color(0xFFE8F8F5);
    fg = isDark ? const Color(0xFF10B981) : AppColors.activeGreen;
  } else if (category == 'Personal') {
    bg = isDark ? Colors.blue.withValues(alpha: 0.15) : const Color(0xFFEBF5FB);
    fg = isDark ? Colors.blue.shade400 : Colors.blue.shade700;
  } else if (category == 'General') {
    bg = isDark ? Colors.orange.withValues(alpha: 0.15) : const Color(0xFFFEF9E7);
    fg = isDark ? Colors.orange.shade400 : Colors.orange.shade800;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      category,
      style: AppTextStyles.caption.copyWith(
        fontWeight: FontWeight.w600,
        color: fg,
      ),
    ),
  );
}

class NotebookNoteCard extends StatelessWidget {
  final NoteItem note;
  final int index;
  final VoidCallback onTap;
  final Future<bool?> Function() onConfirmDelete;
  final VoidCallback onDeleted;
  final bool isDark;
  final Color cardColor;
  final Color onSurfaceColor;

  const NotebookNoteCard({
    super.key,
    required this.note,
    required this.index,
    required this.onTap,
    required this.onConfirmDelete,
    required this.onDeleted,
    required this.isDark,
    required this.cardColor,
    required this.onSurfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.red.withValues(alpha: 0.1) : const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFFCA5A5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Swipe to delete',
              style: AppTextStyles.bodyBold.copyWith(
                color: isDark ? Colors.red.shade400 : const Color(0xFFB91C1C),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              LucideIcons.trash,
              color: isDark ? Colors.red.shade400 : const Color(0xFFB91C1C),
              size: 24,
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await onConfirmDelete();
      },
      onDismissed: (direction) {
        onDeleted();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF0F0F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: FontWeight.bold,
                          color: onSurfaceColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () async {
                        final confirm = await onConfirmDelete();
                        if (confirm == true) {
                          onDeleted();
                        }
                      },
                      child: Icon(
                        LucideIcons.trash,
                        color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  note.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    height: 1.4,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(note.createdAt),
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w400,
                        color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                      ),
                    ),
                    _buildCategoryBadge(context, note.category),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
