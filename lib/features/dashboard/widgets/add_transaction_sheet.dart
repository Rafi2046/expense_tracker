import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/balance_analytics_provider.dart';
import 'package:expense_tracker/core/providers/account_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_transaction_components/error_dialog.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_transaction_components/month_selector_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_transaction_components/party_selector_tile.dart';
import 'package:expense_tracker/features/dashboard/widgets/select_party_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/sheet_components/category_selector.dart';
import 'package:expense_tracker/features/dashboard/widgets/select_category_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/sheet_components/date_selector.dart';
import 'package:expense_tracker/features/dashboard/widgets/sheet_components/income_month_selector.dart';
import 'package:expense_tracker/features/dashboard/widgets/sheet_components/payment_mode_selector.dart';
import 'package:expense_tracker/features/dashboard/widgets/sheet_components/transaction_amount_input.dart';
import 'package:expense_tracker/features/dashboard/widgets/sheet_components/transaction_note_input.dart';
import 'package:expense_tracker/features/dashboard/widgets/sheet_components/transaction_save_button.dart';
import 'package:expense_tracker/features/dashboard/widgets/sheet_components/transaction_sheet_header.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.85,
        expand: true,
        builder: (context, scrollController) => AddTransactionSheet(
          isIncome: isIncome,
          transaction: transaction,
          enableBalanceWarning: enableBalanceWarning,
        ),
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
  bool _isHidden = false;
  bool _initialized = false;

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
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      if (widget.transaction == null && widget.isIncome) {
        _selectedIncomeMonth = context.formatDate(_selectedDate, pattern: 'MMMM yyyy');
      }
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
    if (widget.transaction == null && _paymentMethod == 'Cash') {
      final accountProvider = Provider.of<AccountProvider>(context, listen: false);
      final accounts = accountProvider.accounts;
      if (accounts.isNotEmpty && accounts.first.name != 'Cash') {
        Future.microtask(() {
          if (mounted) {
            setState(() => _paymentMethod = accounts.first.name);
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
            messageKey: 'please_enter_valid_amount',
          ),
        );
        return;
      }

      if (_selectedCategory == null || _selectedCategory!.isEmpty) {
        showDialog(
          context: context,
          builder: (_) => const ErrorDialog(
            messageKey: 'please_select_category',
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
                context.translate('balance_will_go_negative'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppFontSizes.size16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              content: Text(
                context.translate('balance_warning_body', namedArgs: {
                  'account': _paymentMethod == 'Cash' || _paymentMethod == 'Bank'
                      ? context.translate(_paymentMethod.toLowerCase())
                      : _paymentMethod,
                  'amount': context.formatAmount(projected, listen: false),
                }),
                style: TextStyle(
                  fontSize: AppFontSizes.size14,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(
                    context.translate('cancel'),
                    style: TextStyle(
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
                  child: Text(
                    context.translate('proceed'),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
          if (proceed != true || !context.mounted) return;
        }
      }

      final provider = context.read<TransactionProvider>();
      final existing = widget.transaction;
      final noteText = _noteController.text.trim();

      final finalNote = noteText.isEmpty && widget.isIncome
          ? context.translate('income_for_month', namedArgs: {'month': _selectedIncomeMonth!})
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
        debugPrint(
          'DIAG SAVE: _selectedDate=$_selectedDate month=${_selectedDate.month} day=${_selectedDate.day}',
        );
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

      final monthIdx = provider.availableMonths.indexWhere(
        (m) => m.year == _selectedDate.year && m.month == _selectedDate.month,
      );
      if (monthIdx >= 0) {
        provider.selectMonthIndex(monthIdx);
      }

      Navigator.pop(context);

      final action = existing != null ? context.translate('updated') : context.translate('added');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(LucideIcons.checkCircle, color: Colors.white),
              const SizedBox(width: AppSpacing.w8),
              Text(
                context.translate('transaction_saved_snackbar', namedArgs: {
                  'type': context.translate(widget.isIncome ? 'income' : 'expense'),
                  'action': action,
                  'amount': context.formatAmount(amount, listen: false),
                }),
                style: TextStyle(fontWeight: FontWeight.w600),
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
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (_) => const ErrorDialog(
          messageKey: 'something_went_wrong',
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

    final double bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: _isHidden ? Colors.transparent : theme.cardColor,
        borderRadius: _isHidden
            ? BorderRadius.zero
            : const BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.br20),
                topRight: Radius.circular(AppSpacing.br20),
              ),
      ),
      child: _isHidden
          ? const SizedBox.shrink()
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.p24,
                      AppSpacing.p20,
                      AppSpacing.p24,
                      0,
                    ),
                    child: TransactionSheetHeader(
                      isEditing: widget.isEditing,
                      isIncome: widget.isIncome,
                      onClose: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.p24,
                      ),
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
                            onTap: () async {
                              setState(() => _isHidden = true);
                              await SelectCategorySheet.show(
                                context: context,
                                isIncome: widget.isIncome,
                                selectedCategory: _selectedCategory,
                                onCategorySelected: (cat) =>
                                    setState(() => _selectedCategory = cat),
                              );
                              if (mounted) {
                                setState(() => _isHidden = false);
                              }
                            },
                          ),
                          const SizedBox(height: AppSpacing.h12),
                          DateSelector(
                            dateText: context.formatDate(
                              _selectedDate,
                              pattern: 'EEEE, MMM d, yyyy',
                            ),
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
                            onTap: () => _showAccountPicker(context),
                          ),
                          const SizedBox(height: AppSpacing.h12),
                          PartySelectorTile(
                            selectedPartyName: _selectedPartyName,
                            themeColor: themeColor,
                            onClear: () =>
                                setState(() => _selectedPartyName = null),
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
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.p24,
                      0,
                      AppSpacing.p24,
                      bottomInset + 24,
                    ),
                    child: TransactionSaveButton(
                      onPressed: () async {
                        await _save(context);
                      },
                      themeColor: themeColor,
                      isEditing: widget.isEditing,
                      title: widget.isEditing
                          ? (widget.isIncome
                                ? context.translate('update_income')
                                : context.translate('update_expense'))
                          : (widget.isIncome ? context.translate('save_income') : context.translate('save_expense')),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    debugPrint(
      'DIAG PICKER ENTERED: _selectedDate=$_selectedDate month=${_selectedDate.month}',
    );
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
      debugPrint(
        'DIAG PICKER SELECTED: picked=$picked month=${picked.month} day=${picked.day}',
      );
      setState(() {
        _selectedDate = picked;
        debugPrint(
          'DIAG PICKER SETSTATE: _selectedDate=$_selectedDate month=${_selectedDate.month}',
        );
        if (widget.isIncome) {
          _selectedIncomeMonth = context.formatDate(picked, pattern: 'MMMM yyyy');
        }
      });
    }
  }

  void _showMonthSheet(BuildContext context) async {
    setState(() => _isHidden = true);
    final provider = context.read<TransactionProvider>();
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MonthSelectorSheet(
        months: provider.availableMonths,
        selectedMonth: _selectedIncomeMonth,
        onSelect: (label) {
          setState(() {
            _selectedIncomeMonth = label;
            try {
              _selectedDate = DateFormat('MMMM yyyy', context.locale.toString()).parse(label);
            } catch (_) {}
          });
          Navigator.pop(ctx);
        },
      ),
    );
    if (mounted) {
      setState(() => _isHidden = false);
    }
  }

  void _showPartySheet(BuildContext context) async {
    setState(() => _isHidden = true);
    final debtProvider = context.read<DebtProvider>();
    await showSelectPartySheet(
      context: context,
      debtProvider: debtProvider,
      selectedPartyName: _selectedPartyName,
      isIncome: widget.isIncome,
      onSelect: (name) => setState(() => _selectedPartyName = name),
      onClear: () => setState(() => _selectedPartyName = null),
    );
    if (mounted) {
      setState(() => _isHidden = false);
    }
  }

  void _showAccountPicker(BuildContext context) async {
    final accountProvider = context.read<AccountProvider>();
    final accounts = accountProvider.accounts;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).padding.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.translate('select_account'),
                style: AppTextStyles.h3.copyWith(color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 12),
              ...accounts.map((account) => ListTile(
                leading: Icon(
                  account.name == 'Cash'
                      ? LucideIcons.creditCard
                      : account.name == 'Bank'
                          ? LucideIcons.landmark
                          : LucideIcons.wallet,
                  color: _paymentMethod == account.name
                      ? theme.primaryColor
                      : theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                title: Text(
                  account.name == 'Cash' || account.name == 'Bank'
                      ? context.translate(account.name.toLowerCase())
                      : account.name,
                  style: AppTextStyles.body.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: _paymentMethod == account.name
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                trailing: _paymentMethod == account.name
                    ? Icon(LucideIcons.check, color: theme.primaryColor, size: 18)
                    : null,
                onTap: () {
                  setState(() => _paymentMethod = account.name);
                  Navigator.pop(ctx);
                },
              )),
            ],
          ),
        );
      },
    );
  }
}
