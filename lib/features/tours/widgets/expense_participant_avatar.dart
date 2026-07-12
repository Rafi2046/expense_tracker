import 'package:flutter/material.dart';

const avatarColors = [
  Color(0xFF6366F1),
  Color(0xFFEC4899),
  Color(0xFF10B981),
  Color(0xFFF59E0B),
  Color(0xFF06B6D4),
  Color(0xFF8B5CF6),
  Color(0xFFEF4444),
  Color(0xFF14B8A6),
];

class ExpenseParticipantAvatar extends StatelessWidget {
  final String name;
  final Color color;
  final double radius;
  final double fontSize;
  final Color? textColor;
  final Color? backgroundColor;

  const ExpenseParticipantAvatar({
    super.key,
    required this.name,
    required this.color,
    this.radius = 14,
    this.fontSize = 10,
    this.textColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? color,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
