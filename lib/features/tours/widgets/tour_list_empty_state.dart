import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_images.dart';

class TourListEmptyState extends StatelessWidget {
  final VoidCallback onCreateTour;

  const TourListEmptyState({super.key, required this.onCreateTour});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AppImages.tour,
                width: 200,
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.explore_rounded,
                  size: 150,
                  color: isDark
                      ? AppColors.white.withValues(alpha: 0.3)
                      : AppColors.activeGreen,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Your journey starts here',
                style: AppTextStyles.sectionHeaderTitle.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                'Create a tour to split group expenses\nseamlessly with your travel buddies.',
                textAlign: TextAlign.center,
                style: AppTextStyles.dialogBody.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onCreateTour,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Create your first tour'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.activeGreen,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 42,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}