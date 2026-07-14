import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Widget _buildSection(BuildContext context, ThemeData theme, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.reportTileTitle.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: AppTextStyles.bodySmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.6,
              fontSize: 13.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
            color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF1F1F1),
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BudgetMint Privacy Policy',
                  style: AppTextStyles.profileTitle.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Last Updated: July 2026',
                  style: AppTextStyles.caption.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 20),
                
                _buildSection(
                  context,
                  theme,
                  '1. Data Ownership & Storage',
                  'Your financial records, transactions, notes, and profiles are stored locally on your device\'s secure database. We do not transmit or process your financial information on external servers, except when you choose to use our cloud backup and sync service.',
                ),
                _buildSection(
                  context,
                  theme,
                  '2. Firebase Cloud Backup & Sync',
                  'If you choose to log in and enable cloud synchronization, your transactions, categories, budgets, and profile data are backed up to secure Firebase servers (Cloud Firestore). This data is strictly used to synchronize your entries across devices and is encrypted in transit and at rest.',
                ),
                _buildSection(
                  context,
                  theme,
                  '3. Security & Encryption',
                  'Your local database is stored in your device\'s isolated storage directory, accessible only by this application. In addition, when biometric security (Face ID / Touch ID) is enabled, access to the application is protected using your device\'s native secure enclave. We never collect or store your biometric credentials.',
                ),
                _buildSection(
                  context,
                  theme,
                  '4. No Selling or Sharing',
                  'We value your privacy. We do not sell, rent, lease, or share your financial logs, personal email, display name, or profile configurations with any third-party advertisers, companies, or analytics networks.',
                ),
                _buildSection(
                  context,
                  theme,
                  '5. Your Rights & Data Deletion',
                  'You retain absolute ownership and control over your data. At any time, you can clear all transactions, delete your custom profiles, or delete your entire account and synced backups directly from the Settings menu. Once deleted, the action cannot be undone and your data is permanently wiped from our databases.',
                ),
                _buildSection(
                  context,
                  theme,
                  '6. Policy Changes & Updates',
                  'We may update our Privacy Policy from time to time. Any changes will be posted on this screen. We encourage you to review this policy periodically for any updates to stay informed about how we protect your information.',
                ),
                _buildSection(
                  context,
                  theme,
                  '7. Contact & Support',
                  'If you have any questions or feedback regarding this Privacy Policy or your data, please contact our support team from the Settings menu or email us directly.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
