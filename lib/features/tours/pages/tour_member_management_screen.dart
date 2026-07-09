import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

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
                  Icons.arrow_back_ios_new_rounded,
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
          // Add Member Section
          Container(
            margin: const EdgeInsets.all(AppSpacing.m16),
            padding: const EdgeInsets.all(AppSpacing.p16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSpacing.br8),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter member name',
                    hintStyle: AppTextStyles.textFieldHint,
                    border: InputBorder.none,
                    filled: true,
                    fillColor: theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : AppColors.containerColorGrey,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.p16,
                      vertical: AppSpacing.p14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.br12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.br12),
                      borderSide: BorderSide(
                        color: AppColors.activeGreen.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.h16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(_presetColors.length, (index) {
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedColorIndex = index),
                          child: Container(
                            margin: const EdgeInsets.only(right: AppSpacing.m8),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _presetColors[index],
                              shape: BoxShape.circle,
                              border: _selectedColorIndex == index
                                  ? Border.all(
                    color: theme.colorScheme.onSurface,
                                      width: 2.5,
                                    )
                                  : null,
                            ),
                          ),
                        );
                      }),
                    ),
                    ElevatedButton(
                      onPressed: _addMember,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.activeGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.br12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.p20,
                          vertical: AppSpacing.p12,
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Add',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Data Integrity Warning
          if (participants.length < 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.w8),
                  Flexible(
                    child: Text(
                      'Add buddies manually for offline tracking, or skip this and share the invite code later for real-time syncing!',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: AppFontSizes.size12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: AppSpacing.h16),

          // Members List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(AppSpacing.p16, 0, AppSpacing.p16, MediaQuery.of(context).padding.bottom + 16),
              itemCount: participants.length,
              itemBuilder: (context, index) {
                final member = participants[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.m12),
                  padding: const EdgeInsets.all(AppSpacing.p12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.br8),
                    // Using br12 instead of br16
                    border: Border.all(
                      color: AppColors.dividerColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: member.avatarColor != 0
                            ? Color(member.avatarColor)
                            : _presetColors[index % _presetColors.length],
                        child: Text(
                          member.name.isNotEmpty
                              ? member.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.w16),
                      Expanded(
                        child: Text(
                          member.name,
                          style: AppTextStyles.cardTitle.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontSize: AppFontSizes.size16,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.remove_circle_outline_rounded,
                          color: AppColors.activeRed.withValues(alpha: 0.8),
                        ),
                        onPressed: () => _removeMember(member.id),
                      ),
                    ],
                  ),
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
    final provider = context.read<TourProvider>();
    final member = provider.participants.firstWhere((p) => p.id == memberId);
    final balances = provider.netBalances(widget.tourId);
    final balance = balances[memberId] ?? 0;

    if (balance.abs() >= 0.01) {
      _showOutstandingBalanceDialog(member.name, balance, memberId);
      return;
    }

    _showConfirmRemoveDialog(member.name, memberId);
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
              context.read<TourProvider>().removeParticipant(memberId);
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
              context.read<TourProvider>().removeParticipant(memberId);
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
