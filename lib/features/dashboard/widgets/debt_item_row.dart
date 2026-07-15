import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

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

  Color _getAvatarBg(BuildContext context, String name) {
    final hash = name.hashCode.abs();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? [
      const Color(0xFF2EBD85).withValues(alpha: 0.15),
      const Color(0xFFDC3545).withValues(alpha: 0.15),
      const Color(0xFF2980B9).withValues(alpha: 0.15),
      const Color(0xFFD35400).withValues(alpha: 0.15),
      const Color(0xFF8E44AD).withValues(alpha: 0.15),
      const Color(0xFF607D8B).withValues(alpha: 0.15),
    ] : [
      const Color(0xFFE8F8F5), // soft green
      const Color(0xFFFEE2E2), // soft red/pink
      const Color(0xFFEBF5FB), // soft blue
      const Color(0xFFFEF9E7), // soft yellow
      const Color(0xFFF3E5F5), // soft purple
      const Color(0xFFECEFF1), // soft blue-grey
    ];
    return colors[hash % colors.length];
  }

  Color _getAvatarFg(BuildContext context, String name) {
    final hash = name.hashCode.abs();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? [
      const Color(0xFF5EDCAE),
      const Color(0xFFFCA5A5),
      const Color(0xFF76B9E4),
      const Color(0xFFF5A069),
      const Color(0xFFC084FC),
      const Color(0xFF90A4AE),
    ] : [
      const Color(0xFF2EBD85),
      const Color(0xFFDC3545),
      const Color(0xFF2980B9),
      const Color(0xFFD35400),
      const Color(0xFF8E44AD),
      const Color(0xFF607D8B),
    ];
    return colors[hash % colors.length];
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0].runes.isNotEmpty ? String.fromCharCode(parts[0].runes.first).toUpperCase() : '';
  }

  @override
  Widget build(BuildContext context) {
    final debtProvider = context.read<DebtProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isDark
              ? themeColor.withValues(alpha: 0.15)
              : (themeColor == AppColors.activeRed
                  ? const Color(0xFFFEE2E2)
                  : const Color(0xFFE8F8F5)),
          borderRadius: BorderRadius.circular(AppSpacing.r8),
          border: Border.all(
            color: isDark
                ? themeColor.withValues(alpha: 0.3)
                : (themeColor == AppColors.activeRed
                    ? const Color(0xFFFCA5A5)
                    : const Color(0xFFA3E4D7)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              context.translate('settle'),
              style: TextStyle(
                color: themeColor,
                fontWeight: FontWeight.bold,
                fontSize: AppFontSizes.size14,
              ),
            ),
            const SizedBox(width: 8),
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
            content: Text(context.translate('debt_settled', namedArgs: {'name': name})),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: context.translate('undo'),
              textColor: Colors.yellow,
              onPressed: () {
                debtProvider.toggleSettledStatus(id);
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppSpacing.r8),
          border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFF0F0F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.r8),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 4, color: themeColor),
              ),
              ListTile(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (sheetContext) => Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(sheetContext).viewInsets.bottom + MediaQuery.of(sheetContext).padding.bottom + 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: theme.dividerTheme.color ?? Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          ListTile(
                            leading: Icon(LucideIcons.edit, color: theme.colorScheme.onSurface),
                            title: Text(context.translate('edit'), style: TextStyle(color: theme.colorScheme.onSurface)),
                            onTap: () {
                              Navigator.pop(sheetContext);
                              onEditTap();
                            },
                          ),
                          if (onDelete != null)
                            ListTile(
                              leading: Icon(LucideIcons.trash2, color: Colors.red.shade400),
                              title: Text(context.translate('delete'), style: TextStyle(color: Colors.red.shade400)),
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
                  left: 20,
                  right: 16,
                  top: 6,
                  bottom: 6,
                ),
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        _getAvatarBg(context, item.name),
                        _getAvatarBg(context, item.name).withValues(alpha: 0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: _getAvatarFg(context, item.name).withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _getInitials(item.name),
                    style: TextStyle(
                      fontSize: AppFontSizes.size14,
                      fontWeight: FontWeight.bold,
                      color: _getAvatarFg(context, item.name),
                    ),
                  ),
                ),
                title: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: AppFontSizes.size15,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    item.detail,
                    style: TextStyle(
                      fontSize: AppFontSizes.size13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                trailing: PrivacyMaskedText(
                  amount: item.amount,
                  isMasked: isMasked,
                  style: TextStyle(
                    fontSize: AppFontSizes.size15,
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
