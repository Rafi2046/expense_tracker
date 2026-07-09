import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
          context.translate('help_center'),
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
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              itemCount: _faqs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final faq = _faqs[index];
                return Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.brightness == Brightness.dark
                          ? const Color(0xFF2D2D2D)
                          : const Color(0xFFF1F1F1),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      shape: const Border(),
                      collapsedShape: const Border(),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? const Color(0xFF2D2D2D)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          LucideIcons.helpCircle,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        faq.question,
                        style: AppTextStyles.reportTileTitle.copyWith(color: theme.colorScheme.onSurface),
                      ),
                      children: [
                        Text(
                          faq.answer,
                          style: AppTextStyles.body.copyWith(
                            fontFamily: GoogleFonts.workSans().fontFamily,
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 24 + MediaQuery.of(context).padding.bottom),
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
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(LucideIcons.mail, size: 18),
                label: Text(
                  'Contact Support',
                  style: AppTextStyles.reportTileTitle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A53A1),
                  foregroundColor: Colors.white,
                  elevation: 0,
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

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});
}
