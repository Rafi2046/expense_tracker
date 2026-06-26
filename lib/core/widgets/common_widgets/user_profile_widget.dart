import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserProfile {
  final String id;
  final String name;
  final String type;

  UserProfile({required this.id, required this.name, required this.type});
}

class ProfileSwitchSheet extends StatefulWidget {
  final String currentProfileId;
  final List<UserProfile> profiles;
  final Function(UserProfile) onProfileSelected;
  final VoidCallback onCreateNewTap;

  const ProfileSwitchSheet({
    super.key,
    required this.currentProfileId,
    required this.profiles,
    required this.onProfileSelected,
    required this.onCreateNewTap,
  });

  static void show({
    required BuildContext context,
    required String currentProfileId,
    required List<UserProfile> profiles,
    required Function(UserProfile) onProfileSelected,
    required VoidCallback onCreateNewTap,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ProfileSwitchSheet(
          currentProfileId: currentProfileId,
          profiles: profiles,
          onProfileSelected: onProfileSelected,
          onCreateNewTap: onCreateNewTap,
        );
      },
    );
  }

  @override
  State<ProfileSwitchSheet> createState() => _ProfileSwitchSheetState();
}

class _ProfileSwitchSheetState extends State<ProfileSwitchSheet> {
  late String _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.currentProfileId;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Switch Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.workSans().fontFamily,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose a profile to manage',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontFamily: GoogleFonts.workSans().fontFamily,
              ),
            ),
            const SizedBox(height: 20),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.profiles.length,
              itemBuilder: (context, index) {
                final profile = widget.profiles[index];
                final isSelected = profile.id == _selectedId;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade100,
                    radius: 24,
                    child: Text(
                      profile.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  title: Text(
                    profile.name,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: Colors.black,
                      fontFamily: GoogleFonts.workSans().fontFamily,
                    ),
                  ),
                  subtitle: Text(
                    profile.type,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontFamily: GoogleFonts.workSans().fontFamily,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Symbols.radio_button_checked,
                          color: AppColors.selectedColor,
                        )
                      : const Icon(
                          Symbols.radio_button_unchecked,
                          color: Colors.grey,
                        ),
                  onTap: () {
                    setState(() {
                      _selectedId = profile.id;
                    });

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

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onCreateNewTap();
                },
                icon: const Icon(Symbols.add, color: Color(0xFF00BFA5)),
                label: Text(
                  'Create New Profile',
                  style: AppTextStyles.createProfile,
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
    );
  }
}
