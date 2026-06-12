import 'package:expense_tracker/core/providers/profile_provider.dart';
import 'package:expense_tracker/core/widgets/common_widgets/appbar_widget.dart';
import 'package:expense_tracker/core/widgets/common_widgets/user_profile_widget.dart';
import 'package:expense_tracker/features/dashboard/pages/select_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final currentProfile = profileProvider.currentProfile;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: HomepageAppbarWidget(
        name: currentProfile.name,
        onProfileTap: () {
          ProfileSwitchSheet.show(
            context: context,
            currentProfileId: currentProfile.id,
            profiles: profileProvider.profiles,
            onProfileSelected: (selectedProfile) {
              profileProvider.selectProfile(selectedProfile);
            },
            onCreateNewTap: () async {
              final newProfile = await Navigator.push<UserProfile>(
                context,
                MaterialPageRoute(
                  builder: (context) => const SelectProfileScreen(),
                ),
              );
              if (newProfile != null) {
                profileProvider.addProfile(newProfile);
              }
            },
          );
        },
        notificationOnTap: () {},
      ),
      body: const Column(
        children: [
          // Dashboard screen contents go here
        ],
      ),
    );
  }
}
