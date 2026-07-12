import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/features/tours/widgets/expense_participant_avatar.dart';

class ExpenseParticipantSelector extends StatelessWidget {
  final ThemeData theme;
  final List<TourParticipant> participants;
  final String paidById;
  final ValueChanged<String> onPayerSelected;

  const ExpenseParticipantSelector({
    super.key,
    required this.theme,
    required this.participants,
    required this.paidById,
    required this.onPayerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: participants.asMap().entries.map((entry) {
          final p = entry.value;
          final selected = p.id == paidById;
          final index = entry.key;
          final color = avatarColors[index % avatarColors.length];
          return Padding(
            padding: EdgeInsets.only(
              right: index < participants.length - 1 ? 8 : 0,
            ),
            child: GestureDetector(
              onTap: () => onPayerSelected(p.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? color : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ExpenseParticipantAvatar(
                      name: p.name,
                      color: color,
                      radius: 14,
                      fontSize: AppFontSizes.size11,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      p.name.split(' ').first,
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withValues(alpha: selected ? 1 : 0.6),
                      ),
                    ),
                    if (selected) ...[
                      const SizedBox(width: 4),
                      Icon(LucideIcons.checkCircle, size: 14, color: AppColors.activeGreen),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
