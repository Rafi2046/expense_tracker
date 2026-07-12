import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/reports/widgets/privacy_toggle_section.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PartiesReportHeader extends StatelessWidget {
  final bool isMasked;
  final VoidCallback onToggle;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final bool isDark;

  const PartiesReportHeader({
    super.key,
    required this.isMasked,
    required this.onToggle,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PrivacyToggleSection(
          isMasked: isMasked,
          onToggle: onToggle,
        ),
        const SizedBox(height: 14),
        TextFormField(
          initialValue: searchQuery,
          onChanged: onSearchChanged,
          style: AppTextStyles.partyFormInput.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'Search parties...',
            hintStyle: AppTextStyles.partyFormHint.copyWith(
              fontSize: AppFontSizes.size14,
              color: isDark ? Colors.white30 : null,
            ),
            prefixIcon: Icon(
              LucideIcons.search,
              color: isDark ? Colors.white30 : Colors.grey.shade400,
              size: 20,
            ),
            filled: true,
            fillColor: theme.cardColor,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.dividerTheme.color ?? Colors.grey.shade100,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.dividerTheme.color ?? Colors.grey.shade100,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.primaryColor,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
