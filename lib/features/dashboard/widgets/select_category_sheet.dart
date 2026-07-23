import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_new_category_tile.dart';
import 'package:expense_tracker/features/dashboard/widgets/category_list_row.dart';
import 'package:expense_tracker/features/dashboard/widgets/category_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';


class SelectCategorySheet extends StatefulWidget {
  final bool isIncome;
  final String? selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const SelectCategorySheet({
    super.key,
    required this.isIncome,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  static Future<void> show({
    required BuildContext context,
    required bool isIncome,
    String? selectedCategory,
    required ValueChanged<String> onCategorySelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectCategorySheet(
        isIncome: isIncome,
        selectedCategory: selectedCategory,
        onCategorySelected: onCategorySelected,
      ),
    );
  }

  @override
  State<SelectCategorySheet> createState() => _SelectCategorySheetState();
}

class _SelectCategorySheetState extends State<SelectCategorySheet> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isHidden = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddNewCategoryDialog(
    BuildContext context,
    TransactionProvider provider,
  ) async {
    setState(() => _isHidden = true);
    final textController = TextEditingController();
    try {
      await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.r16),
        ),
        title: Text(
          widget.isIncome
              ? context.translate('add_new_income_category')
              : context.translate('add_new_expense_category'),
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: context.translate('category_name'),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.p16,
              vertical: AppSpacing.p12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.r8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.r8),
              borderSide: BorderSide(
                color: widget.isIncome
                    ? AppColors.activeGreen
                    : AppColors.activeRed,
                width: 2,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.translate('cancel'),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isIncome
                  ? AppColors.activeGreen
                  : AppColors.activeRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.r8),
              ),
            ),
            onPressed: () {
              final name = textController.text.trim();
              if (name.isNotEmpty) {
                if (widget.isIncome) {
                  provider.addIncomeCategory(name);
                } else {
                  provider.addExpenseCategory(name);
                }
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context); // Close category bottom sheet
                widget.onCategorySelected(name); // Notify callback
              }
            },
            child: Text(
              context.translate('add'),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    } finally {
      textController.dispose();
      if (mounted) {
        setState(() => _isHidden = false);
      }
    }
  }

  void _showRenameDialog(
    BuildContext context,
    TransactionProvider provider,
    String currentName,
    bool isIncome,
  ) async {
    setState(() => _isHidden = true);
    final controller = TextEditingController(text: currentName);
    final themeColor = isIncome ? AppColors.activeGreen : AppColors.activeRed;

    try {
      await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.r16),
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
              horizontal: AppSpacing.p16,
              vertical: AppSpacing.p12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.r8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.r8),
              borderSide: BorderSide(color: themeColor, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.translate('cancel'),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.r8),
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
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    } finally {
      controller.dispose();
      if (mounted) {
        setState(() => _isHidden = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final allCategories = widget.isIncome
        ? provider.incomeCategories
        : provider.expenseCategories;

    final filteredCategories = allCategories
        .where((c) => c.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    final activeThemeColor = widget.isIncome
        ? AppColors.activeGreen
        : AppColors.activeRed;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isHidden) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: const SizedBox.shrink(),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.r24),
            topRight: Radius.circular(AppSpacing.r24),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.16)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(AppSpacing.r12),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s16),

              Text(
                widget.isIncome
                    ? context.translate('select_category_for_income')
                    : context.translate('select_category_for_expense'),
                style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: AppSpacing.s16),

              CategorySearchBar(
                controller: _searchController,
                activeThemeColor: activeThemeColor,
                isDark: isDark,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.s12),

              AddNewCategoryTile(
                isDark: isDark,
                onTap: () => _showAddNewCategoryDialog(context, provider),
              ),
              const SizedBox(height: AppSpacing.s16),

              // Scrollable List
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.40,
                ),
                child: filteredCategories.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.p16),
                          child: Text(
                            context.translate('no_categories_found'),
                            style: AppTextStyles.body.copyWith(color: isDark ? Colors.white38 : Colors.grey.shade400),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: filteredCategories.length,
                        separatorBuilder: (context, index) => Divider(
                          color: isDark
                              ? theme.colorScheme.onSurface.withValues(alpha: 0.08)
                              : const Color(0xFFF5F5F5),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final cat = filteredCategories[index];
                          final isSelected = cat == widget.selectedCategory;

                          return CategoryListRow(
                            categoryName: cat,
                            themeColor: activeThemeColor,
                            isSelected: isSelected,
                            showSelection: true,
                            showLeadingIcon: false,
                            onTap: () {
                              Navigator.pop(context);
                              widget.onCategorySelected(cat);
                            },
                            onDelete: () {
                              if (widget.isIncome) {
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
                              widget.isIncome,
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: AppSpacing.s8),
            ],
          ),
        ),
      ),
    );
  }
}
