import 'package:expense_tracker/core/widgets/common_widgets/appbar_widget.dart';
import 'package:expense_tracker/core/widgets/common_widgets/user_profile_widget.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Demo user profiles matching the design
  final List<UserProfile> _profiles = [
    UserProfile(id: '1', name: 'Rafi', type: 'Personal'),
    UserProfile(id: '2', name: 'Office', type: 'Business'),
  ];

  late UserProfile _currentProfile;

  @override
  void initState() {
    super.initState();
    _currentProfile = _profiles.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: HomepageAppbarWidget(
        name: _currentProfile.name,
        onProfileTap: () {
          ProfileSwitchSheet.show(
            context: context,
            currentProfileId: _currentProfile.id,
            profiles: _profiles,
            onProfileSelected: (selectedProfile) {
              setState(() {
                _currentProfile = selectedProfile;
              });
            },
            onCreateNewTap: () {
              // Add implementation if there's profile creation flow
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
