import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/features/analytics/widgets/monthly_comparison_card.dart';
import 'package:expense_tracker/features/analytics/widgets/spending_overview_card.dart';
import 'package:expense_tracker/features/analytics/widgets/top_spending_categories_card.dart';
import 'package:expense_tracker/features/analytics/widgets/top_spending_category_row.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Spending Overview Data
    final spendingItems = [
      SpendingDistributionItem(
        category: 'Housing',
        percentage: 40,
        amount: 1700,
        color: const Color(0xFF1EA97C),
      ),
      SpendingDistributionItem(
        category: 'Food',
        percentage: 30,
        amount: 1275,
        color: const Color(0xFF2EBD85),
      ),
      SpendingDistributionItem(
        category: 'Transport',
        percentage: 20,
        amount: 850,
        color: const Color(0xFF80E2B9),
      ),
      SpendingDistributionItem(
        category: 'Utilities',
        percentage: 10,
        amount: 425,
        color: const Color(0xFFD2F8E7),
      ),
    ];

    // 2. Top Spending Categories Data
    final topCategories = [
      TopSpendingCategoryItem(
        title: 'Housing',
        subtitle: 'Rent & Maintenance',
        amount: 1700,
        percentage: 40,
        icon: Icons.home_outlined,
      ),
      TopSpendingCategoryItem(
        title: 'Food',
        subtitle: 'Groceries & Dining',
        amount: 1275,
        percentage: 30,
        icon: Icons.restaurant,
      ),
      TopSpendingCategoryItem(
        title: 'Transport',
        subtitle: 'Fuel & Transit',
        amount: 850,
        percentage: 20,
        icon: Icons.directions_car_outlined,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Analytics Header Title (matches Settings header style)
                Text(
                  'Analytics',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: GoogleFonts.workSans().fontFamily,
                  ),
                ),
                const SizedBox(height: 6),
                // Analytics Header Subtitle
                Text(
                  'Track and analyze your spending distributions.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.loginSubTitle,
                    fontFamily: GoogleFonts.workSans().fontFamily,
                  ),
                ),
                const SizedBox(height: 24),

                // Spending Overview Card
                SpendingOverviewCard(
                  totalAmount: '${context.currencySymbol}4,250',
                  items: spendingItems,
                ),
                const SizedBox(height: 20),

                // Monthly Comparison Card
                MonthlyComparisonCard(
                  currentAmount: 4250,
                  previousAmount: 3800,
                  netChangeText: '+11.8%',
                ),
                const SizedBox(height: 20),

                // Top Spending Categories Card
                TopSpendingCategoriesCard(
                  items: topCategories,
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
