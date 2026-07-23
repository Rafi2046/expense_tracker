import 'package:flutter/material.dart';
import 'package:expense_tracker/core/models/tour.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

import 'tour_card_background.dart';
import 'tour_card_status_badge.dart';
import 'tour_card_menu_button.dart';
import 'tour_card_bottom_content.dart';

class TourCard extends StatelessWidget {
  final Tour tour;
  final int memberCount;
  final double totalSpent;
  final VoidCallback onTap;
  final bool isOwner;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleComplete;
  final int index;

  const TourCard({
    super.key,
    required this.tour,
    required this.memberCount,
    required this.totalSpent,
    required this.onTap,
    this.isOwner = true,
    this.onEdit,
    this.onDelete,
    this.onToggleComplete,
    this.index = 0,
  });

  static List<List<Color>> _gradientPalette(ColorScheme scheme) => [
        [scheme.primaryContainer, scheme.secondaryContainer, scheme.tertiaryContainer],
        [scheme.secondaryContainer, scheme.tertiaryContainer, scheme.errorContainer],
        [scheme.tertiaryContainer, scheme.errorContainer, scheme.surfaceContainerHighest],
        [scheme.errorContainer, scheme.surfaceContainerHighest, scheme.primaryContainer],
        [scheme.surfaceContainerHighest, scheme.primaryContainer, scheme.secondaryContainer],
        [scheme.primaryContainer, scheme.tertiaryContainer, scheme.surfaceContainerHighest],
        [scheme.secondaryContainer, scheme.errorContainer, scheme.primaryContainer],
        [scheme.tertiaryContainer, scheme.surfaceContainerHighest, scheme.secondaryContainer],
      ];

  List<Color> _gradientFor(ColorScheme scheme) =>
      _gradientPalette(scheme)[index % _gradientPalette(scheme).length];

  String _currencySymbol(String code) {
    const symbols = {
      'BDT': '\u09F3', 'USD': r'$', 'EUR': '\u20AC', 'GBP': '\u00A3',
      'INR': '\u20B9', 'JPY': '\u00A5', 'AED': '\u062F.\u0625', 'CAD': r'$',
    };
    return symbols[code] ?? r'$';
  }

  String _formatAmount(double amount, String currency) {
    final symbol = _currencySymbol(currency);
    if (amount == amount.roundToDouble()) {
      return '$symbol${amount.toStringAsFixed(0)}';
    }
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasCoverPhoto = tour.coverPhoto != null && tour.coverPhoto!.isNotEmpty;
    final totalLabel = context.translate('total_spent');
    final memberLabel = memberCount == 1
        ? context.translate('member')
        : context.translate('members');

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.r16),
        child: Stack(
          children: [
            TourCardBackground(
              coverPhoto: hasCoverPhoto ? tour.coverPhoto : null,
              gradient: _gradientFor(scheme),
            ),
            Positioned(
              top: 14,
              right: 14,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TourCardStatusBadge(isCompleted: tour.isCompleted),
                  if (onDelete != null || onToggleComplete != null || onEdit != null) ...[
                    const SizedBox(width: AppSpacing.s8),
                    TourCardMenuButton(
                      isCompleted: tour.isCompleted,
                      isOwner: isOwner,
                      onEdit: onEdit,
                      onDelete: onDelete,
                      onToggleComplete: onToggleComplete,
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.p16),
                child: TourCardBottomContent(
                  name: tour.name,
                  memberCount: memberCount,
                  totalSpentFormatted: _formatAmount(totalSpent, tour.currency),
                  totalLabel: totalLabel,
                  memberLabel: memberLabel,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
