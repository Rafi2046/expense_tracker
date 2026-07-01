import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:expense_tracker/core/models/tour.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';
import 'package:expense_tracker/core/utils/debt_simplifier.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';

class TourExportService {
  static Future<void> shareReport(BuildContext context, String tourId) async {
    final provider = context.read<TourProvider>();
    final tour = provider.tours.firstWhere((t) => t.id == tourId);
    final participants = provider.participants;
    final netBalances = provider.netBalances(tourId);
    final totalSpent = provider.totalSpent(tourId);
    final totalOutstanding = provider.totalOutstanding(tourId);
    final settlements = simplifyDebts(netBalances);

    final controller = ScreenshotController();
    final receiptWidget = _buildReceipt(tour, participants, settlements, totalSpent, totalOutstanding);

    final imageBytes = await controller.captureFromWidget(
      Material(child: receiptWidget),
      pixelRatio: 3.0,
    );

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/tour_report_${tour.id.substring(max(0, tour.id.length - 8))}.png',
    );
    await file.writeAsBytes(imageBytes);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: '${tour.name} — Settlement Report',
      ),
    );
  }

  static Widget _buildReceipt(
    Tour tour,
    List<TourParticipant> participants,
    List<SimplifiedSettlement> settlements,
    double totalSpent,
    double totalOutstanding,
  ) {
    final pById = {for (final p in participants) p.id: p.name};

    return Container(
      width: 420,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Header Badge ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text(
              'SETTLEMENT REPORT',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 2.5,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Tour Name ──
          Text(
            tour.name,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
              fontFamily: 'WorkSans',
            ),
          ),
          const SizedBox(height: 16),

          // ── Total Spent Highlight Box ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2EBD85).withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                const Text(
                  'TOTAL SPENT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatAmount(totalSpent, tour.currency),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF059669),
                    fontFamily: 'JetBrainsMono',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Outstanding ──
          if (settlements.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'OUTSTANDING',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _formatAmount(totalOutstanding, tour.currency),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFDC3545),
                      fontFamily: 'JetBrainsMono',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(height: 1, color: const Color(0xFFE5E7EB)),
            const SizedBox(height: 20),
          ],

          // ── Settlement List ──
          if (settlements.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Icon(Icons.check_circle_rounded, color: Color(0xFF2EBD85), size: 36),
                  SizedBox(height: 12),
                  Text(
                    'All settled up — no payments needed',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            )
          else
            ...settlements.asMap().entries.map((entry) {
              final i = entry.key;
              final s = entry.value;
              final from = pById[s.fromParticipantId] ?? 'Unknown';
              final to = pById[s.toParticipantId] ?? 'Unknown';
              final isLast = i == settlements.length - 1;

              return Column(
                children: [
                  Row(
                    children: [
                      // ── From ──
                      Expanded(
                        flex: 3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: _avatarColor(i),
                              child: Text(
                                from.isNotEmpty ? from[0].toUpperCase() : '?',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                from,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFDC3545)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ── Arrow + Amount ──
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF9CA3AF)),
                            const SizedBox(height: 2),
                            Text(
                              _formatAmount(s.amount, tour.currency),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF059669),
                                fontFamily: 'JetBrainsMono',
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ── To ──
                      Expanded(
                        flex: 3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                to,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2EBD85)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: _avatarColor(i + settlements.length),
                              child: Text(
                                to.isNotEmpty ? to[0].toUpperCase() : '?',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (!isLast) ...[
                    const SizedBox(height: 14),
                    Container(height: 1, color: const Color(0xFFF3F4F6)),
                    const SizedBox(height: 14),
                  ],
                ],
              );
            }),

          // ── Divider ──
          if (settlements.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(height: 1.5, color: const Color(0xFFE5E7EB)),
            const SizedBox(height: 20),
          ],

          // ── Footer Watermark ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_balance_wallet_rounded, size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 6),
              Text(
                'Generated via Expense Tracker  \u2022  Shared Expenses Simplified',
                style: TextStyle(
                  fontSize: 9.5,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Color _avatarColor(int index) {
    const colors = [
      Color(0xFF667eea), Color(0xFFf5576c), Color(0xFF43e97b),
      Color(0xFFfa709a), Color(0xFF4facfe), Color(0xFFa18cd1),
      Color(0xFFfccb90), Color(0xFF38f9d7),
    ];
    return colors[index % colors.length];
  }

  static String _formatAmount(double amount, String currency) {
    const symbols = {
      'BDT': '\u09F3', 'USD': r'$', 'EUR': '\u20AC', 'GBP': '\u00A3',
      'INR': '\u20B9', 'JPY': '\u00A5', 'AED': '\u062F.\u0625', 'CAD': r'$',
    };
    final sym = symbols[currency] ?? r'$';
    if (amount == amount.roundToDouble()) {
      return '$sym${amount.toStringAsFixed(0)}';
    }
    return '$sym${amount.toStringAsFixed(2)}';
  }
}
