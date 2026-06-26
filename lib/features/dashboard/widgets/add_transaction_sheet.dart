import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_transaction_components/amount_input_field.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_transaction_components/note_input_field.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_transaction_components/save_transaction_button.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_transaction_components/sheet_header.dart';
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
      builder: (context) =>
          AddTransactionSheet(isIncome: isIncome, transaction: transaction),
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
  late DateTime _selectedDate;
  String? _selectedIncomeMonth;
  String _paymentMethod = 'Cash';

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    _selectedDate = tx?.dateTime ?? DateTime.now();

    if (tx != null) {
      _amountController.text = tx.amount.toString();
      _noteController.text = tx.note;
      _selectedCategory = tx.category;
      _selectedIncomeMonth = tx.incomeMonth;
      _paymentMethod = tx.paymentMethod;
    } else {
      // Set the month dynamically when opening
      if (widget.isIncome) {
        _selectedIncomeMonth = DateFormat('MMMM yyyy').format(_selectedDate);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This safely waits for the Provider to have data and updates the UI instantly
    if (_selectedCategory == null && widget.transaction == null) {
      final provider = Provider.of<TransactionProvider>(
        context,
      ); // Automatically listens
      final cats = widget.isIncome
          ? provider.incomeCategories
          : provider.expenseCategories;

      if (cats.isNotEmpty) {
        final targetSearch = widget.isIncome ? 'salary' : 'misc';
        final defaultCat = cats.firstWhere(
          (c) => c.toLowerCase().contains(targetSearch),
          orElse: () => cats.first,
        );

        // Use Future.microtask to avoid build-phase collisions
        Future.microtask(() {
          if (mounted && _selectedCategory == null) {
            setState(() {
              _selectedCategory = defaultCat;
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // Uses Dialog instead of SnackBar to guarantee it shows ABOVE the BottomSheet
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.activeRed),
            const SizedBox(width: 8),
            Text(
              'Missing Info',
              style: GoogleFonts.workSans(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(message, style: GoogleFonts.workSans(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'OK',
              style: GoogleFonts.workSans(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
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
                  separatorBuilder: (context, index) => Divider(
                    color:
                        innerTheme.dividerTheme.color ??
                        const Color(0xFFF5F5F5),
                    height: 1,
                  ),
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
    try {
      final amount = double.tryParse(_amountController.text) ?? 0.0;

      if (amount <= 0) {
        _showErrorDialog('Please enter a valid amount greater than 0.');
        return;
      }

      if (_selectedCategory == null || _selectedCategory!.isEmpty) {
        _showErrorDialog('Please select a category before saving.');
        return;
      }

      if (!_formKey.currentState!.validate()) return;

      final provider = context.read<TransactionProvider>();
      final existing = widget.transaction;
      final noteText = _noteController.text.trim();

      final finalNote = noteText.isEmpty && widget.isIncome
          ? 'Income for $_selectedIncomeMonth'
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

      Navigator.pop(context);

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
    } catch (e) {
      _showErrorDialog('Something went wrong. Please check your inputs.');
      debugPrint('Save error: $e');
    }
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
                SheetHeader(
                  isEditing: widget.isEditing,
                  isIncome: widget.isIncome,
                  onClose: () => Navigator.pop(context),
                ),
                const SizedBox(height: 24),
                AmountInputField(
                  controller: _amountController,
                  themeColor: themeColor,
                  currencySymbol: context.currencySymbol,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                Divider(
                  color: theme.dividerTheme.color ?? Colors.grey.shade100,
                  height: 1,
                ),
                const SizedBox(height: 20),
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
                TransactionSelectorTile(
                  leadingIcon: Icons.account_balance_wallet_outlined,
                  labelText: 'Payment Mode',
                  valueText: _paymentMethod,
                  isValueSelected: true,
                  themeColor: secondaryThemeColor,
                  trailingIcon: Icons.swap_horiz_rounded,
                  onTap: () {
                    setState(() {
                      _paymentMethod = _paymentMethod == 'Cash'
                          ? 'Bank'
                          : 'Cash';
                    });
                  },
                ),
                const SizedBox(height: 16),
                NoteInputField(
                  controller: _noteController,
                  focusColor: secondaryThemeColor,
                  isDark: isDark,
                ),
                const SizedBox(height: 24),
                SaveTransactionButton(
                  onPressed: () => _save(context),
                  isEditing: widget.isEditing,
                  isIncome: widget.isIncome,
                  backgroundColor: themeColor,
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
