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
  final VoidCallback? onDelete;
  final VoidCallback? onToggleComplete;
  final int index;

  static const _gradientPalette = [
    [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
    [Color(0xFF0D2B1D), Color(0xFF1A6B47), Color(0xFF064E3B)],
    [Color(0xFF2D0A0A), Color(0xFF7F1D1D), Color(0xFF450A0A)],
    [Color(0xFF0C1F3F), Color(0xFF1E3A8A), Color(0xFF1E1B4B)],
    [Color(0xFF2D0A4E), Color(0xFF581C87), Color(0xFF3B0764)],
    [Color(0xFF2D0A1C), Color(0xFF831843), Color(0xFF4C0519)],
    [Color(0xFF0A2E3F), Color(0xFF0E7490), Color(0xFF164E63)],
    [Color(0xFF2D1A0A), Color(0xFF92400E), Color(0xFF451A03)],
  ];

  const TourCard({
    super.key,
    required this.tour,
    required this.memberCount,
    required this.totalSpent,
    required this.onTap,
    this.isOwner = true,
    this.onDelete,
    this.onToggleComplete,
    this.index = 0,
  });

  List<Color> get _gradient => _gradientPalette[index % _gradientPalette.length];

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
    final hasCoverPhoto = tour.coverPhoto != null && tour.coverPhoto!.isNotEmpty;
    final totalLabel = context.translate('total_spent');
    final memberLabel = memberCount == 1
        ? context.translate('member')
        : context.translate('members');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              TourCardBackground(
                coverPhoto: hasCoverPhoto ? tour.coverPhoto : null,
                gradient: _gradient,
              ),
              Positioned(
                top: 14,
                right: 14,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TourCardStatusBadge(isCompleted: tour.isCompleted),
                    if (onDelete != null || onToggleComplete != null) ...[
                      const SizedBox(width: 6),
                      TourCardMenuButton(
                        isCompleted: tour.isCompleted,
                        isOwner: isOwner,
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
                  padding: const EdgeInsets.all(AppSpacing.p20),
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
      ),
    );
  }
}
