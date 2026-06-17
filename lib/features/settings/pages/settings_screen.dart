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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      icon: Icons.person_rounded,
                      iconBgColor: const Color(0xFFE3F2FD),
                      iconColor: const Color(0xFF1E88E5),
                      title: 'Personal Information',
                      onTap: () => _showSnackBar(context, 'Personal Information clicked'),
                    ),
                    SettingsOptionRow(
                      icon: Icons.lock_rounded,
                      iconBgColor: const Color(0xFFFFF3E0),
                      iconColor: const Color(0xFFFB8C00),
                      title: 'Security & Privacy',
                      onTap: () => _showSnackBar(context, 'Security & Privacy clicked'),
                    ),
                    SettingsOptionRow(
                      icon: Icons.notifications_rounded,
                      iconBgColor: const Color(0xFFFCE4EC),
                      iconColor: const Color(0xFFD81B60),
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
                      icon: Icons.category_rounded,
                      iconBgColor: const Color(0xFFF3E5F5),
                      iconColor: const Color(0xFF8E24AA),
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
                      icon: Icons.bar_chart_rounded,
                      iconBgColor: const Color(0xFFE8F8F5),
                      iconColor: const Color(0xFF16A085),
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
                      icon: Icons.payments_rounded,
                      iconBgColor: const Color(0xFFE0F2F1),
                      iconColor: const Color(0xFF00796B),
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
                      icon: Icons.palette_rounded,
                      iconBgColor: const Color(0xFFE8EAF6),
                      iconColor: const Color(0xFF3F51B5),
                      title: 'Theme',
                      trailingText: 'Light',
                      onTap: () => _showSnackBar(context, 'Theme clicked'),
                    ),
                    SettingsOptionRow(
                      icon: Icons.language_rounded,
                      iconBgColor: const Color(0xFFFFFDE7),
                      iconColor: const Color(0xFFFBC02D),
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
                      icon: Icons.book_rounded,
                      iconBgColor: const Color(0xFFEFEBE9),
                      iconColor: const Color(0xFF6D4C41),
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
                      icon: Icons.help_rounded,
                      iconBgColor: const Color(0xFFECEFF1),
                      iconColor: const Color(0xFF546E7A),
                      title: 'Help Center',
                      onTap: () => _showSnackBar(context, 'Help Center clicked'),
                    ),
                    SettingsOptionRow(
                      icon: Icons.shield_rounded,
                      iconBgColor: const Color(0xFFE8F5E9),
                      iconColor: const Color(0xFF43A047),
                      title: 'Privacy Policy',
                      onTap: () => _showSnackBar(context, 'Privacy Policy clicked'),
                    ),
                    SettingsOptionRow(
                      icon: Icons.logout_rounded,
                      iconBgColor: const Color(0xFFFFF1F0),
                      iconColor: const Color(0xFFE53935),
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
