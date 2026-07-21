import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/providers/profile_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/profile_info_banner.dart';
import 'package:expense_tracker/features/dashboard/widgets/profile_type_card.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:expense_tracker/features/dashboard/pages/create_profile_name_screen.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SelectProfileScreen extends StatelessWidget {
  const SelectProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: theme.colorScheme.surface,
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
                context.translate('create_profile'),
                style: AppTextStyles.h1.copyWith(fontWeight: FontWeight.w800, color: theme.textTheme.titleLarge?.color),
              ),
              const SizedBox(height: 4),
              Text(
                context.translate('create_profile_subtitle'),
                style: AppTextStyles.bodySmall.copyWith(color: theme.textTheme.bodySmall?.color),
              ),
              const SizedBox(height: 20),

              ProfileTypeCard(
                icon: LucideIcons.user,
                title: context.translate('personal_finance'),
                subtitle: context.translate('personal_finance_subtitle'),
                isSelected: true,
                onTap: () => provider.setCreationProfileType('personal'),
              ),

              const Spacer(),

              const ProfileInfoBanner(),

              const SizedBox(height: 14),

              CustomButton(
                text: context.translate('continue'),
                backgroundColor: const Color(0xFF2EBD85),
                onPressed: () async {
                  if (provider.profiles.length >= 2) {
                    _showMaxProfilesSheet(context);
                    return;
                  }
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateProfileNameScreen(isBusiness: false),
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

  static void _showMaxProfilesSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(24, 20, 24, 20 + bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Icon(
              LucideIcons.userRoundCog,
              size: 40,
              color: const Color(0xFF2EBD85),
            ),
            const SizedBox(height: 16),
            Text(
              context.translate('max_profiles_reached'),
              style: AppTextStyles.h2.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.translate('max_profiles_description'),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2EBD85),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  context.translate('got_it'),
                  style: TextStyle(
                    fontSize: AppFontSizes.size16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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
