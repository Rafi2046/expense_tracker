import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const _faqs = [
    _FaqItem(
      question: 'How to reset biometric login?',
      answer: 'Open Settings → Account → Biometric Settings. Toggle the switch off, then on again to re-enroll your biometrics.',
    ),
    _FaqItem(
      question: 'How to export party statements?',
      answer: 'Go to Reports → Party Statement. Select the party and date range, then tap the Export button to save as PDF.',
    ),
    _FaqItem(
      question: 'Are my transactions backed up?',
      answer: 'Transactions are stored locally on your device. Enable cloud backup in Settings → Preferences to keep your data safe.',
    ),
    _FaqItem(
      question: 'How to edit a budget?',
      answer: 'Navigate to Dashboard → Budget Card → Tap the budget you want to modify. Adjust the amount or category and save.',
    ),
  ];

  Widget _buildFaqSection(BuildContext context, ThemeData theme, _FaqItem faq) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            faq.question,
            style: AppTextStyles.reportTileTitle.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            faq.answer,
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
          context.translate('help_center'),
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
                  'Frequently Asked Questions',
                  style: AppTextStyles.profileTitle.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Quick answers to help you navigate the app',
                  style: AppTextStyles.caption.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 20),
                
                ..._faqs.map((faq) => _buildFaqSection(context, theme, faq)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});
}
