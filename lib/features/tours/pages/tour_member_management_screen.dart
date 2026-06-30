import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';

class TourMemberManagementScreen extends StatefulWidget {
  final String tourId;
  final bool isInitialSetup;

  const TourMemberManagementScreen({
    super.key,
    required this.tourId,
    this.isInitialSetup = false,
  });

  @override
  State<TourMemberManagementScreen> createState() => _TourMemberManagementScreenState();
}

class _TourMemberManagementScreenState extends State<TourMemberManagementScreen> {
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
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Manage Members',
          style: AppTextStyles.appbarTitle,
        ),
        leading: widget.isInitialSetup
            ? const SizedBox.shrink()
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.black, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
        actions: [
          if (widget.isInitialSetup)
            TextButton(
              onPressed: participants.length >= 2 ? () => Navigator.pop(context) : null,
              child: Text(
                'Done',
                style: TextStyle(
                  color: participants.length >= 2 ? AppColors.activeGreen : AppColors.textMuted,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
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
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.br20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.04),
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
                    fillColor: AppColors.containerColorGrey,
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.br12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.br12),
                      borderSide: BorderSide(color: AppColors.activeGreen.withValues(alpha: 0.5), width: 1.5),
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
                          onTap: () => setState(() => _selectedColorIndex = index),
                          child: Container(
                            margin: const EdgeInsets.only(right: AppSpacing.m8),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _presetColors[index],
                              shape: BoxShape.circle,
                              border: _selectedColorIndex == index
                                  ? Border.all(color: AppColors.black, width: 2.5)
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.br12)),
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p20, vertical: AppSpacing.p12),
                        elevation: 0,
                      ),
                      child: const Text('Add', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Data Integrity Warning
          if (participants.length < 2)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.p16),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.activeRed, size: 16),
                  SizedBox(width: AppSpacing.w8),
                  Text(
                    'At least 2 members are required to split expenses.',
                    style: TextStyle(color: AppColors.activeRed, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            
          const SizedBox(height: AppSpacing.h16),
          
          // Members List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16),
              itemCount: participants.length,
              itemBuilder: (context, index) {
                final member = participants[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.m12),
                  padding: const EdgeInsets.all(AppSpacing.p12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.br12), // Using br12 instead of br16
                    border: Border.all(color: AppColors.dividerColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: member.avatarColor != 0 ? Color(member.avatarColor) : _presetColors[index % _presetColors.length], 
                        child: Text(
                          member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.w16),
                      Expanded(
                        child: Text(member.name, style: AppTextStyles.cardTitle.copyWith(color: AppColors.black, fontSize: 16, letterSpacing: 0)),
                      ),
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline_rounded, color: AppColors.activeRed.withValues(alpha: 0.8)),
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
    if (_nameController.text.trim().isEmpty) return;
    final int memberColor = _presetColors[_selectedColorIndex].toARGB32();
    
    final member = TourParticipant(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tourId: widget.tourId,
      name: _nameController.text.trim(),
      avatarColor: memberColor,
      joinedAt: DateTime.now(),
    );
    
    context.read<TourProvider>().addParticipant(member);
    _nameController.clear();
  }

  void _removeMember(String memberId) {
    context.read<TourProvider>().removeParticipant(memberId);
  }
}
