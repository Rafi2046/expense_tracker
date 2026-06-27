import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/providers/app_lock_provider.dart';

class LockScreenOverlay extends StatefulWidget {
  const LockScreenOverlay({super.key});

  @override
  State<LockScreenOverlay> createState() => _LockScreenOverlayState();
}

class _LockScreenOverlayState extends State<LockScreenOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  IconData _biometricIcon = Icons.fingerprint;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    _detectBiometrics();
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _detectBiometrics() async {
    try {
      final auth = LocalAuthentication();
      final available = await auth.getAvailableBiometrics();
      if (available.contains(BiometricType.face)) {
        setState(() => _biometricIcon = Icons.face_rounded);
      } else if (available.contains(BiometricType.fingerprint)) {
        setState(() => _biometricIcon = Icons.fingerprint);
      }
    } catch (_) {}
  }

  Future<void> _authenticate() async {
    final provider = context.read<AppLockProvider>();
    if (provider.isAuthenticating) return;

    HapticFeedback.lightImpact();
    setState(() {
      _hasError = false;
      _errorMessage = '';
    });

    final success = await provider.authenticate();
    if (!mounted) return;

    if (!success) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Authentication failed. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: child,
                );
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _biometricIcon,
                  size: 48,
                  color: theme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'App Locked',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Authenticate to access your data',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const Spacer(flex: 1),
            if (_hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: Color(0xFFE53935),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            GestureDetector(
              onTap: _authenticate,
              child: Container(
                width: 200,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Tap to Unlock',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
