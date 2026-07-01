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
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
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
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 200,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.95),
                      ],
                    ),
                  ),
                ),
              ),
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
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          letterSpacing: -0.5,
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
                                color: Colors.white70,
                                size: 18,
                              ),
                              const SizedBox(width: AppSpacing.s6),
                              Text(
                                '$memberCount ${memberCount == 1 ? 'member' : 'members'}',
                                style: GoogleFonts.workSans(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _formatAmount(totalSpent, tour.currency),
                            style: GoogleFonts.workSans(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
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
