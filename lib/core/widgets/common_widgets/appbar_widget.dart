import 'dart:io';

import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/privacy_provider.dart';
import 'package:expense_tracker/core/providers/session_provider.dart';
import 'package:expense_tracker/core/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomepageAppbarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback onProfileTap;
  final VoidCallback notificationOnTap;

  const HomepageAppbarWidget({
    super.key,
    required this.onProfileTap,
    required this.notificationOnTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 2.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = context.watch<SessionProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final isMasked = context.watch<PrivacyProvider>().isMasked;
    final currentProfile = profileProvider.currentProfile;
    final displayName = currentProfile.id == 'default_profile' ? session.firstName : currentProfile.name;
    final photoUrl = currentProfile.id == 'default_profile' ? session.photoUrl : null;
    final initials = currentProfile.id == 'default_profile' ? session.initials : (currentProfile.name.isNotEmpty ? currentProfile.name.substring(0, 1).toUpperCase() : 'P');

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 16,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: InkWell(
              onTap: onProfileTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4.0,
                  horizontal: 8.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: theme.brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                      backgroundImage: _resolveImage(photoUrl),
                      child: _resolveImage(photoUrl) == null
                          ? Text(
                              initials,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                fontFamily: GoogleFonts.workSans().fontFamily,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          fontFamily: GoogleFonts.workSans().fontFamily,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Symbols.keyboard_arrow_down,
                      color: theme.colorScheme.onSurface,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.read<PrivacyProvider>().toggle();
                },
                icon: Icon(
                  isMasked ? Symbols.visibility_off : Symbols.visibility,
                  color: AppColors.notificationIcon,
                  size: 26,
                ),
              ),
              IconButton(
                onPressed: notificationOnTap,
                icon: const Icon(
                  Symbols.notifications_none,
                  color: AppColors.notificationIcon,
                  size: 26,
                ),
              ),
            ],
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2.0),
        child: Container(
          color: theme.dividerTheme.color ?? AppColors.dividerColor,
          height: 2.0,
        ),
      ),
    );
  }

  ImageProvider? _resolveImage(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return null;
    if (photoUrl.startsWith('http')) return NetworkImage(photoUrl);
    if (File(photoUrl).existsSync()) return FileImage(File(photoUrl));
    return null;
  }
}
