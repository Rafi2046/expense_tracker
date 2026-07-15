import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PremiumHeaderSection extends StatelessWidget {
  final VoidCallback onClose;

  const PremiumHeaderSection({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            onPressed: onClose,
            icon: Icon(
              LucideIcons.x,
              color: Colors.white.withValues(alpha: 0.6),
              size: 24,
            ),
          ),
        ),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF2EBD85), Color(0xFF1A8C5E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2EBD85).withValues(alpha: 0.4),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(
            LucideIcons.gem,
            color: Colors.white,
            size: 40,
            weight: 400,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Go Premium',
          style: TextStyle(
            fontSize: AppFontSizes.size28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Unlock the full power of your finance tracker',
          style: TextStyle(
            fontSize: AppFontSizes.size14,
            color: Colors.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
