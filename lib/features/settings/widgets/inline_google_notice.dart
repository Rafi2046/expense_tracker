import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class InlineGoogleNotice extends StatelessWidget {
  const InlineGoogleNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor, width: 1.0),
          ),
          child: Column(
            children: [
              Icon(
                LucideIcons.signal,
                color: theme.primaryColor,
                size: 36,
              ),
              const SizedBox(height: 8),
              Text(
                'Google Sign-in Active',
              style: AppTextStyles.bodyBold.copyWith(color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 6),
              Text(
                'Your account password is managed securely by Google. You cannot change your Google account credentials inside this app.',
                textAlign: TextAlign.center,
              style: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
