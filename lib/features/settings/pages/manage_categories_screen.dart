import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/features/settings/widgets/category_empty_state.dart';
import 'package:expense_tracker/features/settings/widgets/category_list_tile.dart';
import 'package:expense_tracker/features/settings/widgets/category_search_bar.dart';
import 'package:expense_tracker/features/settings/widgets/manage_categories_header.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          content: Text(context.translate('category_added', namedArgs: {'name': name})),
          duration: const Duration(seconds: 1),
          backgroundColor: isIncome ? AppColors.activeGreen : AppColors.activeRed,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('category_exists', namedArgs: {'name': name})),
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
          context.translate('rename_category'),
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: context.translate('category_name'),
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
              context.translate('cancel'),
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
                    content: Text(context.translate('category_renamed', namedArgs: {'name': newName})),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
              Navigator.pop(ctx);
            },
            child: Text(
              context.translate('rename'),
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
      appBar: ManageCategoriesHeader(
        tabController: _tabController,
        primaryTabColor: primaryTabColor,
        onBack: () => Navigator.pop(context),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CategorySearchBar(
            controller: controller,
            themeColor: themeColor,
            onSubmitted: (_) => _addCategory(isIncome),
            onAddPressed: () => _addCategory(isIncome),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: categories.isEmpty
                ? CategoryEmptyState(isDark: isDark)
                : ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return CategoryListTile(
                        categoryName: cat,
                        themeColor: themeColor,
                        isDark: isDark,
                        onDelete: () {
                          if (isIncome) {
                            provider.deleteIncomeCategory(cat);
                          } else {
                            provider.deleteExpenseCategory(cat);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.translate('category_removed', namedArgs: {'name': cat})),
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
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
