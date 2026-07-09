import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class InviteCodeCard extends StatelessWidget {
  final String inviteCode;
  final String tourName;

  const InviteCodeCard({
    super.key,
    required this.inviteCode,
    required this.tourName,
  });

  String get _formattedCode {
    return inviteCode; // continuous, no gaps
  }

  void _onCopy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: inviteCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Code copied: $inviteCode')),
    );
  }

  void _onShare() {
    SharePlus.instance.share(
      ShareParams(
        text: 'Join my tour "$tourName" on Expense Tracker!\n\n'
            'Use invite code: $inviteCode',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : AppColors.activeGreen.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.activeGreen.withValues(alpha: 0.12),
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invite Code',
                  style: GoogleFonts.workSans(
                    fontSize: AppFontSizes.size11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formattedCode,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: AppFontSizes.size24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: AppColors.activeGreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _IconButton(
            icon: Icons.copy_rounded,
            onTap: () => _onCopy(context),
            tooltip: 'Copy',
          ),
          const SizedBox(width: 8),
          _IconButton(
            icon: Icons.share_rounded,
            onTap: _onShare,
            tooltip: 'Share',
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _IconButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.activeGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: AppColors.activeGreen),
        ),
      ),
    );
  }
}
