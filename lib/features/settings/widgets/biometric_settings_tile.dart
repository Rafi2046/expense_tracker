import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/core/providers/biometric_auth_provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class BiometricSettingsTile extends StatefulWidget {
  const BiometricSettingsTile({super.key});

  @override
  State<BiometricSettingsTile> createState() => _BiometricSettingsTileState();
}

class _BiometricSettingsTileState extends State<BiometricSettingsTile> {
  bool _canCheckBiometrics = false;
  bool _checkedCapability = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _checkCapability();
  }

  Future<void> _checkCapability() async {
    final provider = context.read<BiometricAuthProvider>();
    final canCheck = await provider.canCheckBiometrics;
    if (!mounted) return;
    setState(() {
      _canCheckBiometrics = canCheck;
      _checkedCapability = true;
    });
  }

  Future<void> _onToggle(bool value) async {
    if (_isProcessing) return;

    final provider = context.read<BiometricAuthProvider>();
    final messenger = ScaffoldMessenger.of(context);

    if (value) {
      setState(() => _isProcessing = true);
      try {
        final verified = await provider.authenticate(
          localizedReason: 'Scan your fingerprint or Face ID to register and enable biometric login.',
        );
        if (!verified) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Biometric authentication failed. Please try again.')),
          );
          return;
        }
        final userEmail = FirebaseAuth.instance.currentUser?.email;
        await provider.setEnabled(true, email: userEmail);
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
    } else {
      await provider.setEnabled(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BiometricAuthProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bool isAvailable = _checkedCapability && _canCheckBiometrics;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Icon(
            LucideIcons.fingerprint,
            color: isAvailable
                ? (isDark ? Colors.white70 : Colors.grey.shade700)
                : (isDark ? Colors.white30 : Colors.grey.shade400),
            size: 22,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Biometric Login',
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isAvailable
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isProcessing
                      ? 'Authenticating...'
                      : (isAvailable
                          ? 'Use Face ID / Fingerprint on app restart'
                          : 'Not available on this device'),
                  style: AppTextStyles.caption.copyWith(
                    fontSize: AppFontSizes.size9,
                    color: _isProcessing
                        ? theme.primaryColor
                        : (isAvailable
                            ? theme.colorScheme.onSurfaceVariant
                            : const Color(0xFFE53935).withValues(alpha: 0.7)),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (_checkedCapability)
            Switch(
              value: provider.isEnabled && isAvailable,
              onChanged: isAvailable && !_isProcessing ? _onToggle : null,
              activeThumbColor: theme.primaryColor,
            )
          else
            const SizedBox(
              width: 36,
              height: 36,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
        ],
      ),
    );
  }
}
