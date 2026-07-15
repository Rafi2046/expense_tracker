import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/features/tours/widgets/join_tour_sheet.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TourListEmptyState extends StatelessWidget {
  final VoidCallback onCreateTour;
  final VoidCallback? onJoinTour;

  const TourListEmptyState({
    super.key,
    required this.onCreateTour,
    this.onJoinTour,
  });

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
                  LucideIcons.compass,
                  size: 150,
                  color: isDark
                      ? AppColors.white.withValues(alpha: 0.3)
                      : AppColors.activeGreen,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                context.translate('your_journey_starts'),
                style: AppTextStyles.sectionHeaderTitle.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                context.translate('journey_description'),
                textAlign: TextAlign.center,
                style: AppTextStyles.dialogBody.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onCreateTour,
                icon: Icon(LucideIcons.plus, size: 20),
                label: Text(context.translate('create_first_tour')),
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
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onJoinTour ?? () => _showJoinSheet(context),
                icon: Icon(LucideIcons.qrCode, size: 18),
                label: Text(context.translate('join_invite_code')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.activeGreen,
                  side: BorderSide(
                    color: AppColors.activeGreen.withValues(alpha: 0.3),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 42,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
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
