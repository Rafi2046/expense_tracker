import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

class NewTourCta extends StatelessWidget {
  final VoidCallback onTap;

  const NewTourCta({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20), // Increased height for premium feel
          decoration: BoxDecoration(
            color: isDark ? theme.colorScheme.surfaceContainer : Colors.white,
            borderRadius: BorderRadius.circular(20), // Softer, rounder corners
            // Premium elegant shadow
            boxShadow: isDark
                ? []
                : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.activeGreen.withValues(alpha: 0.25),
                      AppColors.activeGreen.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.plus,
                  size: 18,
                  color: AppColors.activeGreen,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                context.translate('create_new_tour'),
                style: AppTextStyles.reportTileTitle.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}