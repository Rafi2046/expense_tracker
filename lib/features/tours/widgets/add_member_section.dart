import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

class AddMemberSection extends StatelessWidget {
  final TextEditingController nameController;
  final int selectedColorIndex;
  final List<Color> presetColors;
  final ValueChanged<int> onColorSelected;
  final VoidCallback onAddMember;

  const AddMemberSection({
    super.key,
    required this.nameController,
    required this.selectedColorIndex,
    required this.presetColors,
    required this.onColorSelected,
    required this.onAddMember,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(AppSpacing.m16),
      padding: const EdgeInsets.all(AppSpacing.p16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.br8),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: context.translate('enter_member_name'),
              hintStyle: AppTextStyles.textFieldHint,
              border: InputBorder.none,
              filled: true,
              fillColor: theme.brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.05)
                  : AppColors.containerColorGrey,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.p16,
                vertical: AppSpacing.p16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.br12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.br12),
                borderSide: BorderSide(
                  color: AppColors.activeGreen.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.h16),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(presetColors.length, (index) {
                      final isLast = index == presetColors.length - 1;
                      return GestureDetector(
                        onTap: () => onColorSelected(index),
                        child: Container(
                          margin: EdgeInsets.only(
                            right: isLast ? 0 : AppSpacing.m8,
                          ),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: presetColors[index],
                            shape: BoxShape.circle,
                            border: selectedColorIndex == index
                                ? Border.all(
                                    color: theme.colorScheme.onSurface,
                                    width: 2.5,
                                  )
                                : null,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.w8),
              ElevatedButton(
                onPressed: onAddMember,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.activeGreen,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.p16,
                    vertical: AppSpacing.p12,
                  ),
                  elevation: 0,
                ),
                child: Text(
                  context.translate('add'),
                  style: AppTextStyles.bodyBold.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
