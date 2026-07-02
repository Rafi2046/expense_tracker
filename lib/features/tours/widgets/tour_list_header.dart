import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/profile_provider.dart';
import 'package:expense_tracker/core/providers/profile_manager_provider.dart';
import 'package:expense_tracker/core/widgets/common_widgets/user_profile_widget.dart';
import 'package:expense_tracker/features/dashboard/pages/select_profile_screen.dart';

class TourListHeader extends StatelessWidget {
  final UserProfile currentProfile;
  final String? photoUrl;
  final String initials;

  const TourListHeader({
    super.key,
    required this.currentProfile,
    required this.photoUrl,
    required this.initials,
  });

  ImageProvider? _resolveImage(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return NetworkImage(url);
    if (File(url).existsSync()) return FileImage(File(url));
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileProvider = context.read<ProfileProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.p20,
        AppSpacing.p12,
        AppSpacing.p20,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.activeGreen.withValues(alpha: 0.08), // Softer background
                    borderRadius: BorderRadius.circular(8), // Slightly rounder
                  ),
                  child: Text(
                    'WHERE TO NEXT?',
                    style: GoogleFonts.workSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: AppColors.activeGreen.withValues(alpha: 0.9),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  'Your Tours',
                  style: AppTextStyles.sectionHeaderTitle.copyWith(
                    fontSize: 32, // Larger font
                    fontWeight: FontWeight.w800, // Extra bold for premium feel
                    letterSpacing: -1.2, // Tighter letter spacing
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              ProfileSwitchSheet.show(
                context: context,
                currentProfileId: currentProfile.id,
                profiles: profileProvider.profiles,
                onProfileSelected: (selectedProfile) {
                  profileProvider.selectProfile(selectedProfile);
                  context.read<ProfileManagerProvider>().switchProfile(
                    selectedProfile.id,
                  );
                },
                onCreateNewTap: () async {
                  final newProfile = await Navigator.push<UserProfile>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SelectProfileScreen(),
                    ),
                  );
                  if (newProfile != null && context.mounted) {
                    context
                        .read<ProfileManagerProvider>()
                        .switchProfile(newProfile.id);
                  }
                },
              );
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 24, // Slightly larger avatar
                backgroundColor: theme.brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.white,
                backgroundImage: _resolveImage(photoUrl),
                child: _resolveImage(photoUrl) == null
                    ? Text(
                  initials,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    fontFamily: GoogleFonts.workSans().fontFamily,
                  ),
                )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}