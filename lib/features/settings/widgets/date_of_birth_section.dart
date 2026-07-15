import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DateOfBirthSection extends StatelessWidget {
  final TextEditingController dobController;
  final VoidCallback onSelectDate;

  const DateOfBirthSection({
    super.key,
    required this.dobController,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final inputBg = isDark ? theme.cardColor : const Color(0xFFF5F6F8);
    final primaryColor = isDark ? const Color(0xFF8E75C8) : const Color(0xFF6A53A1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.translate('date_of_birth'),
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade400 : Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: dobController,
          readOnly: true,
          onTap: onSelectDate,
          style: AppTextStyles.reportTileTitle.copyWith(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            filled: true,
            fillColor: inputBg,
            prefixIcon: Icon(
              LucideIcons.calendar,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              size: 18,
            ),
            hintText: context.translate('dd_mm_yyyy'),
            hintStyle: AppTextStyles.body.copyWith(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 1.5),
            ),
            suffixIcon: Icon(
              LucideIcons.calendar,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}
