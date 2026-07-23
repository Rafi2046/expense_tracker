import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PrivacyToggleSection extends StatelessWidget {
  final bool isMasked;
  final VoidCallback onToggle;

  const PrivacyToggleSection({
    super.key,
    required this.isMasked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.r12),
        border: Border.all(
          color: theme.dividerTheme.color ?? (isDark ? Colors.white12 : const Color(0xFFE8EAEE)),
          width: AppSpacing.w1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: AppSpacing.s32,
            height: AppSpacing.s32,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppSpacing.r12),
            ),
            child: Icon(
              isMasked ? LucideIcons.lock : LucideIcons.lockOpen,
              size: AppSpacing.s16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
          Expanded(
            child: Text(
              context.translate(isMasked ? 'amounts_hidden' : 'amounts_visible'),
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onToggle();
            },
            child: Container(
              width: AppSpacing.s32,
              height: AppSpacing.s32,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppSpacing.r12),
              ),
              child: Icon(
                isMasked ? LucideIcons.shield : LucideIcons.shieldOff,
                size: AppSpacing.s16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
