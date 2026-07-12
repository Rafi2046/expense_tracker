import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/settings/widgets/info_row_tile.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PersonalInfoDetailsCard extends StatelessWidget {
  final String phone;
  final String dob;
  final String gender;
  final String email;

  const PersonalInfoDetailsCard({
    super.key,
    required this.phone,
    required this.dob,
    required this.gender,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = Theme.of(context).cardColor;
    final borderColor = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF1F1F1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'PERSONAL DETAILS',
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: borderColor, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            children: [
              InfoRowTile(
                icon: LucideIcons.phoneCall,
                label: 'Phone Number',
                value: phone,
              ),
              Divider(height: 1, color: borderColor),
              InfoRowTile(
                icon: LucideIcons.calendar,
                label: 'Date of Birth',
                value: dob,
              ),
              Divider(height: 1, color: borderColor),
              InfoRowTile(
                icon: gender == 'Male' ? LucideIcons.mars : LucideIcons.venus,
                label: 'Gender',
                value: gender,
              ),
              Divider(height: 1, color: borderColor),
              InfoRowTile(
                icon: LucideIcons.mail,
                label: 'Email Address',
                value: email,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
