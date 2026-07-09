import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';
import 'package:expense_tracker/core/models/tour_settlement.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';
import 'package:expense_tracker/core/utils/debt_simplifier.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

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
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: Border(
        bottom: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.08)),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: theme.colorScheme.onSurface),
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
              onTap: () => _showSettlementDetail(theme, entry.value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryHeader(double totalOutstanding) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Total Outstanding',
            style: TextStyle(
              fontSize: AppFontSizes.size12,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _formatAmount(totalOutstanding),
            style: const TextStyle(
              fontSize: AppFontSizes.size32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFamily: 'JetBrainsMono',
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Outstanding balances to settle',
              style: TextStyle(fontSize: AppFontSizes.size10, color: Colors.white70, fontWeight: FontWeight.w500),
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

  void _showSettlementDetail(ThemeData theme, SimplifiedSettlement s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SettlementDetailSheet(
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
  final VoidCallback onTap;

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
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // ── From Avatar ──
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 20, backgroundColor: fromColor,
                child: Text(fromInitials, style: const TextStyle(color: AppColors.white, fontSize: AppFontSizes.size11, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: 44,
                child: Text(
                  fromName,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: AppFontSizes.size10, fontWeight: FontWeight.w500, color: isDark ? Colors.white70 : const Color(0xFFDC3545)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          // ── Transfer Flow ──
          Expanded(
            child: Column(
              children: [
                Icon(Icons.swap_horiz_rounded, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                const SizedBox(height: 2),
                Text(
                  amount,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: AppFontSizes.size16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.activeGreen,
                  ),
                ),
              ],
              ),
            ),
          const SizedBox(width: 8),
          // ── To Avatar ──
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 20, backgroundColor: toColor,
                child: Text(toInitials, style: const TextStyle(color: AppColors.white, fontSize: AppFontSizes.size11, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: 44,
                child: Text(
                  toName,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: AppFontSizes.size10, fontWeight: FontWeight.w500, color: AppColors.activeGreen),
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
          // ── Settle Button ──
          SizedBox(
            height: 36,
            child: FilledButton(
              onPressed: onMarkSettled,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.activeGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                elevation: 0,
              ),
              child: const Text('Settle', style: TextStyle(fontSize: AppFontSizes.size12, fontWeight: FontWeight.w700, color: AppColors.white)),
            ),
          ),
        ],
      ),
      ),
      ),
    );
  }
}

// ─── Settlement Detail Sheet ──────────────────────────────────────────────

class _SettlementDetailSheet extends StatelessWidget {
  final ThemeData theme;
  final String fromName;
  final String toName;
  final Color fromColor;
  final Color toColor;
  final String fromInitials;
  final String toInitials;
  final String amount;
  final VoidCallback onMarkSettled;

  const _SettlementDetailSheet({
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
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Gradient amount header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('SETTLEMENT AMOUNT',
                    style: TextStyle(fontSize: AppFontSizes.size10, fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 6),
                  Text(amount,
                    style: GoogleFonts.jetBrainsMono(fontSize: AppFontSizes.size36, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // From → To transfer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // From
                  Expanded(
                    child: Column(
                      children: [
                        CircleAvatar(radius: 28, backgroundColor: fromColor,
                          child: Text(fromInitials, style: const TextStyle(color: Colors.white, fontSize: AppFontSizes.size14, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(height: 6),
                        Text(fromName, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.workSans(fontSize: AppFontSizes.size13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                        ),
                        const SizedBox(height: 2),
                        Text('pays',
                          style: GoogleFonts.workSans(fontSize: AppFontSizes.size11, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                        ),
                      ],
                    ),
                  ),
                  // Arrow
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.activeGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_forward_rounded, color: AppColors.activeGreen, size: 24),
                  ),
                  const SizedBox(width: 16),
                  // To
                  Expanded(
                    child: Column(
                      children: [
                        CircleAvatar(radius: 28, backgroundColor: toColor,
                          child: Text(toInitials, style: const TextStyle(color: Colors.white, fontSize: AppFontSizes.size14, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(height: 6),
                        Text(toName, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.workSans(fontSize: AppFontSizes.size13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                        ),
                        const SizedBox(height: 2),
                        Text('receives',
                          style: GoogleFonts.workSans(fontSize: AppFontSizes.size11, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Mark as Settled button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: onMarkSettled,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.activeGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Mark as Settled',
                    style: TextStyle(fontSize: AppFontSizes.size15, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
