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
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/features/tours/widgets/settle_up_payment_tile.dart';
import 'package:expense_tracker/features/tours/widgets/settle_up_member_balance_list.dart';
import 'package:expense_tracker/features/tours/widgets/settle_up_payment_method_selector.dart';

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
    if (parts.length >= 2) {
      final f = parts.first.runes.isNotEmpty ? String.fromCharCode(parts.first.runes.first) : '';
      final l = parts.last.runes.isNotEmpty ? String.fromCharCode(parts.last.runes.first) : '';
      return '$f$l'.toUpperCase();
    }
    return name.isNotEmpty ? String.fromCharCode(name.runes.first).toUpperCase() : '?';
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
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: Border(
        bottom: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.08)),
      ),
      leading: IconButton(
        icon: Icon(LucideIcons.arrowLeft, color: theme.colorScheme.onSurface),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text('Settle Up', style: AppTextStyles.dialogTitle.copyWith(color: theme.colorScheme.onSurface)),
    );
  }

  Widget _buildContent(
    ThemeData theme,
    List<SimplifiedSettlement> settlements,
    List<TourParticipant> participants,
    double totalOutstanding,
  ) {
    final tiles = settlements.map((s) => SettleUpPaymentTile(
      theme: theme,
      fromName: _participantName(s.fromParticipantId),
      toName: _participantName(s.toParticipantId),
      fromColor: _avatarColor(s.fromParticipantId),
      toColor: _avatarColor(s.toParticipantId),
      fromInitials: _initials(_participantName(s.fromParticipantId)),
      toInitials: _initials(_participantName(s.toParticipantId)),
      amount: _formatAmount(s.amount),
      onMarkSettled: () => _markSettled(s),
      onTap: () => _showSettlementDetail(theme, s),
    )).toList();

    return SettleUpMemberBalanceList(
      formattedTotalOutstanding: _formatAmount(totalOutstanding),
      settlementTiles: tiles,
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
              child: Icon(LucideIcons.checkCircle, size: 44, color: AppColors.activeGreen),
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

  void _showSettlementDetail(ThemeData theme, SimplifiedSettlement s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SettleUpPaymentMethodSelector(
        theme: theme,
        fromName: _participantName(s.fromParticipantId),
        toName: _participantName(s.toParticipantId),
        fromColor: _avatarColor(s.fromParticipantId),
        toColor: _avatarColor(s.toParticipantId),
        fromInitials: _initials(_participantName(s.fromParticipantId)),
        toInitials: _initials(_participantName(s.toParticipantId)),
        amount: _formatAmount(s.amount),
        onMarkSettled: () {
          Navigator.pop(ctx);
          _markSettled(s);
        },
      ),
    );
  }
}


