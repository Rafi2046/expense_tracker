import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/dashboard/widgets/profile_info_banner.dart';
import 'package:expense_tracker/features/dashboard/widgets/profile_type_card.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:expense_tracker/features/dashboard/pages/create_profile_name_screen.dart';
import 'package:flutter/material.dart';

class SelectProfileScreen extends StatefulWidget {
  const SelectProfileScreen({super.key});

  @override
  State<SelectProfileScreen> createState() => _SelectProfileScreenState();
}

class _SelectProfileScreenState extends State<SelectProfileScreen> {
  // 'business' or 'personal'
  String _selectedType = 'business';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Your Profile',
                style: AppTextStyles.profileTitle,
              ),
              const SizedBox(height: 6),
              Text(
                'What will you use the app mostly for?',
                style: AppTextStyles.profileSubtitle,
              ),
              const SizedBox(height: 24),
              
              // Business Management Card
              ProfileTypeCard(
                icon: Icons.storefront,
                title: 'Business Management',
                subtitle: 'Manage your business accounting and inventory easily.',
                isSelected: _selectedType == 'business',
                onTap: () {
                  setState(() {
                    _selectedType = 'business';
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Personal Finance Card
              ProfileTypeCard(
                icon: Icons.person,
                title: 'Personal Finance',
                subtitle: 'Track your expenses and maintain your credits with friends.',
                isSelected: _selectedType == 'personal',
                onTap: () {
                  setState(() {
                    _selectedType = 'personal';
                  });
                },
              ),
              
              const Spacer(),
              
              // Info Banner
              const ProfileInfoBanner(),
              
              const SizedBox(height: 16),
              
              // Continue Button
              CustomButton(
                text: 'Continue',
                backgroundColor: AppColors.activeGreen,
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateProfileNameScreen(
                        isBusiness: _selectedType == 'business',
                      ),
                    ),
                  );
                  if (result != null && context.mounted) {
                    Navigator.pop(context, result);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
