import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';
import 'package:expense_tracker/core/models/tour_settlement.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';
import 'package:expense_tracker/core/utils/debt_simplifier.dart';

class SettleUpScreen extends StatefulWidget {
  final String tourId;
  const SettleUpScreen({super.key, required this.tourId});

  @override
  State<SettleUpScreen> createState() => _SettleUpScreenState();
}

class _SettleUpScreenState extends State<SettleUpScreen> {
  late ConfettiController _confettiController;
  bool _allSettled = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(days: 365));
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await context.read<TourProvider>().selectTour(widget.tourId);
    if (!mounted) return;
    _checkAllSettled();
  }

  void _checkAllSettled() {
    final provider = context.read<TourProvider>();
    final balances = provider.netBalances(widget.tourId);
    final settlements = simplifyDebts(balances);
    final allZero = settlements.isEmpty;
    if (mounted) {
      setState(() {
        _allSettled = allZero;
        _checking = false;
      });
      if (allZero) {
        _confettiController.play();
      } else {
        _confettiController.stop();
      }
    }
  }

  Future<void> _markSettled(SimplifiedSettlement s) async {
    final provider = context.read<TourProvider>();
    await provider.addSettlement(TourSettlement(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      tourId: widget.tourId,
      fromParticipant: s.fromParticipantId,
      toParticipant: s.toParticipantId,
      amount: s.amount,
      date: DateTime.now(),
    ));
    _checkAllSettled();
  }

  String _currencySymbol() {
    const symbols = {
      'BDT': '৳', 'USD': '\$', 'EUR': '€', 'GBP': '£',
      'INR': '₹', 'JPY': '¥', 'AED': 'د.إ', 'CAD': '\$',
    };
    final tour = context.read<TourProvider>().selectedTour;
    final code = tour?.currency ?? 'USD';
    return symbols[code] ?? '\$';
  }

  String _formatAmount(double amount) {
    final symbol = _currencySymbol();
    final formatted = amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2);
    return '$symbol$formatted';
  }

  String _participantName(String id) {
    final provider = context.read<TourProvider>();
    final participants = provider.participants;
    final idx = participants.indexWhere((p) => p.id == id);
    return idx != -1 ? participants[idx].name : id;
  }

  Color _avatarColor(String id) {
    const colors = [
      Color(0xFF667eea), Color(0xFFf5576c), Color(0xFF43e97b),
      Color(0xFFfa709a), Color(0xFF4facfe), Color(0xFFa18cd1),
      Color(0xFFfccb90), Color(0xFF38f9d7),
    ];
    final provider = context.read<TourProvider>();
    final idx = provider.participants.indexWhere((p) => p.id == id);
    return colors[idx >= 0 ? idx % colors.length : id.hashCode % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<TourProvider>();
    final balances = provider.netBalances(widget.tourId);
    final settlements = simplifyDebts(balances);

    if (_checking) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: theme.colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Settle Up', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600)),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Settle Up', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600)),
      ),
      body: Stack(
        children: [
          _allSettled ? _buildAllSettled(theme) : _buildSettlementList(theme, settlements, provider.participants),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [
                Color(0xFF2EBD85), Color(0xFF667eea), Color(0xFFf5576c),
                Color(0xFF43e97b), Color(0xFFfa709a), Color(0xFF4facfe),
                Color(0xFFfccb90), Color(0xFF38f9d7),
              ],
              numberOfParticles: 20,
              emissionFrequency: 0.08,
              gravity: 0.3,
              strokeWidth: 2,
              shouldLoop: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementList(
      ThemeData theme, List<SimplifiedSettlement> settlements, List<TourParticipant> participants) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: settlements.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final s = settlements[index];
        return _SettlementCard(
          theme: theme,
          fromName: _participantName(s.fromParticipantId),
          toName: _participantName(s.toParticipantId),
          fromColor: _avatarColor(s.fromParticipantId),
          toColor: _avatarColor(s.toParticipantId),
          amount: _formatAmount(s.amount),
          onMarkSettled: () => _markSettled(s),
        );
      },
    );
  }

  Widget _buildAllSettled(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF2EBD85).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, size: 44, color: Color(0xFF2EBD85)),
            ),
            const SizedBox(height: 20),
            Text(
              'All Settled Up!',
              style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Everyone is even. No outstanding debts.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14, color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Settlement Card ──────────────────────────────────────────────────

class _SettlementCard extends StatelessWidget {
  final ThemeData theme;
  final String fromName;
  final String toName;
  final Color fromColor;
  final Color toColor;
  final String amount;
  final VoidCallback onMarkSettled;

  const _SettlementCard({
    required this.theme,
    required this.fromName,
    required this.toName,
    required this.fromColor,
    required this.toColor,
    required this.amount,
    required this.onMarkSettled,
  });

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 20, backgroundColor: fromColor,
            child: Text(_initials(fromName), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_rounded, color: theme.colorScheme.onSurfaceVariant, size: 18),
          const SizedBox(width: 8),
          CircleAvatar(radius: 20, backgroundColor: toColor,
            child: Text(_initials(toName), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$fromName owes $toName',
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 2),
                Text(amount, style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: const Color(0xFF2EBD85),
                  fontFamily: 'JetBrainsMono',
                )),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 36,
            child: FilledButton(
              onPressed: onMarkSettled,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2EBD85),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              child: const Text('Settle', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
