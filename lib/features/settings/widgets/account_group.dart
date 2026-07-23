import 'package:expense_tracker/features/dashboard/pages/notifications_screen.dart';
import 'package:expense_tracker/features/settings/pages/personal_info_screen.dart';
import 'package:expense_tracker/features/settings/widgets/settings_group_card.dart';
import 'package:expense_tracker/features/settings/widgets/settings_option_row.dart';
import 'package:expense_tracker/features/settings/widgets/inline_password_form.dart';
import 'package:expense_tracker/features/settings/widgets/inline_google_notice.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'biometric_settings_tile.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class AccountGroup extends StatefulWidget {
  final Function(String) onSnackBar;

  const AccountGroup({super.key, required this.onSnackBar});

  @override
  State<AccountGroup> createState() => _AccountGroupState();
}

class _AccountGroupState extends State<AccountGroup> {
  bool _isSecurityExpanded = false;
  bool _isGoogleUser = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final providers = user.providerData.map((info) => info.providerId).toList();
      if (providers.contains('google.com')) {
        _isGoogleUser = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SettingsGroupCard(
      title: context.translate('account'),
      children: [
        SettingsOptionRow(
          icon: LucideIcons.user,
          title: context.translate('personal_info'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PersonalInfoScreen()),
            );
          },
        ),
        
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsOptionRow(
              icon: LucideIcons.lock,
              title: context.translate('password_change'),
              trailingIcon: _isSecurityExpanded 
                  ? LucideIcons.chevronDown 
                  : LucideIcons.chevronRight,
              onTap: () {
                setState(() {
                  _isSecurityExpanded = !_isSecurityExpanded;
                });
              },
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 1.0,
                    color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF1F1F1),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.p16, AppSpacing.p16, AppSpacing.p16, AppSpacing.p16),
                    child: _isGoogleUser 
                        ? const InlineGoogleNotice() 
                        : InlinePasswordForm(
                            onSuccess: () {
                              setState(() {
                                _isSecurityExpanded = false;
                              });
                            },
                          ),
                  ),
                ],
              ),
              crossFadeState: _isSecurityExpanded 
                  ? CrossFadeState.showSecond 
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
        BiometricSettingsTile(),
        SettingsOptionRow(
          icon: LucideIcons.bell,
          title: context.translate('notifications'),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()))
        ),
      ],
    );
  }
}
