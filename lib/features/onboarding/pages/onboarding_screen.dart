import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/bottom_navigation/pages/bottom_nav_screen.dart';
import 'package:expense_tracker/features/onboarding/widgets/onboarding_page.dart';
import 'package:expense_tracker/features/onboarding/widgets/onboarding_page_indicator.dart';
import 'package:expense_tracker/features/onboarding/widgets/onboarding_navigation_buttons.dart';
import 'package:expense_tracker/features/onboarding/widgets/onboarding_skip_button.dart';
import 'package:expense_tracker/features/onboarding/widgets/onboarding_theme_picker.dart';
import 'package:expense_tracker/features/onboarding/widgets/onboarding_language_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
  static const int _totalSlides = 6;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _bgFloatController;

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

    // Slow floating animation for background orbs
    _bgFloatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _bgFloatController.dispose();
    super.dispose();
  }

  List<_OnboardingSlide> _buildSlides() {
    return [
      _OnboardingSlide(
        icon: LucideIcons.sparkles,
        iconColor: AppColors.activeGreen,
        titleKey: 'onboarding_welcome_title',
        subtitleKey: 'onboarding_welcome_subtitle',
        features: [],
      ),
      _OnboardingSlide(
        icon: LucideIcons.arrowDownUp,
        iconColor: const Color(0xFF4CAF50),
        titleKey: 'onboarding_track_title',
        subtitleKey: 'onboarding_track_subtitle',
        features: [
          OnboardingFeatureItem(
            icon: LucideIcons.trendingUp,
            labelKey: 'onboarding_track_feature_income',
            color: const Color(0xFF4CAF50),
          ),
          OnboardingFeatureItem(
            icon: LucideIcons.trendingDown,
            labelKey: 'onboarding_track_feature_expense',
            color: AppColors.expensePink,
          ),
          OnboardingFeatureItem(
            icon: LucideIcons.zap,
            labelKey: 'onboarding_track_feature_quick',
            color: const Color(0xFFFFA726),
          ),
        ],
      ),
      _OnboardingSlide(
        icon: LucideIcons.usersRound,
        iconColor: const Color(0xFF42A5F5),
        titleKey: 'onboarding_tour_title',
        subtitleKey: 'onboarding_tour_subtitle',
        features: [
          OnboardingFeatureItem(
            icon: LucideIcons.split,
            labelKey: 'onboarding_tour_feature_split',
            color: const Color(0xFF42A5F5),
          ),
          OnboardingFeatureItem(
            icon: LucideIcons.handshake,
            labelKey: 'onboarding_tour_feature_settle',
            color: const Color(0xFF2EBD85),
          ),
          OnboardingFeatureItem(
            icon: LucideIcons.layoutGrid,
            labelKey: 'onboarding_tour_feature_multi',
            color: const Color(0xFFFFA726),
          ),
        ],
      ),
      _OnboardingSlide(
        icon: LucideIcons.chartNoAxesCombined,
        iconColor: const Color(0xFFAB47BC),
        titleKey: 'onboarding_budget_title',
        subtitleKey: 'onboarding_budget_subtitle',
        features: [
          OnboardingFeatureItem(
            icon: LucideIcons.piggyBank,
            labelKey: 'onboarding_budget_feature_budget',
            color: const Color(0xFFFFA726),
          ),
          OnboardingFeatureItem(
            icon: LucideIcons.pieChart,
            labelKey: 'onboarding_budget_feature_reports',
            color: const Color(0xFFAB47BC),
          ),
        ],
      ),
    ];
  }

  void _onNext() {
    if (_currentPage < _totalSlides - 1) {
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

  // Get the accent color for current page to tint background orbs
  Color get _currentAccentColor {
    if (_currentPage < _slides.length) {
      return _slides[_currentPage].iconColor;
    }
    return AppColors.activeGreen;
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _totalSlides - 1;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // ─── Animated Background Orbs ───
            AnimatedBuilder(
              animation: _bgFloatController,
              builder: (context, child) {
                final floatValue = _bgFloatController.value;
                return Stack(
                  children: [
                    // Top-right orb (large, follows page accent color)
                    Positioned(
                      top: -100 + (floatValue * 20),
                      right: -80 - (floatValue * 15),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _currentAccentColor.withValues(
                                  alpha: isDark ? 0.12 : 0.08),
                              _currentAccentColor.withValues(
                                  alpha: isDark ? 0.04 : 0.02),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Bottom-left orb
                    Positioned(
                      bottom: -60 - (floatValue * 15),
                      left: -60 + (floatValue * 10),
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFAB47BC).withValues(
                                  alpha: isDark ? 0.1 : 0.06),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Center-left accent orb (new — adds depth)
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.35,
                      left: -120 + (floatValue * 25),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _currentAccentColor.withValues(
                                  alpha: isDark ? 0.06 : 0.04),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            // ─── Main Content ───
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
                          OnboardingSkipButton(
                            onSkip: _completeOnboarding,
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _totalSlides,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(flex: 2),
                            Image.asset(
                              AppImages.onboardingLogo,
                              width: 160,
                              height: 160,
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'Welcome to BudgetMint',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                'Your all-in-one companion to track daily expenses, manage budgets, and split tour bills effortlessly.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const Spacer(flex: 3),
                          ],
                        );
                      } else if (index < 4) {
                        final slide = _slides[index];
                        return OnboardingPage(
                          icon: slide.icon,
                          iconColor: slide.iconColor,
                          title: context.translate(slide.titleKey),
                          subtitle: context.translate(slide.subtitleKey),
                          features: slide.features,
                        );
                      } else if (index == 4) {
                        return OnboardingThemePicker(isDark: isDark);
                      } else {
                        return OnboardingLanguagePicker(isDark: isDark);
                      }
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
                      OnboardingPageIndicator(
                        itemCount: _totalSlides,
                        currentPage: _currentPage,
                      ),
                      const SizedBox(height: 24),
                      OnboardingNavigationButtons(
                        isLastPage: isLastPage,
                        onPressed: _onNext,
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
