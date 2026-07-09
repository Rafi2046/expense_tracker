import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/features/tours/widgets/join_tour_sheet.dart';

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
      child: Row(
        children: [
          _ActionPill(
            icon: Icons.add_rounded,
            label: 'Create',
            isDark: isDark,
            onTap: onCreateNew ?? () {},
          ),
          const SizedBox(width: 10),
          _ActionPill(
            icon: Icons.qr_code_scanner_rounded,
            label: 'Join',
            isDark: isDark,
            onTap: onJoinTour ?? () => _showJoinSheet(context),
          ),
          const SizedBox(width: 10),
          _ActionPill(
            icon: Icons.grid_view_rounded,
            label: 'View All',
            isDark: isDark,
            onTap: onViewAll ?? () {},
          ),
        ],
      ),
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

class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionPill({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppColors.activeGreen.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.activeGreen.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: AppColors.activeGreen),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.workSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.8)
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
