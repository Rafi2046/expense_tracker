import 'dart:math' as math;
import 'package:expense_tracker/core/providers/biometric_auth_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class OnboardingBiometricPicker extends StatefulWidget {
  final bool isDark;
  final VoidCallback onStepComplete;

  const OnboardingBiometricPicker({
    super.key,
    required this.isDark,
    required this.onStepComplete,
  });

  @override
  State<OnboardingBiometricPicker> createState() => _OnboardingBiometricPickerState();
}

class _OnboardingBiometricPickerState extends State<OnboardingBiometricPicker>
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
  late Animation<double> _buttonFade;
  late Animation<double> _buttonSlide;

  bool _isProcessing = false;
  static const _accentColor = Color(0xFF6A53A1); // Premium purple matching theme

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
    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _staggerController, curve: const Interval(0.5, 0.85, curve: Curves.easeOut)),
    );
    _buttonSlide = Tween<double>(begin: 20, end: 0).animate(
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

  Future<void> _enableBiometrics() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final provider = context.read<BiometricAuthProvider>();
    final messenger = ScaffoldMessenger.of(context);

    // Get translations with listen: false before async gap to prevent context/listen issues
    final reasonText = context.translate('onboarding_biometric_subtitle', listen: false);
    final successText = context.translate('onboarding_biometric_success', listen: false);
    final failedText = context.translate('onboarding_biometric_failed', listen: false);

    try {
      final verified = await provider.authenticate(
        localizedReason: reasonText,
      );
      if (!verified) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(failedText),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      final userEmail = FirebaseAuth.instance.currentUser?.email;
      await provider.setEnabled(true, email: userEmail);

      messenger.showSnackBar(
        SnackBar(
          content: Text(successText),
          backgroundColor: Colors.green,
        ),
      );
      widget.onStepComplete();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(failedText),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF6B7280);

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: AnimatedBuilder(
          animation: _staggerController,
          builder: (context, child) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
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
                    context.translate('onboarding_biometric_title'),
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
                    context.translate('onboarding_biometric_subtitle'),
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
              // ─── Action Buttons ───
              Transform.translate(
                offset: Offset(0, _buttonSlide.value),
                child: Opacity(
                  opacity: _buttonFade.value,
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _enableBiometrics,
                        icon: const Icon(LucideIcons.fingerprint, size: 20),
                        label: Text(
                          context.translate('onboarding_biometric_enable'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: _accentColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: widget.onStepComplete,
                      child: Text(
                        context.translate('onboarding_biometric_skip'),
                        style: TextStyle(
                          color: _accentColor,
                          fontWeight: FontWeight.w600,
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
                colors: [Color(0xFF8670BE), _accentColor, Color(0xFF4C367C)],
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
            child: const Icon(LucideIcons.fingerprint, size: 34, color: Colors.white),
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

    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      final angle = (i * 2 * math.pi / 3);
      final dotCenter = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawCircle(dotCenter, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
