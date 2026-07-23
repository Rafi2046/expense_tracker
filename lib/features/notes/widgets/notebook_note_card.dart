import 'package:flutter/material.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/note_provider.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


String _formatDate(DateTime dt) {
  final months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
}

Widget _buildCategoryBadge(BuildContext context, String category) {
  final scheme = Theme.of(context).colorScheme;
  final (Color bg, Color fg) = switch (category) {
    'Business' => (scheme.primaryContainer, scheme.primary),
    'Personal' => (scheme.secondaryContainer, scheme.secondary),
    'General' => (scheme.tertiaryContainer, scheme.tertiary),
    _ => (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
  };

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p8, vertical: AppSpacing.p4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(AppSpacing.r12),
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
    final scheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16),
        margin: const EdgeInsets.only(bottom: AppSpacing.p12),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(AppSpacing.r16),
          border: Border.all(color: scheme.error.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              context.translate('swipe_to_delete'),
              style: AppTextStyles.bodyBold.copyWith(color: scheme.error),
            ),
            const SizedBox(width: AppSpacing.s8),
            Icon(LucideIcons.trash, color: scheme.error, size: 24),
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
        margin: const EdgeInsets.only(bottom: AppSpacing.p12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(AppSpacing.r16),
          border: Border.all(color: scheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: scheme.onSurface.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.r16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.p16),
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
                    const SizedBox(width: AppSpacing.s8),
                    GestureDetector(
                      onTap: () async {
                        final confirm = await onConfirmDelete();
                        if (confirm == true) {
                          onDeleted();
                        }
                      },
                      child: Icon(
                        LucideIcons.trash,
                        color: scheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  note.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    height: 1.4,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(note.createdAt),
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w400,
                        color: scheme.onSurfaceVariant,
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
