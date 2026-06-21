import 'package:expense_tracker/features/settings/pages/personal_info_screen.dart';
import 'package:expense_tracker/features/settings/widgets/settings_group_card.dart';
import 'package:expense_tracker/features/settings/widgets/settings_option_row.dart';
import 'package:expense_tracker/features/settings/widgets/inline_password_form.dart';
import 'package:expense_tracker/features/settings/widgets/inline_google_notice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
    return SettingsGroupCard(
      title: 'Account',
      children: [
        SettingsOptionRow(
          icon: Icons.person_rounded,
          iconBgColor: const Color(0xFFE3F2FD),
          iconColor: const Color(0xFF1E88E5),
          title: 'Personal Information',
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
              icon: Icons.lock_rounded,
              iconBgColor: const Color(0xFFFFF3E0),
              iconColor: const Color(0xFFFB8C00),
              title: 'Password Change',
              trailingIcon: _isSecurityExpanded 
                  ? Icons.keyboard_arrow_down_rounded 
                  : Icons.chevron_right_rounded,
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
                  Container(height: 1.0, color: const Color(0xFFF1F1F1)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
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

        SettingsOptionRow(
          icon: Icons.notifications_rounded,
          iconBgColor: const Color(0xFFFCE4EC),
          iconColor: const Color(0xFFD81B60),
          title: 'Notifications',
          onTap: () => widget.onSnackBar('Notifications clicked'),
        ),
      ],
    );
  }
}
