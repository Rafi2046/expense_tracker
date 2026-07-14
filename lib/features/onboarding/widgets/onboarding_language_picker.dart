import 'dart:math' as math;
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class OnboardingLanguagePicker extends StatefulWidget {
  final bool isDark;

  const OnboardingLanguagePicker({super.key, required this.isDark});

  @override
  State<OnboardingLanguagePicker> createState() =>
      _OnboardingLanguagePickerState();
}

class _OnboardingLanguagePickerState extends State<OnboardingLanguagePicker>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _orbitController;
  late AnimationController _staggerController;

  late Animation<double> _heroFade;
  late Animation<double> _heroSlide;
  late Animation<double> _titleFade;
  late Animation<double> _titleSlide;
  late Animation<double> _subtitleFade;
  late Animation<double> _subtitleSlide;
  late Animation<double> _cardsFade;
  late Animation<double> _cardsSlide;

  static const _accentColor = Color(0xFF2EBD85);

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _heroFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _staggerController, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );
    _heroSlide = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _staggerController, curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic)),
    );
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _staggerController, curve: const Interval(0.2, 0.55, curve: Curves.easeOut)),
    );
    _titleSlide = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(parent: _staggerController, curve: const Interval(0.2, 0.55, curve: Curves.easeOutCubic)),
    );
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _staggerController, curve: const Interval(0.35, 0.65, curve: Curves.easeOut)),
    );
    _subtitleSlide = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(parent: _staggerController, curve: const Interval(0.35, 0.65, curve: Curves.easeOutCubic)),
    );
    _cardsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _staggerController, curve: const Interval(0.5, 0.85, curve: Curves.easeOut)),
    );
    _cardsSlide = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(parent: _staggerController, curve: const Interval(0.5, 0.85, curve: Curves.easeOutCubic)),
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
    final langProvider = context.watch<LanguageProvider>();
    final isDark = widget.isDark;
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF6B7280);
    final cardBg = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white;
    final selectedBorder = _accentColor;
    final unselectedBorder = isDark ? Colors.white24 : Colors.grey.shade200;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: AnimatedBuilder(
        animation: _staggerController,
        builder: (context, child) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            // ─── Premium Hero ───
            Transform.translate(
              offset: Offset(0, _heroSlide.value),
              child: Opacity(
                opacity: _heroFade.value,
                child: _buildHeroIcon(),
              ),
            ),
            const SizedBox(height: 32),
            // ─── Title ───
            Transform.translate(
              offset: Offset(0, _titleSlide.value),
              child: Opacity(
                opacity: _titleFade.value,
                child: Text(
                  context.translate('onboarding_language_title'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.8,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // ─── Subtitle ───
            Transform.translate(
              offset: Offset(0, _subtitleSlide.value),
              child: Opacity(
                opacity: _subtitleFade.value,
                child: Text(
                  context.translate('onboarding_language_subtitle'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: subTextColor,
                    height: 1.5,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),
            // ─── Language Cards ───
            Transform.translate(
              offset: Offset(0, _cardsSlide.value),
              child: Opacity(
                opacity: _cardsFade.value,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: langProvider.supportedLanguages.map((lang) {
                    final isSelected = langProvider.currentLanguageCode == lang.code;
                    return GestureDetector(
                      onTap: () => langProvider.changeLanguage(lang.code),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        width: 140,
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? selectedBorder : unselectedBorder,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: selectedBorder.withValues(alpha: 0.25),
                                    blurRadius: 16,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(lang.flag, style: const TextStyle(fontSize: 32)),
                            const SizedBox(height: 8),
                            Text(
                              lang.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected
                                    ? selectedBorder
                                    : textColor.withValues(alpha: 0.6),
                              ),
                            ),
                            // Selected indicator dot
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.only(top: 8),
                              width: isSelected ? 6 : 0,
                              height: isSelected ? 6 : 0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selectedBorder,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroIcon() {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Orbit ring
          AnimatedBuilder(
            animation: _orbitController,
            builder: (context, child) => Transform.rotate(
              angle: _orbitController.value * 2 * math.pi,
              child: CustomPaint(
                size: const Size(140, 140),
                painter: _OrbitRingPainter(
                  color: _accentColor.withValues(alpha: 0.15),
                  dotColor: _accentColor.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          // Glow ring
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _accentColor.withValues(alpha: 0.22),
                    _accentColor.withValues(alpha: 0.08),
                    _accentColor.withValues(alpha: 0.02),
                    Colors.transparent,
                  ],
                  stops: const [0.2, 0.5, 0.75, 1.0],
                ),
              ),
            ),
          ),
          // Icon circle
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF36D399), _accentColor, Color(0xFF1A8B5E)],
              ),
              boxShadow: [
                BoxShadow(
                  color: _accentColor.withValues(alpha: 0.4),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: _accentColor.withValues(alpha: 0.15),
                  blurRadius: 50,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: const Icon(LucideIcons.globe, size: 34, color: Colors.white),
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
