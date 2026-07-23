import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/profile_provider.dart';
import 'package:expense_tracker/core/providers/profile_manager_provider.dart';
import 'package:expense_tracker/core/widgets/common_widgets/user_profile_widget.dart';
import 'package:expense_tracker/features/dashboard/pages/select_profile_screen.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

class TourListHeader extends StatelessWidget {
  final UserProfile currentProfile;
  final String? photoUrl;
  final String initials;
  final int totalTours;
  final int totalBuddies;
  final VoidCallback? onViewAll;

  const TourListHeader({
    super.key,
    required this.currentProfile,
    required this.photoUrl,
    required this.initials,
    this.totalTours = 0,
    this.totalBuddies = 0,
    this.onViewAll,
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
    final scheme = theme.colorScheme;
    final profileProvider = context.read<ProfileProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.p16,
        AppSpacing.p12,
        AppSpacing.p16,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.p12,
                    vertical: AppSpacing.p8,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.r8),
                  ),
                  child: Text(
                    context.translate('where_to_next'),
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: scheme.primary),
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.translate('your_tours'),
                      style: AppTextStyles.displayLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        color: scheme.onSurface),
                    ),
                    if (onViewAll != null && totalTours > 0)
                      TextButton(
                        onPressed: onViewAll,
                        style: TextButton.styleFrom(
                          foregroundColor: scheme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          context.translate('view_all'),
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.primary),
                        ),
                      ),
                  ],
                ),
                if (totalTours > 0) ...[
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    '$totalTours tour${totalTours == 1 ? '' : 's'} · $totalBuddies ${totalBuddies == 1 ? 'buddy' : 'buddies'}',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.r24),
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
                    color: scheme.onSurface.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                  radius: 20,
                backgroundColor: scheme.surfaceContainerHighest,
                backgroundImage: _resolveImage(photoUrl),
                child: _resolveImage(photoUrl) == null
                    ? Text(
                  initials,
                  style: AppTextStyles.h3.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700),
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