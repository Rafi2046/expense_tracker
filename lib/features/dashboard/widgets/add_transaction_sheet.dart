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
  final TransactionItem? transaction;

  const AddTransactionSheet({
    super.key,
    required this.isIncome,
    this.transaction,
  });

  bool get isEditing => transaction != null;

  static void show({
    required BuildContext context,
    required bool isIncome,
    TransactionItem? transaction,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionSheet(
        isIncome: isIncome,
        transaction: transaction,
      ),
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
  String? _selectedIncomeMonth;
  String _paymentMethod = 'Cash';

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    if (tx != null) {
      _amountController.text = tx.amount.toString();
      _noteController.text = tx.note;
      _selectedCategory = tx.category;
      _selectedDate = tx.dateTime;
      _selectedIncomeMonth = tx.incomeMonth;
      _paymentMethod = tx.paymentMethod;
    } else {
      final provider = context.read<TransactionProvider>();
      if (widget.isIncome) {
        _selectedIncomeMonth = DateFormat('MMMM yyyy').format(DateTime.now());
        final categories = provider.incomeCategories;
        if (categories.isNotEmpty) {
          final idx = categories.indexWhere((c) => c.toLowerCase().contains('salary'));
          _selectedCategory = idx != -1 ? categories[idx] : categories.first;
        }
      } else {
        final categories = provider.expenseCategories;
        if (categories.isNotEmpty) {
          final idx = categories.indexWhere((c) => c.toLowerCase().contains('misc') || c.toLowerCase().contains('other'));
          _selectedCategory = idx != -1 ? categories[idx] : categories.first;
        }
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final theme = Theme.of(context);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: widget.isIncome
                  ? theme.primaryColor
                  : AppColors.activeRed,
              onPrimary: Colors.white,
              onSurface: theme.colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        if (widget.isIncome) {
          _selectedIncomeMonth = DateFormat('MMMM yyyy').format(picked);
        }
      });
    }
  }

  void _showMonthSelector(BuildContext context) {
    final provider = context.read<TransactionProvider>();
    final months = provider.availableMonths;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final innerTheme = Theme.of(ctx);
        final innerIsDark = innerTheme.brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            color: innerTheme.cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: innerIsDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Income Month',
                style: GoogleFonts.workSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: innerTheme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.40,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: months.length,
                  separatorBuilder: (context, index) =>
                      Divider(color: innerTheme.dividerTheme.color ?? const Color(0xFFF5F5F5), height: 1),
                  itemBuilder: (context, index) {
                    final monthDate = months[index];
                    final label = DateFormat('MMMM yyyy').format(monthDate);
                    final isSelected = _selectedIncomeMonth == label;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        label,
                        style: GoogleFonts.workSans(
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: innerTheme.colorScheme.onSurface,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: AppColors.activeGreen,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedIncomeMonth = label;
                        });
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
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
    final existing = widget.transaction;
    final noteText = _noteController.text.trim();
    final finalNote = noteText.isEmpty && widget.isIncome && _selectedCategory != null
        ? '$_selectedCategory for $_selectedIncomeMonth'
        : noteText;

    if (existing != null) {
      final updatedItem = TransactionItem(
        id: existing.id,
        amount: amount,
        category: _selectedCategory!,
        note: finalNote,
        isIncome: widget.isIncome,
        dateTime: _selectedDate,
        incomeMonth: widget.isIncome ? _selectedIncomeMonth : null,
        paymentMethod: _paymentMethod,
      );
      provider.updateTransaction(updatedItem);
    } else {
      provider.addTransaction(
        TransactionItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          amount: amount,
          category: _selectedCategory!,
          note: finalNote,
          isIncome: widget.isIncome,
          dateTime: _selectedDate,
          incomeMonth: widget.isIncome ? _selectedIncomeMonth : null,
          paymentMethod: _paymentMethod,
        ),
      );
    }

    Navigator.pop(context); // Close bottom sheet

    final action = existing != null ? 'updated' : 'added';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              '${widget.isIncome ? "Income" : "Expense"} $action: ${context.formatAmount(amount, listen: false)}',
              style: GoogleFonts.workSans(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: widget.isIncome
            ? AppColors.activeGreen
            : AppColors.activeRed,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final themeColor = widget.isIncome
        ? theme.primaryColor
        : AppColors.activeRed;
    final secondaryThemeColor = widget.isIncome
        ? theme.primaryColor
        : AppColors.activeRed;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.only(
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
                      color: isDark ? Colors.white24 : Colors.grey.shade300,
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
                      widget.isEditing
                          ? (widget.isIncome ? 'Edit Income' : 'Edit Expense')
                          : (widget.isIncome ? 'Add Income' : 'Add Expense'),
                      style: GoogleFonts.workSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: isDark ? Colors.white60 : Colors.grey.shade600,
                        ),
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
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
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
                          color: isDark ? Colors.white12 : Colors.grey.shade300,
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
                Divider(color: theme.dividerTheme.color ?? Colors.grey.shade100, height: 1),
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
                  valueText: DateFormat(
                    'EEEE, MMM d, yyyy',
                  ).format(_selectedDate),
                  isValueSelected: true,
                  themeColor: secondaryThemeColor,
                  trailingIcon: Icons.edit_calendar_outlined,
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 16),

                // Income Month Selector Tile (Only for income)
                if (widget.isIncome) ...[
                  TransactionSelectorTile(
                    leadingIcon: Icons.calendar_month_outlined,
                    labelText: 'Income Month',
                    valueText: _selectedIncomeMonth ?? 'Select Month',
                    isValueSelected: _selectedIncomeMonth != null,
                    themeColor: secondaryThemeColor,
                    trailingIcon: Icons.arrow_forward_ios_rounded,
                    onTap: () => _showMonthSelector(context),
                  ),
                  const SizedBox(height: 16),
                ],

                // Payment Mode Selector Tile
                TransactionSelectorTile(
                  leadingIcon: Icons.account_balance_wallet_outlined,
                  labelText: 'Payment Mode',
                  valueText: _paymentMethod,
                  isValueSelected: true,
                  themeColor: secondaryThemeColor,
                  trailingIcon: Icons.swap_horiz_rounded,
                  onTap: () {
                    setState(() {
                      _paymentMethod = _paymentMethod == 'Cash' ? 'Bank' : 'Cash';
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Note/Memo Input Field
                TextFormField(
                  controller: _noteController,
                  maxLines: 2,
                  style: GoogleFonts.workSans(
                    fontSize: 15,
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add a note/detail (optional)...',
                    hintStyle: GoogleFonts.workSans(
                      fontSize: 15,
                      color: isDark ? Colors.white30 : Colors.grey.shade400,
                    ),
                    prefixIcon: Icon(
                      Icons.notes_rounded,
                      color: isDark ? Colors.white30 : Colors.grey.shade400,
                      size: 22,
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.white10 : Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.dividerTheme.color ?? Colors.grey.shade100,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.dividerTheme.color ?? Colors.grey.shade100,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: secondaryThemeColor,
                        width: 1.5,
                      ),
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
                      widget.isEditing
                          ? (widget.isIncome ? 'Update Income' : 'Update Expense')
                          : (widget.isIncome ? 'Save Income' : 'Save Expense'),
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
