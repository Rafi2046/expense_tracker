import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



class OnboardingNavigationButtons extends StatefulWidget {
  final bool isLastPage;
  final VoidCallback onPressed;

  const OnboardingNavigationButtons({
    super.key,
    required this.isLastPage,
    required this.onPressed,
  });

  @override
  State<OnboardingNavigationButtons> createState() =>
      _OnboardingNavigationButtonsState();
}

class _OnboardingNavigationButtonsState
    extends State<OnboardingNavigationButtons>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) => GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.r16),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: widget.isLastPage
                    ? [
                        const Color(0xFF22A06B),
                        AppColors.activeGreen,
                        const Color(0xFF36D399),
                      ]
                    : [
                        AppColors.activeGreen,
                        const Color(0xFF36D399),
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.activeGreen.withValues(alpha: 0.35),
                  blurRadius: widget.isLastPage ? 20 : 12,
                  spreadRadius: widget.isLastPage ? 2 : 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.r16),
              child: Stack(
                children: [
                  // Shimmer sweep
                  Positioned.fill(
                    child: _buildShimmer(),
                  ),
                  // Content
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.isLastPage
                              ? context.translate('onboarding_get_started')
                              : context.translate('onboarding_next'),
                          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3),
                        ),
                        const SizedBox(width: AppSpacing.s8),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppSpacing.r8),
                          ),
                          child: Icon(
                            widget.isLastPage
                                ? LucideIcons.rocket
                                : LucideIcons.arrowRight,
                            size: 15,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final shimmerPosition = _shimmerController.value * 2 - 0.5;
        return ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment(shimmerPosition - 0.3, 0),
            end: Alignment(shimmerPosition + 0.3, 0),
            colors: [
              Colors.transparent,
              Colors.white.withValues(alpha: 0.08),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(bounds),
          blendMode: BlendMode.srcATop,
          child: Container(
            color: Colors.white.withValues(alpha: 0.05),
          ),
        );
      },
    );
  }
}
