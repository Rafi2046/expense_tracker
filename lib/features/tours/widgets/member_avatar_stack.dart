import 'package:flutter/material.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';

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
      height: 44,
      child: Stack(
        children: [
          for (var i = 0; i < display.length; i++)
            Positioned(
              left: i * 28.0,
              top: 2,
              child: _SingleAvatar(
                participant: display[i],
                balance: balances[display[i].id] ?? 0,
                color: _avatarColor(i),
              ),
            ),
          if (overflow > 0)
            Positioned(
              left: display.length * 28.0,
              top: 2,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade700.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '+$overflow',
                    style: TextStyle(
                      color: Colors.grey.shade300,
                      fontSize: 11,
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
      width: 40,
      height: 40,
      child: Stack(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                _initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            right: 1,
            bottom: 1,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: balance >= 0
                    ? const Color(0xFF2EBD85)
                    : const Color(0xFFDC3545),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
