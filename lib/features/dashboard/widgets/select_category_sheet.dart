import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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

  static void show({
    required BuildContext context,
    required bool isIncome,
    String? selectedCategory,
    required ValueChanged<String> onCategorySelected,
  }) {
    showModalBottomSheet(
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddNewCategoryDialog(BuildContext context, TransactionProvider provider) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.r16),
        ),
        title: Text(
          widget.isIncome ? 'Add New Income Category' : 'Add New Expense Category',
          style: GoogleFonts.workSans(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Category Name',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: widget.isIncome ? AppColors.activeGreen : AppColors.activeRed,
                width: 2,
              ),
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
              backgroundColor: widget.isIncome ? AppColors.activeGreen : AppColors.activeRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
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
              'Add',
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
    final allCategories = widget.isIncome ? provider.incomeCategories : provider.expenseCategories;
    
    final filteredCategories = allCategories
        .where((c) => c.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    final activeThemeColor = widget.isIncome ? AppColors.activeGreen : AppColors.activeRed;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
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
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),
            
            Text(
              widget.isIncome ? 'Select Category for Income' : 'Select Category for Expense',
              style: GoogleFonts.workSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Search input field matching mockup exactly
            TextField(
              controller: _searchController,
              style: GoogleFonts.workSans(
                fontSize: 15,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Search Category...',
                hintStyle: GoogleFonts.workSans(
                  fontSize: 15,
                  color: Colors.grey.shade400,
                ),
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: activeThemeColor, width: 1.5),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
            const SizedBox(height: 16),

            // Scrollable List
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.40,
              ),
              child: filteredCategories.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'No categories found.',
                          style: GoogleFonts.workSans(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredCategories.length,
                      separatorBuilder: (context, index) => const Divider(
                        color: Color(0xFFF5F5F5),
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final cat = filteredCategories[index];
                        final isSelected = cat == widget.selectedCategory;

                        return Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  widget.onCategorySelected(cat);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        cat,
                                        style: GoogleFonts.workSans(
                                          fontSize: 15,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected ? activeThemeColor : Colors.grey.shade300,
                                            width: isSelected ? 6 : 2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                              onPressed: () {
                                if (widget.isIncome) {
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
                          ],
                        );
                      },
                    ),
            ),
            
            const SizedBox(height: 16),

            // Bottom Border Button: + Add New Category
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add New Category'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: BorderSide(color: Colors.grey.shade200, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: GoogleFonts.workSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                onPressed: () => _showAddNewCategoryDialog(context, provider),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}
}
