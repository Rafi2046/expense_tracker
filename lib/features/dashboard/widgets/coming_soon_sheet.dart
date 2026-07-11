import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ComingSoonSheet extends StatelessWidget {
  const ComingSoonSheet({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const ComingSoonSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.rocket, size: 40, color: Color(0xFF7C3AED)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Business Management\nis Coming Soon!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: AppFontSizes.size18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          const Text(
            'We\'re working hard to bring you business management features. Stay tuned!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: AppFontSizes.size13, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Got It', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
