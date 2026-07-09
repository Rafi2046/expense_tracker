import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class CreditInfoForm extends StatelessWidget {
  final TextEditingController balanceController;
  final TextEditingController dateController;
  final bool isReceive;
  final ValueChanged<bool> onToggleChanged;
  final VoidCallback onSelectDate;
  final String currencySymbol;

  const CreditInfoForm({
    super.key,
    required this.balanceController,
    required this.dateController,
    required this.isReceive,
    required this.onToggleChanged,
    required this.onSelectDate,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Opening Balance Field
            Expanded(
              child: TextFormField(
                controller: balanceController,
                style: AppTextStyles.partyFormInput.copyWith(color: theme.colorScheme.onSurface),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: 'Opening Balance',
                  hintStyle: AppTextStyles.partyFormHint.copyWith(color: isDark ? Colors.white30 : null),
                  prefixText: '$currencySymbol ',
                  prefixStyle: AppTextStyles.partyFormInput.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.dividerTheme.color ?? Colors.grey.shade100),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.dividerTheme.color ?? Colors.grey.shade200),
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
            ),
            const SizedBox(width: 12),

            // Date Picker Field
            Expanded(
              child: TextFormField(
                controller: dateController,
                readOnly: true,
                style: AppTextStyles.partyFormInput.copyWith(
                  fontSize: AppFontSizes.size12,
                  color: theme.colorScheme.onSurface,
                ),
                onTap: onSelectDate,
                decoration: InputDecoration(
                  labelText: 'As of Date',
                  labelStyle: AppTextStyles.partyFormLabel.copyWith(
                    fontSize: AppFontSizes.size12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: theme.cardColor,
                  suffixIcon: Icon(
                    Symbols.calendar_month_rounded,
                    color: isDark ? Colors.white38 : Colors.grey.shade400,
                    size: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.dividerTheme.color ?? Colors.grey.shade100),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.dividerTheme.color ?? Colors.grey.shade200),
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
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Animated To Receive / To Give Toggles
        Row(
          children: [
            _buildAnimatedPill(
              context: context,
              label: 'To Receive',
              isActive: isReceive,
              onTap: () => onToggleChanged(true),
            ),
            const SizedBox(width: 12),
            _buildAnimatedPill(
              context: context,
              label: 'To Give',
              isActive: !isReceive,
              onTap: () => onToggleChanged(false),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnimatedPill({
    required BuildContext context,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? theme.primaryColor : (isDark ? Colors.white10 : const Color(0xFFF1F2F4)),
            borderRadius: BorderRadius.circular(20),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: theme.primaryColor.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: GoogleFonts.workSans(
              fontSize: AppFontSizes.size12,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : (isDark ? Colors.white60 : const Color(0xFF31394D)),
            ),
          ),
        ),
      ),
    );
  }
}
