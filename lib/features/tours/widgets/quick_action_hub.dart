import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/features/tours/widgets/join_tour_sheet.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class QuickActionHub extends StatelessWidget {
  final VoidCallback? onCreateNew;
  final VoidCallback? onJoinTour;
  final VoidCallback? onViewAll;

  const QuickActionHub({
    super.key,
    this.onCreateNew,
    this.onJoinTour,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionItem(
                icon: LucideIcons.plus,
                label: context.translate('quick_action_create'),
                onTap: () => onCreateNew?.call(),
              ),
              _divider(),
              _ActionItem(
                icon: LucideIcons.qrCode,
                label: context.translate('quick_action_join'),
                onTap: () {
                  if (onJoinTour != null) {
                    onJoinTour!();
                  } else {
                    _showJoinSheet(context);
                  }
                },
              ),
              _divider(),
              _ActionItem(
                icon: LucideIcons.grid,
                label: context.translate('view_all'),
                onTap: () => onViewAll?.call(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 24,
      color: Colors.white.withValues(alpha: 0.15),
    );
  }

  void _showJoinSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const JoinTourSheet(),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: AppColors.activeGreen),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.85)
                    : Colors.black.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
