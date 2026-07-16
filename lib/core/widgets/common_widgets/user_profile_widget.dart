import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/profile_manager_provider.dart';
import 'package:expense_tracker/core/providers/profile_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/edit_profile_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class UserProfile {
  final String id;
  final String name;
  final String type;
  final String? uid;

  UserProfile({required this.id, required this.name, required this.type, this.uid});
}

class ProfileSwitchSheet extends StatefulWidget {
  final String currentProfileId;
  final List<UserProfile> profiles;
  final Function(UserProfile) onProfileSelected;
  final VoidCallback onCreateNewTap;
  final double maxHeight;

  const ProfileSwitchSheet({
    super.key,
    required this.currentProfileId,
    required this.profiles,
    required this.onProfileSelected,
    required this.onCreateNewTap,
    this.maxHeight = 500,
  });

  static void show({
    required BuildContext context,
    required String currentProfileId,
    required List<UserProfile> profiles,
    required Function(UserProfile) onProfileSelected,
    required VoidCallback onCreateNewTap,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: viewInsets),
        child: ProfileSwitchSheet(
          currentProfileId: currentProfileId,
          profiles: profiles,
          onProfileSelected: onProfileSelected,
          onCreateNewTap: onCreateNewTap,
          maxHeight: (screenHeight - viewInsets) * 0.55,
        ),
      ),
    );
  }

  @override
  State<ProfileSwitchSheet> createState() => _ProfileSwitchSheetState();
}

class _ProfileSwitchSheetState extends State<ProfileSwitchSheet> {
  String _profileLabel(UserProfile p) {
    if (p.id == 'default_profile') return context.translate('main_profile');
    if (p.type == 'Personal') return context.translate('secondary');
    return p.type;
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profileProvider = context.watch<ProfileProvider>();
    final profiles = profileProvider.profiles;
    final selectedId = profileProvider.currentProfile.id;

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Material(
          color: theme.colorScheme.surface,
          child: Container(
            constraints: BoxConstraints(maxHeight: widget.maxHeight),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
              child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.translate('switch_profile'),
              style: AppTextStyles.h1.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.translate('choose_profile_to_manage'),
              style: AppTextStyles.bodySmall.copyWith(color: theme.textTheme.bodySmall?.color),
            ),
            const SizedBox(height: 20),

            if (!profileProvider.isReady)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: profiles.length,
                  itemBuilder: (context, index) {
                final profile = profiles[index];
                final isSelected = profile.id == selectedId;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: isDark
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.1)
                        : Colors.grey.shade100,
                    radius: 24,
                    child: Text(
                      profile.name.substring(0, 1).toUpperCase(),
                      style: AppTextStyles.h2.copyWith(color: theme.textTheme.titleLarge?.color),
                    ),
                  ),
                  title: Text(
                    profile.name,
                    style: AppTextStyles.reportTileTitle.copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      if (profile.id == 'default_profile') ...[
                        Icon(LucideIcons.star, size: 13, color: const Color(0xFFF59E0B)),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        _profileLabel(profile),
                        style: AppTextStyles.label.copyWith(
                          color: profile.id == 'default_profile'
                              ? const Color(0xFFF59E0B)
                              : theme.textTheme.bodySmall?.color,
                          fontWeight: profile.id == 'default_profile' ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (profile.id != 'default_profile')
                        IconButton(
                          icon: Icon(
                            LucideIcons.edit,
                            color: theme.textTheme.bodySmall?.color,
                            size: 20,
                          ),
                          onPressed: () async {
                            await EditProfileSheet.show(context, profile);
                            if (context.mounted) {
                              final provider = context.read<ProfileProvider>();
                              final stillExists = provider.profiles.any((p) => p.id == profile.id);
                              if (!stillExists) {
                                context.read<ProfileManagerProvider>().switchProfile(
                                  provider.currentProfile.id,
                                );
                                Navigator.pop(context);
                              }
                            }
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      const SizedBox(width: 8),
                      isSelected
                          ? Icon(LucideIcons.circleDot, color: AppColors.selectedColor)
                          : Icon(LucideIcons.circle, color: theme.textTheme.bodySmall?.color),
                    ],
                  ),
                  onTap: () {
                    Future.delayed(const Duration(milliseconds: 150), () {
                      if (context.mounted) {
                        Navigator.pop(context);
                        widget.onProfileSelected(profile);
                      }
                    });
                  },
                );
                  },
                ),
              ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onCreateNewTap();
                },
                icon: Icon(LucideIcons.plus, color: Color(0xFF00BFA5)),
                label: Text(
                  context.translate('create_new_profile'),
                  style: AppTextStyles.reportTileTitle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00BFA5),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF00BFA5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
            ),
          ),
        ),
      ),
    ),
  );
  }
}
