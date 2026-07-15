import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/providers/biometric_auth_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

class LoginBiometricSection extends StatelessWidget {
  final Animation<double> biometricAnim;
  final BiometricAuthProvider biometricProvider;
  final bool biometricFailed;
  final bool hasPasswordProvider;
  final bool isDark;
  final ThemeData theme;
  final VoidCallback onBiometricTap;
  final VoidCallback onSwitchAccount;

  const LoginBiometricSection({
    super.key,
    required this.biometricAnim,
    required this.biometricProvider,
    required this.biometricFailed,
    required this.hasPasswordProvider,
    required this.isDark,
    required this.theme,
    required this.onBiometricTap,
    required this.onSwitchAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Center(
          child: GestureDetector(
            onTap: onBiometricTap,
            child: AnimatedBuilder(
              animation: biometricAnim,
              builder: (context, child) {
                return Transform.scale(
                  scale: biometricAnim.value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.primaryColor.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      biometricProvider.icon,
                      size: 40,
                      color: theme.primaryColor,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          biometricFailed
              ? context.translate('biometric_failed')
              : context.translate('tap_to_unlock'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFontSizes.size13,
            color: biometricFailed
                ? const Color(0xFFE53935)
                : theme.primaryColor.withValues(alpha: 0.7),
          ),
        ),
        if (hasPasswordProvider) ...[
          const SizedBox(height: 4),
          Text(
            context.translate('or_enter_password'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFontSizes.size12,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
            ),
          ),
        ],
        if (!hasPasswordProvider)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: GestureDetector(
              onTap: onSwitchAccount,
              child: Text(
                context.translate('switch_account'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFontSizes.size14,
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
