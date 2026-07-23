import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';


class PartySelectorTile extends StatelessWidget {
  final String? selectedPartyName;
  final Color themeColor;
  final VoidCallback onClear;
  final VoidCallback onTap;

  const PartySelectorTile({
    super.key,
    required this.selectedPartyName,
    required this.themeColor,
    required this.onClear,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasValue = selectedPartyName != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.p16,
          vertical: AppSpacing.p16,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.onSurface.withValues(alpha: 0.04)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(AppSpacing.r16),
          border: Border.all(
            color: isDark
                ? theme.colorScheme.onSurface.withValues(alpha: 0.08)
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: hasValue
                    ? themeColor.withValues(alpha: isDark ? 0.15 : 0.08)
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(AppSpacing.br12),
              ),
              child: Icon(
                LucideIcons.users,
                size: 19,
                color: hasValue
                    ? themeColor
                    : (isDark ? Colors.white30 : Colors.grey.shade400),
              ),
            ),
            const SizedBox(width: AppSpacing.w16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.translate('party'),
                    style: AppTextStyles.caption.copyWith(color: isDark ? Colors.white38 : Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    selectedPartyName ?? context.translate('link_to_party_optional'),
                    style: AppTextStyles.body.copyWith(fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                      color: hasValue
                          ? theme.colorScheme.onSurface
                          : (isDark ? Colors.white24 : Colors.grey.shade400),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(AppSpacing.br8),
              ),
              child: hasValue
                  ? GestureDetector(
                      onTap: onClear,
                      child: Icon(
                        LucideIcons.x,
                        size: 14,
                        color: isDark ? Colors.white38 : Colors.grey.shade500,
                      ),
                    )
                  : Icon(
                      LucideIcons.arrowRight,
                      size: 14,
                      color: isDark ? Colors.white30 : Colors.grey.shade400,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
