import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
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
        category: context.translate('housing'),
        percentage: 40,
        amount: 1700,
        color: const Color(0xFF1EA97C),
      ),
      SpendingDistributionItem(
        category: context.translate('food'),
        percentage: 30,
        amount: 1275,
        color: const Color(0xFF2EBD85),
      ),
      SpendingDistributionItem(
        category: context.translate('transport'),
        percentage: 20,
        amount: 850,
        color: const Color(0xFF80E2B9),
      ),
      SpendingDistributionItem(
        category: context.translate('utilities'),
        percentage: 10,
        amount: 425,
        color: const Color(0xFFD2F8E7),
      ),
    ];

    // 2. Top Spending Categories Data
    final topCategories = [
      TopSpendingCategoryItem(
        title: context.translate('housing'),
        subtitle: context.translate('rent_maintenance'),
        amount: 1700,
        percentage: 40,
        icon: Icons.home_outlined,
      ),
      TopSpendingCategoryItem(
        title: context.translate('food'),
        subtitle: context.translate('groceries_dining'),
        amount: 1275,
        percentage: 30,
        icon: Icons.restaurant,
      ),
      TopSpendingCategoryItem(
        title: context.translate('transport'),
        subtitle: context.translate('fuel_transit'),
        amount: 850,
        percentage: 20,
        icon: Icons.directions_car_outlined,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          context.translate('analytics'),
          style: GoogleFonts.workSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFF0F0F0), height: 1.0),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Spending Overview Card
                SpendingOverviewCard(
                  totalAmount: '${context.currencySymbol}4,250',
                  items: spendingItems,
                ),
                const SizedBox(height: 18),

                // Monthly Comparison Card
                MonthlyComparisonCard(
                  currentAmount: 4250,
                  previousAmount: 3800,
                  netChangeText: '+11.8%',
                ),
                const SizedBox(height: 18),

                // Top Spending Categories Card
                TopSpendingCategoriesCard(
                  items: topCategories,
                ),
                const SizedBox(height: 100), // Spacer to scroll past floating bottom nav
              ],
            ),
          ),
        ),
      ),
    );
  }
}
