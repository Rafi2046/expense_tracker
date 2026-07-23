import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class PartyFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final bool isNameNotEmpty;

  const PartyFormFields({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.isNameNotEmpty,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        TextFormField(
          controller: nameController,
          style: AppTextStyles.partyFormInput.copyWith(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: context.translate('party_name'),
            hintStyle: AppTextStyles.partyFormHint,
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p12),
            filled: true,
            fillColor: theme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.r12),
              borderSide: BorderSide(color: theme.dividerTheme.color ?? Colors.grey.shade100),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.r12),
              borderSide: BorderSide(color: theme.dividerTheme.color ?? Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.r12),
              borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return context.translate('please_enter_party_name');
            }
            return null;
          },
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SizeTransition(sizeFactor: animation, child: FadeTransition(opacity: animation, child: child));
          },
          child: isNameNotEmpty
              ? Padding(
                  key: const ValueKey('expanded_phone'),
                  padding: const EdgeInsets.only(top: AppSpacing.p12),
                  child: TextFormField(
                    controller: phoneController,
                    style: AppTextStyles.partyFormInput.copyWith(color: theme.colorScheme.onSurface),
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: context.translate('phone_number'),
                      hintStyle: AppTextStyles.partyFormHint,
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p12),
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.r12),
                        borderSide: BorderSide(color: theme.dividerTheme.color ?? Colors.grey.shade100),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.r12),
                        borderSide: BorderSide(color: theme.dividerTheme.color ?? Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.r12),
                        borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
                      ),
                    ),
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty && value.trim().length < 10) {
                        return context.translate('enter_at_least_10_digits');
                      }
                      return null;
                    },
                  ),
                )
              : const SizedBox(key: ValueKey('collapsed_phone')),
        ),
      ],
    );
  }
}
