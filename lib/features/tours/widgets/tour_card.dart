import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/models/tour.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';

class TourCard extends StatelessWidget {
  final Tour tour;
  final int memberCount;
  final double totalSpent;
  final VoidCallback onTap;
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
              // Background: cover photo or gradient
              if (hasCoverPhoto)
                Image.file(
                  File(tour.coverPhoto!),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildGradientFallback(),
                )
              else
                _buildGradientFallback(),

              // Bottom gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 160,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),
              ),

              // Status chip — top right
              Positioned(
                top: 14,
                right: 14,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StatusBadge(isCompleted: tour.isCompleted),
                    if (onDelete != null || onToggleComplete != null) ...[
                      const SizedBox(width: 6),
                      _CardMenuButton(
                        isCompleted: tour.isCompleted,
                        onDelete: onDelete,
                        onToggleComplete: onToggleComplete,
                      ),
                    ],
                  ],
                ),
              ),

              // Bottom content — name, members, amount
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.p20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tour.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.workSans(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.people_alt_rounded,
                                color: Colors.white.withValues(alpha: 0.7),
                                size: 16,
                              ),
                              const SizedBox(width: AppSpacing.s6),
                              Text(
                                '$memberCount ${memberCount == 1 ? 'member' : 'members'}',
                                style: GoogleFonts.workSans(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Total spent',
                                style: GoogleFonts.workSans(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatAmount(totalSpent, tour.currency),
                                style: GoogleFonts.workSans(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientFallback() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isCompleted;

  const _StatusBadge({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    final dotColor = isCompleted ? const Color(0xFF9CA3AF) : const Color(0xFF4ADE80);
    final label = isCompleted ? 'Completed' : 'Active';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isCompleted ? 0.1 : 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: isCompleted ? 0.12 : 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.workSans(
              color: Colors.white.withValues(alpha: isCompleted ? 0.6 : 0.9),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardMenuButton extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleComplete;

  const _CardMenuButton({
    required this.isCompleted,
    this.onDelete,
    this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onSelected: (value) {
        if (value == 'toggleComplete') onToggleComplete?.call();
        if (value == 'delete') onDelete?.call();
      },
      itemBuilder: (context) => [
        if (onToggleComplete != null)
          PopupMenuItem(
            value: 'toggleComplete',
            child: Row(
              children: [
                Icon(
                  isCompleted ? Icons.radio_button_unchecked_rounded : Icons.check_circle_outline_rounded,
                  size: 18,
                  color: isCompleted ? const Color(0xFF6B7280) : const Color(0xFF4ADE80),
                ),
                const SizedBox(width: 8),
                Text(
                  isCompleted ? 'Mark as Active' : 'Mark as Completed',
                  style: TextStyle(
                    color: isCompleted ? const Color(0xFF6B7280) : const Color(0xFF4ADE80),
                  ),
                ),
              ],
            ),
          ),
        if (onDelete != null)
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFDC2626)),
                SizedBox(width: 8),
                Text('Delete Tour',
                    style: TextStyle(color: Color(0xFFDC2626))),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        child: const Icon(
          Icons.more_horiz_rounded,
          size: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}
