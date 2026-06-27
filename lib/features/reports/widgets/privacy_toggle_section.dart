import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyToggleSection extends StatelessWidget {
  final bool isMasked;
  final VoidCallback onToggle;

  const PrivacyToggleSection({
    super.key,
    required this.isMasked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE8EAEE),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFEEF0F4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isMasked ? Symbols.lock_rounded : Symbols.lock_open_rounded,
              size: 16,
              color: isDark ? Colors.white60 : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isMasked ? 'Amounts hidden' : 'Amounts visible',
              style: GoogleFonts.workSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : const Color(0xFF374151),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onToggle();
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFEEF0F4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isMasked ? Symbols.visibility_off : Symbols.visibility,
                size: 20,
                color: isDark ? Colors.white70 : const Color(0xFF4B5563),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
