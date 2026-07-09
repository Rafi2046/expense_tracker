import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/bottom_navigation/pages/bottom_nav_screen.dart';
import 'package:expense_tracker/features/onboarding/widgets/onboarding_page.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late List<_OnboardingSlide> _slides;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slides = _buildSlides();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  List<_OnboardingSlide> _buildSlides() {
    return [
      _OnboardingSlide(
        icon: Symbols.account_balance_wallet,
        iconColor: AppColors.activeGreen,
        titleKey: 'onboarding_welcome_title',
        subtitleKey: 'onboarding_welcome_subtitle',
        features: [],
      ),
      _OnboardingSlide(
        icon: Symbols.swap_vert,
        iconColor: const Color(0xFF4CAF50),
        titleKey: 'onboarding_track_title',
        subtitleKey: 'onboarding_track_subtitle',
        features: [
          OnboardingFeatureItem(
            icon: Symbols.arrow_downward,
            labelKey: 'onboarding_track_feature_income',
            color: const Color(0xFF4CAF50),
          ),
          OnboardingFeatureItem(
            icon: Symbols.arrow_upward,
            labelKey: 'onboarding_track_feature_expense',
            color: AppColors.expensePink,
          ),
          OnboardingFeatureItem(
            icon: Symbols.bolt,
            labelKey: 'onboarding_track_feature_quick',
            color: const Color(0xFFFFA726),
          ),
        ],
      ),
      _OnboardingSlide(
        icon: Symbols.group,
        iconColor: const Color(0xFF42A5F5),
        titleKey: 'onboarding_payment_title',
        subtitleKey: 'onboarding_payment_subtitle',
        features: [
          OnboardingFeatureItem(
            icon: Symbols.call_received,
            labelKey: 'onboarding_payment_feature_in',
            color: const Color(0xFF4CAF50),
          ),
          OnboardingFeatureItem(
            icon: Symbols.call_made,
            labelKey: 'onboarding_payment_feature_out',
            color: AppColors.activeRed,
          ),
        ],
      ),
      _OnboardingSlide(
        icon: Symbols.bar_chart,
        iconColor: const Color(0xFFAB47BC),
        titleKey: 'onboarding_budget_title',
        subtitleKey: 'onboarding_budget_subtitle',
        features: [
          OnboardingFeatureItem(
            icon: Symbols.savings,
            labelKey: 'onboarding_budget_feature_budget',
            color: const Color(0xFFFFA726),
          ),
          OnboardingFeatureItem(
            icon: Symbols.analytics,
            labelKey: 'onboarding_budget_feature_reports',
            color: const Color(0xFFAB47BC),
          ),
        ],
      ),
    ];
  }

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    await SharedPrefsHelper.setBool(
      SharedPrefsHelper.onboardingCompleteKey,
      true,
    );
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const BottomNavScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLastPage = _currentPage == _slides.length - 1;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.activeGreen.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.buttonColor.withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (!isLastPage)
                          TextButton(
                            onPressed: _completeOnboarding,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            child: Text(
                              context.translate('onboarding_skip'),
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return OnboardingPage(
                        icon: slide.icon,
                        iconColor: slide.iconColor,
                        title: context.translate(slide.titleKey),
                        subtitle: context.translate(slide.subtitleKey),
                        features: slide.features,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    32,
                    0,
                    32,
                    bottomPadding + 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_slides.length, (index) {
                          final isActive = index == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: isActive
                                  ? AppColors.activeGreen
                                  : (isDark
                                      ? Colors.white24
                                      : Colors.grey.shade300),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isLastPage
                                ? AppColors.activeGreen
                                : AppColors.buttonColor,
                            foregroundColor: Colors.white,
                            elevation: isLastPage ? 6 : 2,
                            shadowColor:
                                AppColors.activeGreen.withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLastPage
                                    ? context.translate(
                                        'onboarding_get_started')
                                    : context.translate('onboarding_next'),
                                style: AppTextStyles.reportTileTitle.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isLastPage
                                    ? Symbols.rocket_launch
                                    : Symbols.arrow_forward,
                                size: 18,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  final IconData icon;
  final Color iconColor;
  final String titleKey;
  final String subtitleKey;
  final List<OnboardingFeatureItem> features;

  const _OnboardingSlide({
    required this.icon,
    required this.iconColor,
    required this.titleKey,
    required this.subtitleKey,
    this.features = const [],
  });
}
