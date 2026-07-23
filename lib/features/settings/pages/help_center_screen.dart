import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  Widget _buildFaqSection(BuildContext context, ThemeData theme, _FaqItem faq) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.p24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            faq.question,
            style: AppTextStyles.reportTileTitle.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            faq.answer,
            style: AppTextStyles.bodySmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.6
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

    final faqs = [
      _FaqItem(
        question: context.translate('faq_biometric_q'),
        answer: context.translate('faq_biometric_a'),
      ),
      _FaqItem(
        question: context.translate('faq_export_statements_q'),
        answer: context.translate('faq_export_statements_a'),
      ),
      _FaqItem(
        question: context.translate('faq_backup_q'),
        answer: context.translate('faq_backup_a'),
      ),
      _FaqItem(
        question: context.translate('faq_edit_budget_q'),
        answer: context.translate('faq_edit_budget_a'),
      ),
    ];

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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p16),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(AppSpacing.r24),
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
            padding: const EdgeInsets.all(AppSpacing.p24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.translate('faq'),
                  style: AppTextStyles.profileTitle.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w800
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  context.translate('faq_subtitle'),
                  style: AppTextStyles.caption.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                const Divider(),
                const SizedBox(height: AppSpacing.s16),
                
                ...faqs.map((faq) => _buildFaqSection(context, theme, faq)),
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