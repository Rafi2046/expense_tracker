import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

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

  Color _avatarColor(ColorScheme scheme, int index) {
    final colors = [
      scheme.primary,
      scheme.secondary,
      scheme.tertiary,
      scheme.error,
      scheme.primaryContainer,
      scheme.secondaryContainer,
      scheme.tertiaryContainer,
      scheme.surfaceContainerHighest,
    ];
    return colors[index % colors.length];
  }

  Color _avatarTextColor(ColorScheme scheme, Color avatarBg) {
    if (avatarBg == scheme.primaryContainer ||
        avatarBg == scheme.secondaryContainer ||
        avatarBg == scheme.tertiaryContainer ||
        avatarBg == scheme.surfaceContainerHighest) {
      return scheme.onPrimaryContainer;
    }
    return scheme.onPrimary;
  }

  ImageProvider? _getParticipantImage(TourParticipant p) {
    String? url = p.photoUrl;
    final currentUser = FirebaseAuth.instance.currentUser;
    if ((url == null || url.isEmpty) && p.uid != null && currentUser != null && p.uid == currentUser.uid) {
      url = currentUser.photoURL ?? SharedPrefsHelper.getString('local_profile_photo_${currentUser.uid}');
    }
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('http')) {
        return NetworkImage(url);
      } else if (File(url).existsSync()) {
        return FileImage(File(url));
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasDebts = outstanding > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            context.translate('balances_label'),
            style: AppTextStyles.h2.copyWith(color: scheme.onSurface),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scheme.outline,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.onSurface.withValues(alpha: 0.06),
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
                      context: context,
                      scheme: scheme,
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
                        color: scheme.outlineVariant,
                      ),
                  ],
                );
              }),
              if (hasDebts) ...[
                Divider(
                  height: 1,
                  thickness: 1,
                  color: scheme.outlineVariant,
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
                      color: scheme.primaryContainer.withValues(alpha: 0.5),
                      border: Border(
                        top: BorderSide(color: scheme.primary.withValues(alpha: 0.3), width: 1),
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.handshake,
                          size: 16,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.translate('settle_up_balances'),
                          style: AppTextStyles.cardTrendGreen.copyWith(color: scheme.primary),
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
    required BuildContext context,
    required ColorScheme scheme,
    required TourParticipant p,
    required int index,
    required double balance,
  }) {
    final isOwed = balance > 0;
    final isSettled = balance == 0;
    final avatarBg = _avatarColor(scheme, index);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: avatarBg,
            backgroundImage: _getParticipantImage(p),
            child: _getParticipantImage(p) == null
                ? Text(
                    p.name.isNotEmpty ? String.fromCharCode(p.name.runes.first).toUpperCase() : '?',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _avatarTextColor(scheme, avatarBg),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              p.name,
              style: AppTextStyles.bodyBold.copyWith(
                fontSize: AppFontSizes.size15,
                color: scheme.onSurface,
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
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                context.translate('settled_label'),
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurfaceVariant,
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
                color: scheme.primaryContainer.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                context.translate('gets_back_amount', namedArgs: {'amount': formatAmount(balance)}),
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
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
                color: scheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                context.translate('owes_amount', namedArgs: {'amount': formatAmount(balance.abs())}),
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
