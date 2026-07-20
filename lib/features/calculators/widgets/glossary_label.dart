import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

class GlossaryEntry {
  final IconData icon;
  final String titleKey;
  final String descriptionKey;

  const GlossaryEntry({
    required this.icon,
    required this.titleKey,
    required this.descriptionKey,
  });
}

class GlossaryLabel extends StatelessWidget {
  final String text;
  final GlossaryEntry entry;

  const GlossaryLabel({
    super.key,
    required this.text,
    required this.entry,
  });

  void _showSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _GlossarySheet(
        entry: entry,
        isDark: isDark,
        theme: theme,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showSheet(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              text,
              style: AppTextStyles.calculatorLabel.copyWith(
                color: isDark ? Colors.grey.shade400 : null,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            LucideIcons.info,
            size: AppFontSizes.size13,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}

class _GlossarySheet extends StatelessWidget {
  final GlossaryEntry entry;
  final bool isDark;
  final ThemeData theme;

  const _GlossarySheet({
    required this.entry,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: (isDark ? const Color(0xFF2EBD85) : const Color(0xFF0C4E3C)).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  entry.icon,
                  color: isDark ? const Color(0xFF2EBD85) : const Color(0xFF0C4E3C),
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                context.translate(entry.titleKey),
                style: TextStyle(
                  fontSize: AppFontSizes.size18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                context.translate(entry.descriptionKey),
                style: TextStyle(
                  fontSize: AppFontSizes.size14,
                  fontWeight: FontWeight.w400,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
