import 'package:flutter/material.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';

class TourMemberBalances extends StatelessWidget {
  final List<TourParticipant> participants;
  final Map<String, double> balances;
  final String currency;
  final double outstanding;
  final String Function(double) formatAmount;
  final VoidCallback onSettleUp;

  const TourMemberBalances({
    super.key,
    required this.participants,
    required this.balances,
    required this.currency,
    required this.outstanding,
    required this.formatAmount,
    required this.onSettleUp,
  });

  Color _avatarColor(int index) {
    if (index < 0) return const Color(0xFF6366F1);
    const colors = [
      Color(0xFF6366F1),
      Color(0xFFEC4899),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFF06B6D4),
      Color(0xFF8B5CF6),
      Color(0xFFEF4444),
      Color(0xFF14B8A6),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDebts = outstanding > 0;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Balances',
            style: AppTextStyles.h2.copyWith(color: theme.colorScheme.onSurface),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF2D2D3D) : const Color(0xFFF1F5F9),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...participants.asMap().entries.map((entry) {
                final idx = entry.key;
                final participant = entry.value;
                final isLast = idx == participants.length - 1;

                return Column(
                  children: [
                    _buildMemberBalanceRow(
                      theme: theme,
                      p: participant,
                      index: idx,
                      balance: balances[participant.id] ?? 0,
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        thickness: 1,
                        indent: 52,
                        endIndent: 16,
                        color: isDark ? const Color(0xFF2D2D3D) : const Color(0xFFF1F5F9),
                      ),
                  ],
                );
              }),
              if (hasDebts) ...[
                Divider(
                  height: 1,
                  thickness: 1,
                  color: isDark ? const Color(0xFF2D2D3D) : const Color(0xFFF1F5F9),
                ),
                InkWell(
                  onTap: onSettleUp,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.1) : const Color(0xFFF0FDF4),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.handshake_outlined,
                          size: 16,
                          color: Color(0xFF10B981),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Settle Up Balances',
                          style: AppTextStyles.cardTrendGreen,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMemberBalanceRow({
    required ThemeData theme,
    required TourParticipant p,
    required int index,
    required double balance,
  }) {
    final isOwed = balance > 0;
    final isSettled = balance == 0;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: _avatarColor(index),
            child: Text(
              p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              p.name,
              style: AppTextStyles.bodyBold.copyWith(
                fontSize: AppFontSizes.size15,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (isSettled)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2D2D3D) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Settled',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            )
          else if (isOwed)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.2) : AppColors.selectionGreenBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Gets back ${formatAmount(balance)}',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.activeGreen,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.2) : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Owes ${formatAmount(balance.abs())}',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.activeRed,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
