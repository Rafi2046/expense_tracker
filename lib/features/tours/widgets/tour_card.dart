import 'dart:io';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/models/tour.dart';

class TourCard extends StatelessWidget {
  final Tour tour;
  final int memberCount;
  final double totalSpent;
  final VoidCallback onTap;
  final int index;

  static const _gradientPalette = [
    [Color(0xFF1E1B4B), Color(0xFF3730A3), Color(0xFF4338CA)],
    [Color(0xFF064E3B), Color(0xFF047857), Color(0xFF059669)],
    [Color(0xFF7C2D12), Color(0xFF9A3412), Color(0xFFC2410C)],
    [Color(0xFF1E3A5F), Color(0xFF1E40AF), Color(0xFF2563EB)],
    [Color(0xFF4C1D95), Color(0xFF6D28D9), Color(0xFF7C3AED)],
    [Color(0xFF5F0F40), Color(0xFF831843), Color(0xFFBE185D)],
    [Color(0xFF164E63), Color(0xFF155E75), Color(0xFF0891B2)],
    [Color(0xFF451A03), Color(0xFF78350F), Color(0xFFB45309)],
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
      'BDT': '৳', 'USD': r'$', 'EUR': '€', 'GBP': '£',
      'INR': '₹', 'JPY': '¥', 'AED': 'د.إ', 'CAD': r'$',
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
    final gradient = _gradient;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              if (hasCoverPhoto)
                Image.file(
                  File(tour.coverPhoto!),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildGradientBg(gradient),
                )
              else
                _buildGradientBg(gradient),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tour.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.person_outline_rounded, color: Colors.white.withValues(alpha: 0.7), size: 13),
                          const SizedBox(width: 4),
                          Text(
                            '$memberCount',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatAmount(totalSpent, tour.currency),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
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

  Widget _buildGradientBg(List<Color> gradient) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
