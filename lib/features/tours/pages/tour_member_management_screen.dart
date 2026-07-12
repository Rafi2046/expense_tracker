import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';
import 'package:expense_tracker/features/tours/widgets/add_member_section.dart';
import 'package:expense_tracker/features/tours/widgets/data_integrity_warning.dart';
import 'package:expense_tracker/features/tours/widgets/member_tile.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TourMemberManagementScreen extends StatefulWidget {
  final String tourId;
  final bool isInitialSetup;

  const TourMemberManagementScreen({
    super.key,
    required this.tourId,
    this.isInitialSetup = false,
  });

  @override
  State<TourMemberManagementScreen> createState() =>
      _TourMemberManagementScreenState();
}

class _TourMemberManagementScreenState
    extends State<TourMemberManagementScreen> {
  final TextEditingController _nameController = TextEditingController();

  // Apple-style preset colors for avatars
  final List<Color> _presetColors = [
    const Color(0xFF007AFF), // iOS Blue
    const Color(0xFF34C759), // iOS Green
    const Color(0xFFFF9500), // iOS Orange
    const Color(0xFFFF2D55), // iOS Pink
    const Color(0xFFAF52DE), // iOS Purple
  ];
  int _selectedColorIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<TourProvider>();
    final participants = provider.participants;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: Border(
          bottom: BorderSide(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
        centerTitle: true,
        title: Text('Manage Members', style: AppTextStyles.appbarTitle.copyWith(color: theme.colorScheme.onSurface)),
        leading: widget.isInitialSetup
            ? const SizedBox.shrink()
            : IconButton(
                icon: Icon(
                  LucideIcons.arrowLeft,
                  color: theme.colorScheme.onSurface,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
        actions: [
          if (widget.isInitialSetup)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Done',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.activeGreen,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          AddMemberSection(
            nameController: _nameController,
            selectedColorIndex: _selectedColorIndex,
            presetColors: _presetColors,
            onColorSelected: (index) =>
                setState(() => _selectedColorIndex = index),
            onAddMember: _addMember,
          ),

          if (participants.length < 2)
            const DataIntegrityWarning(),

          const SizedBox(height: AppSpacing.h16),

          // Members List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(AppSpacing.p16, 0, AppSpacing.p16, MediaQuery.of(context).padding.bottom + 16),
              itemCount: participants.length,
              itemBuilder: (context, index) {
                final member = participants[index];
                return MemberTile(
                  member: member,
                  presetColors: _presetColors,
                  index: index,
                  onRemove: _removeMember,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addMember() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final provider = context.read<TourProvider>();
    final exists = provider.participants.any(
      (p) => p.name.toLowerCase() == name.toLowerCase(),
    );
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name is already added')),
      );
      return;
    }

    final int memberColor = _presetColors[_selectedColorIndex].toARGB32();

    final member = TourParticipant(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tourId: widget.tourId,
      name: name,
      avatarColor: memberColor,
      joinedAt: DateTime.now(),
    );

    provider.addParticipant(member);
    _nameController.clear();
  }

  void _removeMember(String memberId) {
    debugPrint('_removeMember called for: $memberId');
    try {
      final provider = context.read<TourProvider>();
      final member = provider.participants.firstWhere((p) => p.id == memberId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Removing ${member.name}...')),
        );
      }
      final balances = provider.netBalances(widget.tourId);
      final balance = balances[memberId] ?? 0;

      if (balance.abs() >= 0.01) {
        _showOutstandingBalanceDialog(member.name, balance, memberId);
        return;
      }

      _showConfirmRemoveDialog(member.name, memberId);
    } catch (e) {
      debugPrint('_removeMember error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showOutstandingBalanceDialog(
    String name,
    double balance,
    String memberId,
  ) {
    final owesOrOwed = balance > 0 ? 'is owed' : 'owes';
    final amount = balance.abs().toStringAsFixed(2);
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.br8),
        ),
        backgroundColor: theme.colorScheme.surface,
        title: Text('Outstanding Balance', style: AppTextStyles.dialogTitle.copyWith(color: theme.colorScheme.onSurface)),
        content: Text(
          '$name $owesOrOwed $amount in this tour. Removing them now will make this amount disappear from everyone\'s calculation — it won\'t be settled.\n\nSettle up first, or remove anyway?',
          style: AppTextStyles.dialogBody.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<TourProvider>().removeParticipant(memberId).catchError((e) {
                debugPrint('removeParticipant error: $e');
                if (context.mounted) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              });
            },
            child: const Text(
              'Remove Anyway',
              style: TextStyle(
                color: AppColors.activeRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmRemoveDialog(String name, String memberId) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.br8),
        ),
        backgroundColor: theme.colorScheme.surface,
        title: Text('Remove Member', style: AppTextStyles.dialogTitle.copyWith(color: theme.colorScheme.onSurface)),
        content: Text(
          'Remove $name from this tour?',
          style: AppTextStyles.dialogBody.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<TourProvider>().removeParticipant(memberId).catchError((e) {
                debugPrint('removeParticipant error: $e');
                if (context.mounted) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              });
            },
            child: const Text(
              'Remove',
              style: TextStyle(
                color: AppColors.activeRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
