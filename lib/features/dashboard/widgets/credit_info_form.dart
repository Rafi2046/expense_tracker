import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
                style: AppTextStyles.partyFormInput,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Opening Balance',
                  hintStyle: AppTextStyles.partyFormHint,
                  prefixText: '$currencySymbol ',
                  prefixStyle: AppTextStyles.partyFormInput.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade100),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.activeGreen, width: 1.5),
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
                style: AppTextStyles.partyFormInput.copyWith(fontSize: 12.0),
                onTap: onSelectDate,
                decoration: InputDecoration(
                  labelText: 'As of Date',
                  labelStyle: AppTextStyles.partyFormLabel.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.grey.shade400,
                    size: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade100),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.activeGreen, width: 1.5),
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
              label: 'To Receive',
              isActive: isReceive,
              onTap: () => onToggleChanged(true),
            ),
            const SizedBox(width: 12),
            _buildAnimatedPill(
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
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.activeGreen : const Color(0xFFF1F2F4),
            borderRadius: BorderRadius.circular(20),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.activeGreen.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: GoogleFonts.workSans(
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : const Color(0xFF31394D),
            ),
          ),
        ),
      ),
    );
  }
}
