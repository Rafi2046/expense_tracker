import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class ProfileAvatarSection extends StatelessWidget {
  final String partyName;
  final String initial;

  const ProfileAvatarSection({
    super.key,
    required this.partyName,
    required this.initial,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.p24, AppSpacing.p24, AppSpacing.p24, AppSpacing.p16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.p4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  primaryColor.withValues(alpha: 0.6),
                  primaryColor.withValues(alpha: 0.15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.25),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 34,
              backgroundColor: isDark
                  ? primaryColor.withValues(alpha: 0.15)
                  : primaryColor.withValues(alpha: 0.08),
              child: Text(
                initial,
                style: AppTextStyles.reportLargeValue.copyWith(
                  color: primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            partyName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.h1.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.3,
              height: 1.25,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            context.translate('party_account'),
            style: AppTextStyles.label.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
