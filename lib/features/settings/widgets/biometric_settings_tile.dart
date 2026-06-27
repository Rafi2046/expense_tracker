import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/providers/biometric_auth_provider.dart';

class BiometricSettingsTile extends StatefulWidget {
  const BiometricSettingsTile({super.key});

  @override
  State<BiometricSettingsTile> createState() => _BiometricSettingsTileState();
}

class _BiometricSettingsTileState extends State<BiometricSettingsTile> {
  bool _canCheckBiometrics = false;
  bool _checkedCapability = false;

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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? (isAvailable
                      ? const Color(0xFF1A237E).withValues(alpha: 0.2)
                      : Colors.white10)
                  : (isAvailable
                      ? const Color(0xFFE8EAF6)
                      : const Color(0xFFF3F4F6)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.fingerprint,
              color: isAvailable
                  ? (isDark ? Colors.white70 : const Color(0xFF3949AB))
                  : (isDark ? Colors.white30 : const Color(0xFF9CA3AF)),
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Biometric Login',
                  style: GoogleFonts.workSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: isAvailable
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isAvailable
                      ? 'Use Face ID / Fingerprint on app restart'
                      : 'Not available on this device',
                  style: GoogleFonts.workSans(
                    fontSize: 11.5,
                    color: isAvailable
                        ? theme.colorScheme.onSurfaceVariant
                        : const Color(0xFFE53935).withValues(alpha: 0.7),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (_checkedCapability)
            Switch(
              value: provider.isEnabled && isAvailable,
              onChanged: isAvailable
                  ? (value) async {
                      if (value) {
                        final verified = await provider.authenticate(
                          localizedReason: 'Scan your fingerprint or Face ID to register and enable biometric login.',
                        );
                        if (!verified) return;
                        final userEmail = FirebaseAuth.instance.currentUser?.email;
                        await provider.setEnabled(true, email: userEmail);
                      } else {
                        await provider.setEnabled(false);
                      }
                    }
                  : null,
              activeColor: theme.primaryColor,
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
