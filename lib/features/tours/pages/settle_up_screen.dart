import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';
import 'package:expense_tracker/core/models/tour_settlement.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';
import 'package:expense_tracker/core/utils/debt_simplifier.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';

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
      'BDT': '\u09F3', 'USD': r'$', 'EUR': '\u20AC', 'GBP': '\u00A3',
      'INR': '\u20B9', 'JPY': '\u00A5', 'AED': '\u062F.\u0625', 'CAD': r'$',
    };
    final tour = context.read<TourProvider>().selectedTour;
    final code = tour?.currency ?? 'USD';
    return symbols[code] ?? r'$';
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

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<TourProvider>();
    final balances = provider.netBalances(widget.tourId);
    final settlements = simplifyDebts(balances);
    final totalOutstanding = provider.totalOutstanding(widget.tourId);

    if (_checking) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: _buildAppBar(theme),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme),
      body: Stack(
        children: [
          _allSettled
              ? _buildAllSettled(theme)
              : _buildContent(theme, settlements, provider.participants, totalOutstanding),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [
                AppColors.activeGreen, Color(0xFF667eea), Color(0xFFf5576c),
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

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: theme.colorScheme.onSurface),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text('Settle Up', style: AppTextStyles.dialogTitle),
    );
  }

  Widget _buildContent(
    ThemeData theme,
    List<SimplifiedSettlement> settlements,
    List<TourParticipant> participants,
    double totalOutstanding,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.p16, AppSpacing.s8, AppSpacing.p16, 100),
      children: [
        _buildSummaryHeader(totalOutstanding),
        const SizedBox(height: AppSpacing.h24),
        ...settlements.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s16),
            child: _SettlementCard(
              theme: theme,
              fromName: _participantName(entry.value.fromParticipantId),
              toName: _participantName(entry.value.toParticipantId),
              fromColor: _avatarColor(entry.value.fromParticipantId),
              toColor: _avatarColor(entry.value.toParticipantId),
              fromInitials: _initials(_participantName(entry.value.fromParticipantId)),
              toInitials: _initials(_participantName(entry.value.toParticipantId)),
              amount: _formatAmount(entry.value.amount),
              onMarkSettled: () => _markSettled(entry.value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryHeader(double totalOutstanding) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.h24, horizontal: AppSpacing.p20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.br20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Total Outstanding',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            _formatAmount(totalOutstanding),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFamily: 'JetBrainsMono',
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.br30),
            ),
            child: const Text(
              'Outstanding balances to settle',
              style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllSettled(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.h32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSpacing.h80, height: AppSpacing.h80,
              decoration: BoxDecoration(
                color: AppColors.activeGreen.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, size: 44, color: AppColors.activeGreen),
            ),
            const SizedBox(height: AppSpacing.h20),
            Text('All Settled Up!', style: AppTextStyles.cardValueGreen),
            const SizedBox(height: AppSpacing.s8),
            Text(
              'Everyone is even. No outstanding debts.',
              textAlign: TextAlign.center,
              style: AppTextStyles.cardStatusText,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Premium Settlement Card ──────────────────────────────────────────────

class _SettlementCard extends StatelessWidget {
  final ThemeData theme;
  final String fromName;
  final String toName;
  final Color fromColor;
  final Color toColor;
  final String fromInitials;
  final String toInitials;
  final String amount;
  final VoidCallback onMarkSettled;

  const _SettlementCard({
    required this.theme,
    required this.fromName,
    required this.toName,
    required this.fromColor,
    required this.toColor,
    required this.fromInitials,
    required this.toInitials,
    required this.amount,
    required this.onMarkSettled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.p16, AppSpacing.p16, AppSpacing.p14, AppSpacing.p16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.br20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── From Avatar ──
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 24, backgroundColor: fromColor,
                child: Text(fromInitials, style: const TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: AppSpacing.s4),
              SizedBox(
                width: AppSpacing.w48,
                child: Text(
                  fromName,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFFDC3545)),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.w12),
          // ── Transfer Flow ──
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.swap_horiz_rounded, size: 22, color: Color(0xFF9CA3AF)),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.activeGreen,
                    fontFamily: 'JetBrainsMono',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.w12),
          // ── To Avatar ──
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 24, backgroundColor: toColor,
                child: Text(toInitials, style: const TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: AppSpacing.s4),
              SizedBox(
                width: AppSpacing.w48,
                child: Text(
                  toName,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.activeGreen),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.w8),
          // ── Settle Button ──
          SizedBox(
            height: 40,
            child: FilledButton(
              onPressed: onMarkSettled,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.activeGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.br30)),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16),
                elevation: 0,
              ),
              child: const Text('Settle', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
