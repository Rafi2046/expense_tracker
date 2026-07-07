import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';

class TourStatsRow extends StatelessWidget {
  final int totalTours;
  final int totalBuddies;

  const TourStatsRow({
    super.key,
    required this.totalTours,
    required this.totalBuddies,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p20),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              isDark: isDark,
              theme: theme,
              icon: Icons.map_outlined,
              label: '$totalTours ${totalTours == 1 ? 'tour' : 'tours'}',
            ),
          ),
          const SizedBox(width: 12), // Slightly more spacing
          Expanded(
            child: _StatCard(
              isDark: isDark,
              theme: theme,
              icon: Icons.people_outline,
              label: '$totalBuddies ${totalBuddies == 1 ? 'buddy' : 'buddies'}',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final bool isDark;
  final ThemeData theme;
  final IconData icon;
  final String label;

  const _StatCard({
    required this.isDark,
    required this.theme,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // A bit more padding
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceContainerHighest : Colors.white,
        borderRadius: BorderRadius.circular(16),
        // Premium drop shadow
        boxShadow: isDark
            ? []
            : [
          BoxShadow(
            color: AppColors.activeGreen.withValues(alpha: 0.06),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.activeGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: AppColors.activeGreen,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: GoogleFonts.workSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}