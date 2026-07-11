import 'package:expense_tracker/features/dashboard/widgets/select_category_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/transaction_selector_tile.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CategorySelector extends StatelessWidget {
  final String? selectedCategory;
  final Color themeColor;
  final bool isIncome;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback? onTap;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.themeColor,
    required this.isIncome,
    required this.onCategorySelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TransactionSelectorTile(
      leadingIcon: LucideIcons.grid,
      labelText: 'Category',
      valueText: selectedCategory ?? 'Select Category',
      isValueSelected: selectedCategory != null,
      themeColor: themeColor,
      trailingIcon: LucideIcons.arrowRight,
      onTap: onTap ?? () {
        SelectCategorySheet.show(
          context: context,
          isIncome: isIncome,
          selectedCategory: selectedCategory,
          onCategorySelected: onCategorySelected,
        );
      },
    );
  }
}
