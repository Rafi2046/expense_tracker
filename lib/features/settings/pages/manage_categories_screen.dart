import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/category_input_row.dart';
import 'package:expense_tracker/features/dashboard/widgets/category_list_row.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _expenseInputController = TextEditingController();
  final TextEditingController _incomeInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _expenseInputController.dispose();
    _incomeInputController.dispose();
    super.dispose();
  }

  void _addCategory(bool isIncome) {
    final provider = context.read<TransactionProvider>();
    final controller = isIncome ? _incomeInputController : _expenseInputController;
    final name = controller.text.trim();
    if (name.isEmpty) return;

    final bool added = isIncome
        ? provider.addIncomeCategory(name)
        : provider.addExpenseCategory(name);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (added) {
      controller.clear();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Category "$name" added successfully!'),
          duration: const Duration(seconds: 1),
          backgroundColor: isIncome ? AppColors.activeGreen : AppColors.activeRed,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Category "$name" already exists.'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.orange.shade800,
        ),
      );
    }
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
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
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
              style: AppTextStyles.bodyBold.copyWith(color: Colors.grey.shade600),
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
              style: AppTextStyles.bodyBold.copyWith(color: Colors.white),
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
          icon: Icon(LucideIcons.arrowLeft, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.translate('manage_categories'),
          style: AppTextStyles.h2.copyWith(color: theme.colorScheme.onSurface),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryTabColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryTabColor,
          labelStyle: AppTextStyles.bodyBold,
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
    final controller = isIncome ? _incomeInputController : _expenseInputController;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Inline Input Row
          CategoryInputRow(
            controller: controller,
            themeColor: themeColor,
            onSubmitted: (_) => _addCategory(isIncome),
            onAddPressed: () => _addCategory(isIncome),
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
                          style: AppTextStyles.body.copyWith(
                            fontFamily: GoogleFonts.workSans().fontFamily,
                            color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
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
