import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
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

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen>
    with SingleTickerProviderStateMixin {
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

  void _showRenameDialog(
    BuildContext context,
    TransactionProvider provider,
    String currentName,
    bool isIncome,
  ) {
    final controller = TextEditingController(text: currentName);
    final themeColor = isIncome ? AppColors.activeGreen : AppColors.activeRed;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Rename Category',
          style: GoogleFonts.workSans(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Category Name',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: themeColor, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.workSans(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != currentName) {
                provider.renameCategory(
                  currentName,
                  newName,
                  isIncome: isIncome,
                );
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text('Category renamed to "$newName".'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
              Navigator.pop(ctx);
            },
            child: Text(
              'Rename',
              style: GoogleFonts.workSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTabColor = isDark ? const Color(0xFF8E75C8) : AppColors.buttonColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.translate('manage_categories'),
          style: GoogleFonts.workSans(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryTabColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryTabColor,
          labelStyle: GoogleFonts.workSans(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          tabs: [
            Tab(text: context.translate('expense')),
            Tab(text: context.translate('income')),
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

  Widget _buildCategoryListSection(
    TransactionProvider provider, {
    required bool isIncome,
  }) {
    final categories = isIncome
        ? provider.incomeCategories
        : provider.expenseCategories;
    final themeColor = isIncome ? AppColors.activeGreen : AppColors.activeRed;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                        Image.asset(
                          AppImages.categoriesIcon,
                          width: 100,
                          height: 100,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.translate('no_categories_yet'),
                          style: GoogleFonts.workSans(
                            color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                            fontSize: 14,
                          ),
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
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF0F0F0)),
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
                          onEdit: () => _showRenameDialog(
                            context,
                            provider,
                            cat,
                            isIncome,
                          ),
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
