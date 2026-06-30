import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/models/tour.dart';

class TourCard extends StatelessWidget {
  final Tour tour;
  final int memberCount;
  final double totalSpent;
  final VoidCallback onTap;
  final int index;

  static const _gradientPalette = [
    [Color(0xFF667eea), Color(0xFF764ba2)],
    [Color(0xFFf093fb), Color(0xFFf5576c)],
    [Color(0xFF4facfe), Color(0xFF00f2fe)],
    [Color(0xFF43e97b), Color(0xFF38f9d7)],
    [Color(0xFFfa709a), Color(0xFFfee140)],
    [Color(0xFFa18cd1), Color(0xFFfbc2eb)],
    [Color(0xFFfccb90), Color(0xFFd57eeb)],
    [Color(0xFFe0c3fc), Color(0xFF8ec5fc)],
  ];

  const TourCard({
    super.key,
    required this.tour,
    required this.memberCount,
    required this.totalSpent,
    required this.onTap,
    this.index = 0,
  });

  List<Color> get _gradient {
    final palette = _gradientPalette;
    return palette[index % palette.length];
  }

  String _currencySymbol(String code) {
    const symbols = {
      'BDT': '৳',
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'INR': '₹',
      'JPY': '¥',
      'AED': 'د.إ',
      'CAD': '\$',
    };
    return symbols[code] ?? '\$';
  }

  String _formatAmount(double amount, String currency) {
    final symbol = _currencySymbol(currency);
    final formatted = amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2);
    return '$symbol$formatted';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                      ),
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tour.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              fontFamily: 'WorkSans',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                color: Colors.white70,
                                size: 13,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '$memberCount',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _formatAmount(totalSpent, tour.currency),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
