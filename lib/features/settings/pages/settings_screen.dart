import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/features/dashboard/pages/expense_insights_screen.dart';
import 'package:expense_tracker/features/dashboard/pages/income_insights_screen.dart';
import 'package:expense_tracker/features/notes/pages/notebook_screen.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/features/settings/pages/currency_selection_screen.dart';
import 'package:expense_tracker/features/settings/pages/manage_categories_screen.dart';
import 'package:expense_tracker/features/settings/widgets/logout_dialog.dart';
import 'package:expense_tracker/features/settings/widgets/settings_group_card.dart';
import 'package:expense_tracker/features/settings/widgets/settings_option_row.dart';
import 'package:expense_tracker/features/settings/widgets/settings_profile_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
          borderRadius: BorderRadius.circular(16),
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
    final currencyProvider = context.watch<CurrencyProvider>();
    final selectedCurrency = currencyProvider.selectedCurrency;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Settings Header Title
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: GoogleFonts.workSans().fontFamily,
                  ),
                ),
                const SizedBox(height: 6),
                // Settings Header Subtitle
                Text(
                  'Manage your account and app preferences.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.loginSubTitle,
                    fontFamily: GoogleFonts.workSans().fontFamily,
                  ),
                ),
                const SizedBox(height: 24),

                // User Profile Card
                SettingsProfileCard(
                  name: 'Alexander Vance',
                  email: 'alexander.vance@equilibrium.app',
                  onEditTap: () => _showSnackBar(context, 'Edit profile clicked'),
                ),
                const SizedBox(height: 28),

                // ACCOUNT Settings Group
                SettingsGroupCard(
                  title: 'Account',
                  children: [
                    SettingsOptionRow(
                      icon: Icons.person_outline,
                      title: 'Personal Information',
                      onTap: () => _showSnackBar(context, 'Personal Information clicked'),
                    ),
                    SettingsOptionRow(
                      icon: Icons.lock_outline,
                      title: 'Security & Privacy',
                      onTap: () => _showSnackBar(context, 'Security & Privacy clicked'),
                    ),
                    SettingsOptionRow(
                      icon: Icons.notifications_none_outlined,
                      title: 'Notifications',
                      onTap: () => _showSnackBar(context, 'Notifications clicked'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // MANAGEMENT Settings Group
                SettingsGroupCard(
                  title: 'Management',
                  children: [
                    SettingsOptionRow(
                      icon: Icons.category_outlined,
                      title: 'Manage Categories',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageCategoriesScreen(),
                          ),
                        );
                      },
                    ),
                    SettingsOptionRow(
                      icon: Icons.bar_chart_outlined,
                      title: 'View Reports',
                      onTap: () => _showReportSelectorDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // PREFERENCES Settings Group
                SettingsGroupCard(
                  title: 'Preferences',
                  children: [
                    SettingsOptionRow(
                      icon: Icons.payments_outlined,
                      title: 'Currency',
                      trailingText: '${selectedCurrency.code} (${selectedCurrency.symbol})',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CurrencySelectionScreen(),
                          ),
                        );
                      },
                    ),
                    SettingsOptionRow(
                      icon: Icons.palette_outlined,
                      title: 'Theme',
                      trailingText: 'Light',
                      onTap: () => _showSnackBar(context, 'Theme clicked'),
                    ),
                    SettingsOptionRow(
                      icon: Icons.language,
                      title: 'Language',
                      trailingText: 'English',
                      onTap: () => _showSnackBar(context, 'Language clicked'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                 // UTILITIES Settings Group
                SettingsGroupCard(
                  title: 'Utilities',
                  children: [
                    SettingsOptionRow(
                      icon: Icons.note_alt_outlined,
                      title: 'Notebook',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotebookScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // SUPPORT Settings Group
                SettingsGroupCard(
                  title: 'Support',
                  children: [
                    SettingsOptionRow(
                      icon: Icons.help_outline,
                      title: 'Help Center',
                      onTap: () => _showSnackBar(context, 'Help Center clicked'),
                    ),
                    SettingsOptionRow(
                      icon: Icons.shield_outlined,
                      title: 'Privacy Policy',
                      onTap: () => _showSnackBar(context, 'Privacy Policy clicked'),
                    ),
                    SettingsOptionRow(
                      icon: Icons.logout,
                      title: 'Logout',
                      color: AppColors.activeRed,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const LogoutDialog(),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
