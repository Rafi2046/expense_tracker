import 'package:flutter/material.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';

class MemberAvatarStack extends StatelessWidget {
  final List<TourParticipant> participants;
  final Map<String, double> balances;
  final int maxDisplay;

  static const _avatarColors = [
    Color(0xFF667eea),
    Color(0xFFf5576c),
    Color(0xFF43e97b),
    Color(0xFFfa709a),
    Color(0xFF4facfe),
    Color(0xFFa18cd1),
    Color(0xFFfccb90),
    Color(0xFF38f9d7),
  ];

  const MemberAvatarStack({
    super.key,
    required this.participants,
    required this.balances,
    this.maxDisplay = 5,
  });

  Color _avatarColor(int index) {
    return _avatarColors[index % _avatarColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final display = participants.take(maxDisplay).toList();
    final overflow = participants.length - maxDisplay;

    return SizedBox(
      height: AppSpacing.h40,
      child: Stack(
        children: [
          for (var i = 0; i < display.length; i++)
            Positioned(
              left: i * 28.0,
              top: AppSpacing.s2,
              child: _SingleAvatar(
                participant: display[i],
                balance: balances[display[i].id] ?? 0,
                color: _avatarColor(i),
              ),
            ),
          if (overflow > 0)
            Positioned(
              left: display.length * 28.0,
              top: AppSpacing.s2,
              child: Container(
                width: AppSpacing.h40,
                height: AppSpacing.h40,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: AppSpacing.w2),
                ),
                child: Center(
                  child: Text(
                    '+$overflow',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SingleAvatar extends StatelessWidget {
  final TourParticipant participant;
  final double balance;
  final Color color;

  const _SingleAvatar({
    required this.participant,
    required this.balance,
    required this.color,
  });

  String get _initials {
    final parts = participant.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return participant.name.isNotEmpty
        ? participant.name[0].toUpperCase()
        : '?';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSpacing.h40,
      height: AppSpacing.h40,
      child: Stack(
        children: [
          Container(
            width: AppSpacing.h40,
            height: AppSpacing.h40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: AppSpacing.w2),
            ),
            child: Center(
              child: Text(
                _initials,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            right: AppSpacing.w1,
            bottom: AppSpacing.w1,
            child: Container(
              width: AppSpacing.w12,
              height: AppSpacing.w12,
              decoration: BoxDecoration(
                color: balance >= 0
                    ? AppColors.activeGreen
                    : AppColors.activeRed,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
