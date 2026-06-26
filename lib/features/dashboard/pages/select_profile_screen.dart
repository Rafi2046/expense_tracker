import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/profile_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/profile_info_banner.dart';
import 'package:expense_tracker/features/dashboard/widgets/profile_type_card.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:expense_tracker/features/dashboard/pages/create_profile_name_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectProfileScreen extends StatelessWidget {
  const SelectProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final isBusiness = provider.creationProfileType == 'business';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back, color: Colors.black),
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
              Text('Select Your Profile', style: AppTextStyles.profileTitle),
              const SizedBox(height: 6),
              Text(
                'What will you use the app mostly for?',
                style: AppTextStyles.profileSubtitle,
              ),
              const SizedBox(height: 24),

              // Business Management Card
              ProfileTypeCard(
                icon: Symbols.storefront,
                title: 'Business Management',
                subtitle:
                    'Manage your business accounting and inventory easily.',
                isSelected: isBusiness,
                onTap: () {
                  provider.setCreationProfileType('business');
                },
              ),

              const SizedBox(height: 16),

              // Personal Finance Card
              ProfileTypeCard(
                icon: Symbols.person,
                title: 'Personal Finance',
                subtitle:
                    'Track your expenses and maintain your credits with friends.',
                isSelected: !isBusiness,
                onTap: () {
                  provider.setCreationProfileType('personal');
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
                      builder: (context) =>
                          CreateProfileNameScreen(isBusiness: isBusiness),
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
