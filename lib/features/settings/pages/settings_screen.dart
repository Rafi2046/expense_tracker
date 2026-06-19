import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/features/dashboard/pages/expense_insights_screen.dart';
import 'package:expense_tracker/features/dashboard/pages/income_insights_screen.dart';
import 'package:expense_tracker/features/settings/widgets/account_group.dart';
import 'package:expense_tracker/features/settings/widgets/management_group.dart';
import 'package:expense_tracker/features/settings/widgets/preferences_group.dart';
import 'package:expense_tracker/features/settings/widgets/utilities_group.dart';
import 'package:expense_tracker/features/settings/widgets/support_group.dart';
import 'package:expense_tracker/features/settings/widgets/settings_profile_card.dart';
import 'package:expense_tracker/features/settings/widgets/edit_profile_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  void _showReportSelectorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.r16),
        ),
        title: Text(
          'Select Report Type',
          style: GoogleFonts.workSans(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.trending_down, color: AppColors.activeRed),
              title: Text('Expense Insights', style: GoogleFonts.workSans(fontSize: 15)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExpenseInsightsScreen(),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.trending_up, color: AppColors.activeGreen),
              title: Text('Income Insights', style: GoogleFonts.workSans(fontSize: 15)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const IncomeInsightsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Settings',
          style: GoogleFonts.workSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFF1F1F1), height: 1.0),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s20,
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
                    final photoUrl = user?.photoURL;

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
                const SizedBox(height: AppSpacing.s24),

                // Settings Groups
                AccountGroup(onSnackBar: (msg) => _showSnackBar(context, msg)),
                const SizedBox(height: AppSpacing.s24),

                ManagementGroup(onShowReportSelector: () => _showReportSelectorDialog(context)),
                const SizedBox(height: AppSpacing.s24),

                PreferencesGroup(onSnackBar: (msg) => _showSnackBar(context, msg)),
                const SizedBox(height: AppSpacing.s24),

                const UtilitiesGroup(),
                const SizedBox(height: AppSpacing.s24),

                SupportGroup(onSnackBar: (msg) => _showSnackBar(context, msg)),
                const SizedBox(height: AppSpacing.s24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
