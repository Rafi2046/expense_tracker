import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/providers/profile_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/premium_upgrade_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/profile_info_banner.dart';
import 'package:expense_tracker/features/dashboard/widgets/profile_type_card.dart';
import 'package:expense_tracker/features/dashboard/widgets/coming_soon_sheet.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:expense_tracker/features/dashboard/pages/create_profile_name_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SelectProfileScreen extends StatelessWidget {
  const SelectProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final isBusiness = provider.creationProfileType == 'business';
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Symbols.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Your Profile',
                style: GoogleFonts.workSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'What will you use the app mostly for?',
                style: GoogleFonts.workSans(
                  fontSize: 13,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 20),

              ProfileTypeCard(
                icon: Symbols.storefront,
                title: 'Business Management',
                subtitle: 'Manage your business accounting and inventory easily.',
                isSelected: false,
                onTap: () => ComingSoonSheet.show(context),
              ),

              const SizedBox(height: 14),

              ProfileTypeCard(
                icon: Symbols.person,
                title: 'Personal Finance',
                subtitle: 'Track your expenses and maintain your credits with friends.',
                isSelected: !isBusiness,
                onTap: () => provider.setCreationProfileType('personal'),
              ),

              const Spacer(),

              const ProfileInfoBanner(),

              const SizedBox(height: 14),

              CustomButton(
                text: 'Continue',
                backgroundColor: const Color(0xFF2EBD85),
                onPressed: () async {
                  if (provider.profiles.length >= 3 && !provider.isPremium) {
                    PremiumUpgradeSheet.show(context);
                    return;
                  }
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
