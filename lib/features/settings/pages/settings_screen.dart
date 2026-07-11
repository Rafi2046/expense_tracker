import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/features/reports/pages/view_reports_screen.dart';
import 'package:expense_tracker/features/settings/widgets/account_group.dart';
import 'package:expense_tracker/features/settings/widgets/management_group.dart';
import 'package:expense_tracker/features/settings/widgets/preferences_group.dart';
import 'package:expense_tracker/features/settings/widgets/utilities_group.dart';
import 'package:expense_tracker/features/settings/widgets/support_group.dart';
import 'package:expense_tracker/features/settings/widgets/settings_profile_card.dart';
import 'package:expense_tracker/features/settings/widgets/edit_profile_dialog.dart';
import 'package:expense_tracker/features/settings/widgets/delete_account_dialog.dart';
import 'package:expense_tracker/features/settings/widgets/logout_dialog.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _profileVersion = 0;

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  Future<void> _openEditProfile() async {
    await showDialog(
      context: context,
      builder: (context) => const EditProfileDialog(),
    );
    if (mounted) {
      setState(() => _profileVersion++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          context.translate('settings'),
          style: AppTextStyles.h2.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF2D2D2D)
                : const Color(0xFFF1F1F1),
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: 18.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Card (Stream-based)
                StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.userChanges(),
                  builder: (context, snapshot) {
                    final user = snapshot.data;
                    final displayName = user?.displayName ?? 'Guest User';
                    final email = user?.email ?? 'No email';

                    // Retrieve local photo path if it was saved, otherwise fall back to user.photoURL
                    final localPhoto = user != null
                        ? SharedPrefsHelper.getString(
                            'local_profile_photo_${user.uid}',
                          )
                        : null;
                    final photoUrl = localPhoto ?? user?.photoURL;

                    return SettingsProfileCard(
                      name: displayName,
                      email: email,
                      photoUrl: photoUrl,
                      onEditTap: _openEditProfile,
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Settings Groups
                AccountGroup(onSnackBar: (msg) => _showSnackBar(context, msg)),
                const SizedBox(height: 20),

                ManagementGroup(
                  onShowReportSelector: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ViewReportsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                PreferencesGroup(
                  onSnackBar: (msg) => _showSnackBar(context, msg),
                ),
                const SizedBox(height: 20),

                const UtilitiesGroup(),
                const SizedBox(height: 20),

                SupportGroup(onSnackBar: (msg) => _showSnackBar(context, msg)),
                const SizedBox(height: 24),
                // Delete Account Danger Zone
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.red.shade200, width: 1.2),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => const DeleteAccountDialog(),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.trash,
                            color: Colors.red.shade400,
                            size: 22,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.translate('delete_account'),
                                  style: AppTextStyles.label.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red.shade400,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  context.translate('delete_account_subtitle'),
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: AppFontSizes.size10,
                                    color: Colors.red.shade300,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            LucideIcons.chevronRight,
                            color: Colors.red.shade400,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Logout button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.red.shade200, width: 1.2),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => const LogoutDialog(),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.logOut,
                            color: Colors.red.shade400,
                            size: 22,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            context.translate('logout'),
                            style: AppTextStyles.label.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade400,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            LucideIcons.chevronRight,
                            color: Colors.red.shade400,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 150),
                // Spacer to scroll past floating bottom nav
              ],
            ),
          ),
        ),
      ),
    );
  }
}
