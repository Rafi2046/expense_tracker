import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class GenderSelectorSection extends StatelessWidget {
  final String selectedGender;
  final ValueChanged<String> onGenderChanged;

  const GenderSelectorSection({
    super.key,
    required this.selectedGender,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final inputBg = isDark ? theme.cardColor : const Color(0xFFF5F6F8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade400 : Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: ['Male', 'Female'].map((gender) {
            final isSelected = selectedGender == gender;
            final genderIcon = gender == 'Male' ? LucideIcons.mars : LucideIcons.venus;
            final activeColor = gender == 'Male' ? const Color(0xFF1E88E5) : const Color(0xFFD81B60);

            return Expanded(
              child: GestureDetector(
                onTap: () => onGenderChanged(gender),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(
                    right: gender == 'Male' ? 6.0 : 0.0,
                    left: gender == 'Female' ? 6.0 : 0.0,
                  ),
                  height: 46,
                  decoration: BoxDecoration(
                    color: isSelected ? activeColor : inputBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? activeColor : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 16,
                        child: Icon(
                          genderIcon,
                          color: isSelected ? Colors.white : activeColor,
                          size: 18,
                        ),
                      ),
                      Text(
                        gender,
                        style: AppTextStyles.bodyBold.copyWith(
                          color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
