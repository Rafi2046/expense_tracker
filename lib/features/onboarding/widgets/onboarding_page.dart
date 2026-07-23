import 'dart:math' as math;
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



class OnboardingPage extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final List<OnboardingFeatureItem> features;

  const OnboardingPage({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.features = const [],
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _orbitController;
  late AnimationController _staggerController;

  // Staggered entry animations
  late Animation<double> _heroSlide;
  late Animation<double> _heroFade;
  late Animation<double> _titleSlide;
  late Animation<double> _titleFade;
  late Animation<double> _subtitleSlide;
  late Animation<double> _subtitleFade;
  late Animation<double> _featuresFade;
  late Animation<double> _featuresSlide;

  @override
  void initState() {
    super.initState();

    // Pulse glow
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Orbit rotation
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // Staggered content entry
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _heroFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _heroSlide = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.2, 0.55, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.2, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.35, 0.65, curve: Curves.easeOut),
      ),
    );
    _subtitleSlide = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.35, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _featuresFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.5, 0.85, curve: Curves.easeOut),
      ),
    );
    _featuresSlide = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.5, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _staggerController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _orbitController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF6B7280);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p24),
      child: AnimatedBuilder(
        animation: _staggerController,
        builder: (context, child) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.s32),
            Transform.translate(
              offset: Offset(0, _heroSlide.value),
              child: Opacity(
                opacity: _heroFade.value,
                child: _buildHeroIcon(),
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            Transform.translate(
              offset: Offset(0, _titleSlide.value),
              child: Opacity(
                opacity: _titleFade.value,
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.displayMedium.copyWith(fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.6,
                    height: 1.2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Transform.translate(
              offset: Offset(0, _subtitleSlide.value),
              child: Opacity(
                opacity: _subtitleFade.value,
                child: Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(color: subTextColor,
                    height: 1.45,
                    letterSpacing: 0.1),
                ),
              ),
            ),
            if (widget.features.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s16),
              Transform.translate(
                offset: Offset(0, _featuresSlide.value),
                child: Opacity(
                  opacity: _featuresFade.value,
                  child: Column(
                    children: widget.features.map((f) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.p4),
                      child: _PremiumFeatureCard(
                        feature: f,
                        isDark: isDark,
                        subTextColor: subTextColor,
                      ),
                    )).toList(),
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.s24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroIcon() {
    return SizedBox(
      width: 110,
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outermost dashed orbit ring with rotating dots
          AnimatedBuilder(
            animation: _orbitController,
            builder: (context, child) => Transform.rotate(
              angle: _orbitController.value * 2 * math.pi,
              child: CustomPaint(
                size: const Size(110, 110),
                painter: _OrbitRingPainter(
                  color: widget.iconColor.withValues(alpha: 0.15),
                  dotColor: widget.iconColor.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          // Middle glow ring
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    widget.iconColor.withValues(alpha: 0.22),
                    widget.iconColor.withValues(alpha: 0.08),
                    widget.iconColor.withValues(alpha: 0.02),
                    Colors.transparent,
                  ],
                  stops: const [0.2, 0.5, 0.75, 1.0],
                ),
              ),
            ),
          ),
          // Inner icon circle
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  HSLColor.fromColor(widget.iconColor)
                      .withLightness(
                        (HSLColor.fromColor(widget.iconColor).lightness + 0.06)
                            .clamp(0.0, 1.0),
                      )
                      .toColor(),
                  widget.iconColor,
                  HSLColor.fromColor(widget.iconColor)
                      .withLightness(
                        (HSLColor.fromColor(widget.iconColor).lightness - 0.15)
                            .clamp(0.0, 1.0),
                      )
                      .toColor(),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.iconColor.withValues(alpha: 0.4),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: widget.iconColor.withValues(alpha: 0.15),
                  blurRadius: 50,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Icon(widget.icon, size: 26, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// ─── Orbit Ring Painter ───
class _OrbitRingPainter extends CustomPainter {
  final Color color;
  final Color dotColor;

  _OrbitRingPainter({required this.color, required this.dotColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Dashed circle
    final dashPaint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const dashCount = 40;
    const dashAngle = (2 * math.pi) / dashCount;
    const gapRatio = 0.4;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      final sweepAngle = dashAngle * (1 - gapRatio);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        dashPaint,
      );
    }

    // 4 decorative dots at different positions
    final dotPaint = Paint()..color = dotColor;
    const dotPositions = [0.0, math.pi / 2, math.pi, 3 * math.pi / 2];
    final dotSizes = [3.5, 2.5, 3.0, 2.0];

    for (int i = 0; i < dotPositions.length; i++) {
      final angle = dotPositions[i];
      final dx = center.dx + radius * math.cos(angle);
      final dy = center.dy + radius * math.sin(angle);
      canvas.drawCircle(Offset(dx, dy), dotSizes[i], dotPaint);
    }
  }

  @override
  bool shouldRepaint(_OrbitRingPainter oldDelegate) => false;
}

// ─── Premium Feature Card ───
class _PremiumFeatureCard extends StatelessWidget {
  final OnboardingFeatureItem feature;
  final bool isDark;
  final Color subTextColor;

  const _PremiumFeatureCard({
    required this.feature,
    required this.isDark,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.r12),
        border: Border.all(
          color: isDark
              ? feature.color.withValues(alpha: 0.15)
              : feature.color.withValues(alpha: 0.1),
        ),
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: feature.color.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.r12),
        child: Row(
          children: [
            // Gradient accent bar on left
            Container(
              width: 3.5,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    feature.color,
                    feature.color.withValues(alpha: 0.4),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p8),
                child: Row(
                  children: [
                    // Icon with gradient background
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSpacing.r8),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            feature.color.withValues(alpha: isDark ? 0.25 : 0.14),
                            feature.color.withValues(alpha: isDark ? 0.12 : 0.06),
                          ],
                        ),
                      ),
                      child: Icon(feature.icon, size: 16, color: feature.color),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: Text(
                        context.translate(feature.labelKey),
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white.withValues(alpha: 0.85) : const Color(0xFF374151),
                          height: 1.3,
                          letterSpacing: 0.05,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingFeatureItem {
  final IconData icon;
  final String labelKey;
  final Color color;

  const OnboardingFeatureItem({
    required this.icon,
    required this.labelKey,
    required this.color,
  });
}
