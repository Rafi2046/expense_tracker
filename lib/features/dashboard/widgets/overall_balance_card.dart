import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OverallBalanceCard extends StatelessWidget {
  final double totalBalance;
  final bool showBalances;
  final VoidCallback onToggleBalances;

  const OverallBalanceCard({
    super.key,
    required this.totalBalance,
    required this.showBalances,
    required this.onToggleBalances,
  });

  String _formatAmount(double val) {
    final formatted = (val % 1 == 0)
        ? val.toStringAsFixed(0).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            )
        : val.toStringAsFixed(2).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            );
    return 'Tk. $formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0C4E3C), Color(0xFF1E8262)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C4E3C).withValues(alpha: 0.18),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overall Account Balance',
                style: GoogleFonts.workSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  showBalances ? _formatAmount(totalBalance) : 'Tk. ••••',
                  key: ValueKey<bool>(showBalances),
                  style: GoogleFonts.workSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: showBalances ? 0.3 : 1.5,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: onToggleBalances,
              child: Icon(
                showBalances ? Symbols.visibility : Symbols.visibility_off,
                color: Colors.white70,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
