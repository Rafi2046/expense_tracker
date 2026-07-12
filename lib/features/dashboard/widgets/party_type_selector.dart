import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class PartyTypeSelector extends StatelessWidget {
  final bool isReceive;
  final ValueChanged<bool> onToggleChanged;

  const PartyTypeSelector({
    super.key,
    required this.isReceive,
    required this.onToggleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildAnimatedPill(
          context: context,
          label: 'To Receive',
          isActive: isReceive,
          onTap: () => onToggleChanged(true),
        ),
        const SizedBox(width: 12),
        _buildAnimatedPill(
          context: context,
          label: 'To Give',
          isActive: !isReceive,
          onTap: () => onToggleChanged(false),
        ),
      ],
    );
  }

  Widget _buildAnimatedPill({
    required BuildContext context,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? theme.primaryColor : (isDark ? Colors.white10 : const Color(0xFFF1F2F4)),
            borderRadius: BorderRadius.circular(20),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: theme.primaryColor.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: GoogleFonts.workSans(
              fontSize: AppFontSizes.size12,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : (isDark ? Colors.white60 : const Color(0xFF31394D)),
            ),
          ),
        ),
      ),
    );
  }
}
