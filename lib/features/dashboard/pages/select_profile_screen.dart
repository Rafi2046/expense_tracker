import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/providers/profile_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/premium_upgrade_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/profile_info_banner.dart';
import 'package:expense_tracker/features/dashboard/widgets/profile_type_card.dart';
import 'package:expense_tracker/features/dashboard/widgets/coming_soon_sheet.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:expense_tracker/features/dashboard/pages/create_profile_name_screen.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
          icon: Icon(LucideIcons.arrowLeft, color: theme.iconTheme.color),
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
                context.translate('select_your_profile'),
                style: AppTextStyles.h1.copyWith(fontWeight: FontWeight.w800, color: theme.textTheme.titleLarge?.color),
              ),
              const SizedBox(height: 4),
              Text(
                context.translate('what_will_you_use'),
                style: AppTextStyles.bodySmall.copyWith(color: theme.textTheme.bodySmall?.color),
              ),
              const SizedBox(height: 20),

              ProfileTypeCard(
                icon: LucideIcons.store,
                title: context.translate('business_management'),
                subtitle: context.translate('business_management_subtitle'),
                isSelected: false,
                onTap: () => ComingSoonSheet.show(context),
              ),

              const SizedBox(height: 14),

              ProfileTypeCard(
                icon: LucideIcons.user,
                title: context.translate('personal_finance'),
                subtitle: context.translate('personal_finance_subtitle'),
                isSelected: !isBusiness,
                onTap: () => provider.setCreationProfileType('personal'),
              ),

              const Spacer(),

              const ProfileInfoBanner(),

              const SizedBox(height: 14),

              CustomButton(
                text: context.translate('continue'),
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
