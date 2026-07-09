import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.translate('privacy_policy'),
          style: AppTextStyles.h1.copyWith(color: theme.colorScheme.onSurface),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF2D2D2D)
                : const Color(0xFFF1F1F1),
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              children: [
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6A53A1), Color(0xFF32235B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      LucideIcons.shield,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Privacy Summary',
                  style: AppTextStyles.profileTitle.copyWith(color: theme.colorScheme.onSurface),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'How we handle your data',
                  style: AppTextStyles.body.copyWith(
                    fontFamily: GoogleFonts.workSans().fontFamily,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  ),
                ),
                const SizedBox(height: 28),
                _PrivacyTile(
                  icon: LucideIcons.smartphone,
                  title: 'Data Stays with You',
                  subtitle: 'Your financial data is processed securely on your device. Nothing is shared without your explicit consent.',
                ),
                const SizedBox(height: 10),
                _PrivacyTile(
                  icon: LucideIcons.ban,
                  title: 'No Data Selling',
                  subtitle: 'We never sell, rent, or trade your personal information to third parties. Your trust matters.',
                ),
                const SizedBox(height: 10),
                _PrivacyTile(
                  icon: LucideIcons.fingerprint,
                  title: 'Biometric Security',
                  subtitle: 'Protected by your device\'s native secure enclave. Your biometric data never leaves your phone.',
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16, 4, 16, MediaQuery.of(context).padding.bottom),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(LucideIcons.fileText, size: 18),
                label: Text(
                  'Read Full Legal Policy',
                  style: AppTextStyles.bodyBold,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6A53A1),
                  side: const BorderSide(color: Color(0xFF6A53A1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PrivacyTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF2D2D2D)
              : const Color(0xFFF1F1F1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6A53A1), Color(0xFF32235B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                style: AppTextStyles.reportTileTitle.copyWith(color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
