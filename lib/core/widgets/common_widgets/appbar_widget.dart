import 'package:material_symbols_icons/symbols.dart';
import 'dart:io';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomepageAppbarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final String name;
  final String? profilePhoto;
  final VoidCallback onProfileTap;
  final VoidCallback notificationOnTap;

  const HomepageAppbarWidget({
    super.key,
    required this.name,
    this.profilePhoto,
    required this.onProfileTap,
    required this.notificationOnTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 2.0);

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 16,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
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
                    backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade200,
                    backgroundImage: (profilePhoto != null && profilePhoto!.startsWith('http'))
                        ? NetworkImage(profilePhoto!) as ImageProvider
                        : (profilePhoto != null && profilePhoto!.isNotEmpty && File(profilePhoto!).existsSync()
                            ? FileImage(File(profilePhoto!)) as ImageProvider
                            : null),
                    child: (profilePhoto != null && (profilePhoto!.startsWith('http') || (profilePhoto!.isNotEmpty && File(profilePhoto!).existsSync())))
                        ? null
                        : Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'U',
                            style: TextStyle(
                              color: onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: GoogleFonts.workSans().fontFamily,
                            ),
                          ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    name,
                    style: TextStyle(
                      color: onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      fontFamily: GoogleFonts.workSans().fontFamily,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Symbols.keyboard_arrow_down,
                    color: onSurface,
                    size: 20,
                  ),
                ],
              ),
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
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2.0),
        child: Container(
          color: Theme.of(context).dividerTheme.color ?? AppColors.dividerColor,
          height: 2.0,
        ),
      ),
    );
  }
}
