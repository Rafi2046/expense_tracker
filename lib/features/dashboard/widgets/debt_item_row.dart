import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';


class DebtItemRow extends StatelessWidget {
  final DebtItem item;
  final Color themeColor;
  final VoidCallback onEditTap;
  final VoidCallback? onDelete;
  final bool isMasked;

  const DebtItemRow({
    super.key,
    required this.item,
    required this.themeColor,
    required this.onEditTap,
    this.onDelete,
    this.isMasked = false,
  });

  List<Color> _avatarFgPalette(ColorScheme scheme) => [
        scheme.primary,
        scheme.secondary,
        scheme.tertiary,
        scheme.error,
        scheme.onSurfaceVariant,
      ];

  List<Color> _avatarBgPalette(ColorScheme scheme) => [
        scheme.primaryContainer,
        scheme.secondaryContainer,
        scheme.tertiaryContainer,
        scheme.errorContainer,
        scheme.surfaceContainerHighest,
      ];

  Color _getAvatarBg(BuildContext context, String name) {
    final scheme = Theme.of(context).colorScheme;
    final colors = _avatarBgPalette(scheme);
    return colors[name.hashCode.abs() % colors.length];
  }

  Color _getAvatarFg(BuildContext context, String name) {
    final scheme = Theme.of(context).colorScheme;
    final colors = _avatarFgPalette(scheme);
    return colors[name.hashCode.abs() % colors.length];
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0].runes.isNotEmpty
        ? String.fromCharCode(parts[0].runes.first).toUpperCase()
        : '';
  }

  @override
  Widget build(BuildContext context) {
    final debtProvider = context.read<DebtProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16),
        margin: const EdgeInsets.only(bottom: AppSpacing.p8),
        decoration: BoxDecoration(
          color: themeColor == scheme.error
              ? scheme.errorContainer
              : scheme.primaryContainer,
          borderRadius: BorderRadius.circular(AppSpacing.r8),
          border: Border.all(
            color: themeColor == scheme.error
                ? scheme.error.withValues(alpha: 0.35)
                : scheme.primary.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              context.translate('settle'),
              style: AppTextStyles.body.copyWith(color: themeColor,
                fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: AppSpacing.s8),
            Icon(LucideIcons.checkCircle, color: themeColor, size: 24),
          ],
        ),
      ),
      onDismissed: (direction) {
        final id = item.id;
        final name = item.name;
        Future.microtask(() => debtProvider.settleDebtItem(id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.translate('debt_settled', namedArgs: {'name': name}),
              style: TextStyle(color: scheme.onPrimary),
            ),
            backgroundColor: scheme.surfaceContainerHighest,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: context.translate('undo'),
              textColor: scheme.secondary,
              onPressed: () {
                debtProvider.toggleSettledStatus(id);
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.p8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppSpacing.r8),
          border: Border.all(
            color: theme.dividerTheme.color ?? scheme.outlineVariant,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.r8),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 3, color: themeColor),
              ),
              ListTile(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (sheetContext) => Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppSpacing.r16),
                        ),
                      ),
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(sheetContext).viewInsets.bottom +
                            MediaQuery.of(sheetContext).padding.bottom +
                            16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: AppSpacing.p12),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: scheme.outline,
                              borderRadius: BorderRadius.circular(AppSpacing.r8),
                            ),
                          ),
                          ListTile(
                            leading: Icon(
                              LucideIcons.edit,
                              color: scheme.onSurface,
                            ),
                            title: Text(
                              context.translate('edit'),
                              style: TextStyle(color: scheme.onSurface),
                            ),
                            onTap: () {
                              Navigator.pop(sheetContext);
                              onEditTap();
                            },
                          ),
                          if (onDelete != null)
                            ListTile(
                              leading: Icon(
                                LucideIcons.trash2,
                                color: scheme.error,
                              ),
                              title: Text(
                                context.translate('delete'),
                                style: TextStyle(color: scheme.error),
                              ),
                              onTap: () {
                                Navigator.pop(sheetContext);
                                onDelete?.call();
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
                contentPadding: const EdgeInsets.only(
                  left: AppSpacing.p16,
                  right: AppSpacing.p12,
                  top: AppSpacing.p4,
                  bottom: AppSpacing.p4,
                ),
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        _getAvatarBg(context, item.name),
                        _getAvatarBg(context, item.name)
                            .withValues(alpha: 0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: _getAvatarFg(context, item.name)
                          .withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _getInitials(item.name),
                    style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold,
                      color: _getAvatarFg(context, item.name),
                    ),
                  ),
                ),
                title: Text(
                  item.name,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold,
                    color: scheme.onSurface),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.w1),
                  child: Text(
                    item.detail,
                    style: AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
                trailing: PrivacyMaskedText(
                  amount: item.amount,
                  isMasked: isMasked,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold,
                    color: themeColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
