import 'package:material_symbols_icons/symbols.dart';
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
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
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
                        ? SharedPrefsHelper.getString('local_profile_photo_${user.uid}') 
                        : null;
                    final photoUrl = localPhoto ?? user?.photoURL;

                    return SettingsProfileCard(
                      name: displayName,
                      email: email,
                      photoUrl: photoUrl,
                      onEditTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const EditProfileDialog(),
                        );
                      },
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

                PreferencesGroup(onSnackBar: (msg) => _showSnackBar(context, msg)),
                const SizedBox(height: 20),

                const UtilitiesGroup(),
                const SizedBox(height: 20),

                SupportGroup(onSnackBar: (msg) => _showSnackBar(context, msg)),
                const SizedBox(height: 24),
                // Delete Account Danger Zone
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFDC3545).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC3545).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Symbols.delete_forever_rounded,
                          color: Color(0xFFDC3545),
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Delete Account',
                            style: AppTextStyles.label.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFDC3545),
                            ),
                          ),
                          Text(
                            'Permanently remove your account and data',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption.copyWith(
                              fontSize: AppFontSizes.size9,
                              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () => showDialog(
                          context: context,
                          builder: (_) => const DeleteAccountDialog(),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Symbols.chevron_right_rounded,
                            color: Color(0xFFDC3545),
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Logout button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFE53935).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Symbols.logout_rounded,
                          color: Color(0xFFE53935),
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        context.translate('logout'),
                        style: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE53935),
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () => showDialog(
                          context: context,
                          builder: (_) => const LogoutDialog(),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Symbols.chevron_right_rounded,
                            color: Color(0xFFE53935),
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 150), // Spacer to scroll past floating bottom nav
              ],
            ),
          ),
        ),
      ),
    );
  }
}
