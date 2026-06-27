import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_transaction_components/error_dialog.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_transaction_components/month_selector_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_transaction_components/party_selector_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_transaction_components/party_selector_tile.dart';
import 'package:expense_tracker/features/dashboard/widgets/sheet_components/category_selector.dart';
import 'package:expense_tracker/features/dashboard/widgets/sheet_components/date_selector.dart';
import 'package:expense_tracker/features/dashboard/widgets/sheet_components/income_month_selector.dart';
import 'package:expense_tracker/features/dashboard/widgets/sheet_components/payment_mode_selector.dart';
import 'package:expense_tracker/features/dashboard/widgets/sheet_components/transaction_amount_input.dart';
import 'package:expense_tracker/features/dashboard/widgets/sheet_components/transaction_note_input.dart';
import 'package:expense_tracker/features/dashboard/widgets/sheet_components/transaction_save_button.dart';
import 'package:expense_tracker/features/dashboard/widgets/sheet_components/transaction_sheet_header.dart';
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
  String? _selectedPartyName;

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
      _selectedPartyName = tx.partyName;
    } else {
      if (widget.isIncome) {
        _selectedIncomeMonth = DateFormat('MMMM yyyy').format(_selectedDate);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedCategory == null && widget.transaction == null) {
      final provider = Provider.of<TransactionProvider>(context);
      final cats = widget.isIncome
          ? provider.incomeCategories
          : provider.expenseCategories;

      if (cats.isNotEmpty) {
        final targetSearch = widget.isIncome ? 'salary' : 'misc';
        final defaultCat = cats.firstWhere(
          (c) => c.toLowerCase().contains(targetSearch),
          orElse: () => cats.first,
        );

        Future.microtask(() {
          if (mounted && _selectedCategory == null) {
            setState(() => _selectedCategory = defaultCat);
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

  void _save(BuildContext context) {
    try {
      final amount = double.tryParse(_amountController.text) ?? 0.0;

      if (amount <= 0) {
        showDialog(
          context: context,
          builder: (_) => const ErrorDialog(
            message: 'Please enter a valid amount greater than 0.',
          ),
        );
        return;
      }

      if (_selectedCategory == null || _selectedCategory!.isEmpty) {
        showDialog(
          context: context,
          builder: (_) => const ErrorDialog(
            message: 'Please select a category before saving.',
          ),
        );
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
          partyName: _selectedPartyName,
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
            partyName: _selectedPartyName,
          ),
        );
      }

      Navigator.pop(context);

      final action = existing != null ? 'updated' : 'added';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Symbols.check_circle_outline, color: Colors.white),
              const SizedBox(width: AppSpacing.w8),
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
      showDialog(
        context: context,
        builder: (_) => const ErrorDialog(
          message: 'Something went wrong. Please check your inputs.',
        ),
      );
      debugPrint('Save error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeColor = widget.isIncome
        ? theme.primaryColor
        : AppColors.activeRed;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.br20),
            topRight: Radius.circular(AppSpacing.br20),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.p24,
          vertical: AppSpacing.p20,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TransactionSheetHeader(
                  isEditing: widget.isEditing,
                  isIncome: widget.isIncome,
                  onClose: () => Navigator.pop(context),
                ),
                const SizedBox(height: 28),
                TransactionAmountInput(
                  controller: _amountController,
                  themeColor: themeColor,
                  currencySymbol: context.currencySymbol,
                ),
                const SizedBox(height: 28),
                CategorySelector(
                  selectedCategory: _selectedCategory,
                  themeColor: themeColor,
                  isIncome: widget.isIncome,
                  onCategorySelected: (cat) =>
                      setState(() => _selectedCategory = cat),
                ),
                const SizedBox(height: AppSpacing.h12),
                DateSelector(
                  dateText: DateFormat(
                    'EEEE, MMM d, yyyy',
                  ).format(_selectedDate),
                  themeColor: themeColor,
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: AppSpacing.h12),
                if (widget.isIncome) ...[
                  IncomeMonthSelector(
                    selectedIncomeMonth: _selectedIncomeMonth,
                    themeColor: themeColor,
                    onTap: () => _showMonthSheet(context),
                  ),
                  const SizedBox(height: AppSpacing.h12),
                ],
                PaymentModeSelector(
                  paymentMethod: _paymentMethod,
                  themeColor: themeColor,
                  onTap: () => setState(() {
                    _paymentMethod = _paymentMethod == 'Cash' ? 'Bank' : 'Cash';
                  }),
                ),
                const SizedBox(height: AppSpacing.h12),
                PartySelectorTile(
                  selectedPartyName: _selectedPartyName,
                  themeColor: themeColor,
                  onClear: () => setState(() => _selectedPartyName = null),
                  onTap: () => _showPartySheet(context),
                ),
                const SizedBox(height: AppSpacing.h12),
                TransactionNoteInput(
                  controller: _noteController,
                  themeColor: themeColor,
                ),
                const SizedBox(height: 28),
                TransactionSaveButton(
                  onPressed: () => _save(context),
                  themeColor: themeColor,
                  title: widget.isEditing
                      ? (widget.isIncome ? 'Update Income' : 'Update Expense')
                      : (widget.isIncome ? 'Save Income' : 'Save Expense'),
                ),
                const SizedBox(height: AppSpacing.h12),
              ],
            ),
          ),
        ),
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

  void _showMonthSheet(BuildContext context) {
    final provider = context.read<TransactionProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MonthSelectorSheet(
        months: provider.availableMonths,
        selectedMonth: _selectedIncomeMonth,
        onSelect: (label) {
          setState(() => _selectedIncomeMonth = label);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showPartySheet(BuildContext context) {
    final debtProvider = context.read<DebtProvider>();
    final Map<String, DebtItem> uniqueParties = {};
    for (var item in debtProvider.items) {
      if (!uniqueParties.containsKey(item.name) ||
          (uniqueParties[item.name]?.phone == null && item.phone != null)) {
        uniqueParties[item.name] = item;
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PartySelectorSheet(
        uniqueParties: uniqueParties,
        selectedPartyName: _selectedPartyName,
        isIncome: widget.isIncome,
        onSelect: (name) {
          setState(() => _selectedPartyName = name);
          Navigator.pop(ctx);
        },
        onClear: () {
          setState(() => _selectedPartyName = null);
          Navigator.pop(ctx);
        },
      ),
    );
  }
}
