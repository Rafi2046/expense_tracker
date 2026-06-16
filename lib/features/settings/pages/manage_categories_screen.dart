import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/category_input_row.dart';
import 'package:expense_tracker/features/dashboard/widgets/category_list_row.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _addCategory(TransactionProvider provider, bool isIncome) {
    final name = _inputController.text.trim();
    if (name.isEmpty) return;

    if (isIncome) {
      provider.addIncomeCategory(name);
    } else {
      provider.addExpenseCategory(name);
    }

    _inputController.clear();
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Category "$name" added successfully!'),
        duration: const Duration(seconds: 1),
        backgroundColor: isIncome ? AppColors.activeGreen : AppColors.activeRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manage Categories',
          style: GoogleFonts.workSans(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.buttonColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.buttonColor,
          labelStyle: GoogleFonts.workSans(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'Expense'),
            Tab(text: 'Income'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryListSection(provider, isIncome: false),
          _buildCategoryListSection(provider, isIncome: true),
        ],
      ),
    );
  }

  Widget _buildCategoryListSection(TransactionProvider provider, {required bool isIncome}) {
    final categories = isIncome ? provider.incomeCategories : provider.expenseCategories;
    final themeColor = isIncome ? AppColors.activeGreen : AppColors.activeRed;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Inline Input Row
          CategoryInputRow(
            controller: _inputController,
            themeColor: themeColor,
            onSubmitted: (_) => _addCategory(provider, isIncome),
            onAddPressed: () => _addCategory(provider, isIncome),
          ),
          const SizedBox(height: 16),

          // Categories List
          Expanded(
            child: categories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.category_outlined, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        Text(
                          'No categories created yet.',
                          style: GoogleFonts.workSans(color: Colors.grey.shade400, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFF0F0F0)),
                        ),
                        child: CategoryListRow(
                          categoryName: cat,
                          themeColor: themeColor,
                          showLeadingIcon: true,
                          showSelection: false,
                          onDelete: () {
                            if (isIncome) {
                              provider.deleteIncomeCategory(cat);
                            } else {
                              provider.deleteExpenseCategory(cat);
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Category "$cat" removed.'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
