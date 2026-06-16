import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/select_category_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/transaction_selector_tile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddTransactionSheet extends StatefulWidget {
  final bool isIncome;

  const AddTransactionSheet({
    super.key,
    required this.isIncome,
  });

  static void show({
    required BuildContext context,
    required bool isIncome,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionSheet(isIncome: isIncome),
    );
  }

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: widget.isIncome ? AppColors.buttonColor : AppColors.activeRed,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _save(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Amount must be greater than zero'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final provider = context.read<TransactionProvider>();
    final newItem = TransactionItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      category: _selectedCategory!,
      note: _noteController.text.trim(),
      isIncome: widget.isIncome,
      dateTime: _selectedDate,
    );

    provider.addTransaction(newItem);

    Navigator.pop(context); // Close bottom sheet

    // Show high-end success toast/snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              '${widget.isIncome ? "Income" : "Expense"} added: ${context.formatAmount(amount)}',
              style: GoogleFonts.workSans(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: widget.isIncome ? AppColors.activeGreen : AppColors.activeRed,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.isIncome ? AppColors.buttonColor : AppColors.activeRed;
    final secondaryThemeColor = widget.isIncome ? AppColors.activeGreen : AppColors.activeRed;

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
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Drag handle
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
              const SizedBox(height: 16),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isIncome ? 'Add Income' : 'Add Expense',
                    style: GoogleFonts.workSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 20, color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Large Amount Input
              Center(
                child: SizedBox(
                  width: 260,
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.workSans(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                    decoration: InputDecoration(
                      prefixText: '${context.currencySymbol} ',
                      prefixStyle: GoogleFonts.workSans(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: themeColor.withValues(alpha: 0.6),
                      ),
                      hintText: '0.00',
                      hintStyle: GoogleFonts.workSans(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade300,
                      ),
                      border: InputBorder.none,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Enter an amount';
                      }
                      if (double.tryParse(val) == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Divider
              Divider(color: Colors.grey.shade100, height: 1),
              const SizedBox(height: 20),

              // Category Selector Tile
              TransactionSelectorTile(
                leadingIcon: Icons.category_outlined,
                labelText: 'Category',
                valueText: _selectedCategory ?? 'Select Category',
                isValueSelected: _selectedCategory != null,
                themeColor: secondaryThemeColor,
                trailingIcon: Icons.arrow_forward_ios_rounded,
                onTap: () {
                  SelectCategorySheet.show(
                    context: context,
                    isIncome: widget.isIncome,
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (cat) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Date Selector Tile
              TransactionSelectorTile(
                leadingIcon: Icons.calendar_today_outlined,
                labelText: 'Date',
                valueText: DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                isValueSelected: true,
                themeColor: secondaryThemeColor,
                trailingIcon: Icons.edit_calendar_outlined,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),

              // Note/Memo Input Field
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                style: GoogleFonts.workSans(fontSize: 15, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Add a note/detail (optional)...',
                  hintStyle: GoogleFonts.workSans(fontSize: 15, color: Colors.grey.shade400),
                  prefixIcon: Icon(Icons.notes_rounded, color: Colors.grey.shade400, size: 22),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade100, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade100, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: secondaryThemeColor, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Solid Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 1,
                  ),
                  onPressed: () => _save(context),
                  child: Text(
                    widget.isIncome ? 'Save Income' : 'Save Expense',
                    style: GoogleFonts.workSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    ),
  );
}
}
