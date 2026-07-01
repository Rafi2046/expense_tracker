import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/balance_analytics_provider.dart';
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
  final bool enableBalanceWarning;

  const AddTransactionSheet({
    super.key,
    required this.isIncome,
    this.transaction,
    this.enableBalanceWarning = false,
  });

  bool get isEditing => transaction != null;

  static void show({
    required BuildContext context,
    required bool isIncome,
    TransactionItem? transaction,
    bool enableBalanceWarning = false,
  }) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionSheet(
        isIncome: isIncome,
        transaction: transaction,
        enableBalanceWarning: enableBalanceWarning,
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

  Future<void> _save(BuildContext context) async {
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

      if (widget.enableBalanceWarning && widget.transaction == null) {
        final balanceProvider = context.read<BalanceAnalyticsProvider>();
        final projected = balanceProvider.projectedBalance(
          _paymentMethod,
          amount: amount,
          isIncome: widget.isIncome,
        );
        if (projected < 0) {
          final theme = Theme.of(context);
          final proceed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Balance Will Go Negative',
                style: GoogleFonts.workSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              content: Text(
                'This will bring your $_paymentMethod balance to '
                '${context.formatAmount(projected, listen: false)}.\n\n'
                'Are you sure you want to proceed?',
                style: GoogleFonts.workSans(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text('Cancel',
                    style: GoogleFonts.workSans(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.activeRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Proceed',
                    style: GoogleFonts.workSans(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
          if (proceed != true) return;
        }
      }

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
        debugPrint('DIAG SAVE: _selectedDate=$_selectedDate month=${_selectedDate.month} day=${_selectedDate.day}');
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

    final double keyboardPadding = MediaQuery.of(context).viewInsets.bottom;
    final double systemBottomPadding = MediaQueryData.fromView(View.of(context)).padding.bottom;
    final double bottomPadding = keyboardPadding > 0
        ? 20
        : systemBottomPadding + 84;

    final double availableHeight = MediaQuery.of(context).size.height - keyboardPadding;
    final double maxHeight = availableHeight * 0.82;

    return Padding(
      padding: EdgeInsets.only(
        bottom: keyboardPadding,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
        ),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.br20),
            topRight: Radius.circular(AppSpacing.br20),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.p24,
          AppSpacing.p20,
          AppSpacing.p24,
          bottomPadding,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TransactionSheetHeader(
                isEditing: widget.isEditing,
                isIncome: widget.isIncome,
                onClose: () => Navigator.pop(context),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TransactionAmountInput(
                        controller: _amountController,
                        themeColor: themeColor,
                        currencySymbol: context.currencySymbol,
                      ),
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TransactionSaveButton(
                onPressed: () async { await _save(context); },
                themeColor: themeColor,
                title: widget.isEditing
                    ? (widget.isIncome ? 'Update Income' : 'Update Expense')
                    : (widget.isIncome ? 'Save Income' : 'Save Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    debugPrint('DIAG PICKER ENTERED: _selectedDate=$_selectedDate month=${_selectedDate.month}');
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
    debugPrint('DIAG PICKER RETURNED: picked=$picked');
    if (picked != null && picked != _selectedDate) {
      debugPrint('DIAG PICKER SELECTED: picked=$picked month=${picked.month} day=${picked.day}');
      setState(() {
        _selectedDate = picked;
        debugPrint('DIAG PICKER SETSTATE: _selectedDate=$_selectedDate month=${_selectedDate.month}');
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
