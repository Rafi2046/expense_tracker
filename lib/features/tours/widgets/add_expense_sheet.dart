import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:expense_tracker/core/models/tour_expense.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/features/tours/utils/expense_split_calculator.dart';
import 'package:expense_tracker/features/tours/widgets/expense_category_selector.dart';
import 'package:expense_tracker/features/tours/widgets/expense_participant_selector.dart';
import 'package:expense_tracker/features/tours/widgets/expense_split_type_selector.dart';
import 'package:expense_tracker/features/tours/widgets/expense_split_amount_row.dart';
import 'package:expense_tracker/features/tours/widgets/expense_receipt_picker.dart';
import 'package:expense_tracker/features/tours/widgets/expense_date_picker.dart';
import 'package:expense_tracker/features/tours/widgets/expense_validation_banner.dart';
import 'package:expense_tracker/features/tours/widgets/expense_sheet_drag_handle.dart';
import 'package:expense_tracker/features/tours/widgets/expense_hero_section.dart';
import 'package:expense_tracker/features/tours/widgets/expense_add_category_dialog.dart';
import 'package:expense_tracker/features/tours/widgets/expense_late_joiner_banner.dart';
import 'package:expense_tracker/features/tours/widgets/expense_note_field.dart';
import 'package:expense_tracker/features/tours/widgets/expense_save_button.dart';

class AddExpenseSheet extends StatefulWidget {
  final String tourId;
  final List<TourParticipant> participants;
  final String currency;
  final TourExpense? expenseToEdit;

  const AddExpenseSheet({
    super.key,
    required this.tourId,
    required this.participants,
    required this.currency,
    this.expenseToEdit,
  });

  static Future<void> show(
    BuildContext context, {
    required String tourId,
    required List<TourParticipant> participants,
    required String currency,
    TourExpense? expenseToEdit,
  }) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddExpenseSheet(
        tourId: tourId,
        participants: participants,
        currency: currency,
        expenseToEdit: expenseToEdit,
      ),
    );
  }

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _amountFocusNode = FocusNode();
  final _noteController = TextEditingController();
  final _customValues = <String, TextEditingController>{};
  final _picker = ImagePicker();

  String? _selectedCategory;
  final _customCategories = <Map<String, dynamic>>[];
  Map<String, double> _paidByAmounts = {};
  final _paidByControllers = <String, TextEditingController>{};
  String _splitType = 'equal';
  final Set<String> _excludedIds = {};
  final Set<String> _manuallyEditedMembers = {};
  final Set<String> _manuallyEditedPercentMembers = {};
  bool _isDistributing = false;
  bool _isSaving = false;
  String? _validationError;
  DateTime _selectedDate = DateTime.now();
  XFile? _receiptImage;

  @override
  void initState() {
    super.initState();
    final edit = widget.expenseToEdit;
    if (edit != null) {
      _titleController.text = edit.title;
      _amountController.text = edit.amount.toStringAsFixed(0);
      _paidByAmounts = Map<String, double>.from(edit.paidBy);
      _splitType = edit.splitType;
      _selectedCategory = edit.category;
      if (edit.note != null) _noteController.text = edit.note!;
      _selectedDate = edit.date;
      if (edit.receiptPath != null) {
        _receiptImage = XFile(edit.receiptPath!);
      }
    } else {
      if (widget.participants.isNotEmpty) {
        final first = widget.participants.first.id;
        _paidByAmounts = {first: 0};
      }
    }
    for (final p in widget.participants) {
      _customValues[p.id] = TextEditingController();
      _paidByControllers[p.id] = TextEditingController(
        text: _paidByAmounts.containsKey(p.id)
            ? _paidByAmounts[p.id]!.toStringAsFixed(0)
            : '',
      );
    }
    _applyDateBasedDefaults();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_splitType == 'exact' && _parsedAmount > 0) {
        _resetExactSplit();
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _amountFocusNode.dispose();
    _noteController.dispose();
    for (final c in _customValues.values) {
      c.dispose();
    }
    super.dispose();
  }

  String get _sym => _currencySymbol();

  String _currencySymbol() {
    const symbols = {
      'BDT': '৳',
      'USD': r'$',
      'EUR': '€',
      'GBP': '£',
      'INR': '₹',
      'JPY': '¥',
      'AED': 'د.إ',
      'CAD': r'$',
    };
    return symbols[widget.currency] ?? r'$';
  }

  double get _parsedAmount =>
      double.tryParse(_amountController.text.trim()) ?? 0;

  List<TourParticipant> get _lateJoiners => ExpenseSplitCalculator
      .filterLateJoiners(
    participants: widget.participants,
    selectedDate: _selectedDate,
  );

  void _applySplitResults(List<({String id, double value})> results) {
    _isDistributing = true;
    for (final r in results) {
      final value = r.value;
      final text = value == value.roundToDouble()
          ? value.toStringAsFixed(0)
          : value.toStringAsFixed(2);
      _customValues[r.id]?.text = text;
    }
    _isDistributing = false;
  }

  void _redistributeExactSplit() {
    if (_splitType != 'exact') return;
    final total = _parsedAmount;
    if (total <= 0) return;
    final included = widget.participants
        .where((p) => !_excludedIds.contains(p.id))
        .toList();
    if (included.isEmpty) return;

    final results = ExpenseSplitCalculator.redistributeExactSplit(
      totalAmount: total,
      participants: included.map((p) => SplitParticipantInput(
        id: p.id,
        value: double.tryParse(_customValues[p.id]?.text.trim() ?? '') ?? 0,
        edited: _manuallyEditedMembers.contains(p.id),
      )).toList(),
    );
    _applySplitResults(results);
  }

  void _resetExactSplit() {
    _manuallyEditedMembers.clear();
    final included = widget.participants
        .where((p) => !_excludedIds.contains(p.id))
        .toList();
    if (included.isEmpty) return;
    final total = _parsedAmount;
    if (total <= 0) return;

    final results = ExpenseSplitCalculator.resetExactSplit(
      totalAmount: total,
      participantIds: included.map((p) => p.id).toList(),
    );
    _applySplitResults(results);
    setState(() {});
  }

  void _redistributePercentSplit() {
    if (_splitType != 'percentage') return;
    final included = widget.participants
        .where((p) => !_excludedIds.contains(p.id))
        .toList();
    if (included.isEmpty) return;

    final results = ExpenseSplitCalculator.redistributePercentSplit(
      participants: included.map((p) => SplitParticipantInput(
        id: p.id,
        value: double.tryParse(_customValues[p.id]?.text.trim() ?? '') ?? 0,
        edited: _manuallyEditedPercentMembers.contains(p.id),
      )).toList(),
    );
    _applySplitResults(results);
  }

  void _resetPercentSplit() {
    _manuallyEditedPercentMembers.clear();
    final included = widget.participants
        .where((p) => !_excludedIds.contains(p.id))
        .toList();
    if (included.isEmpty) return;

    final results = ExpenseSplitCalculator.resetPercentSplit(
      participantIds: included.map((p) => p.id).toList(),
    );
    _applySplitResults(results);
    setState(() {});
  }

  void _applyDateBasedDefaults() {
    final toExclude = ExpenseSplitCalculator.findExcludedLateJoiners(
      participants: widget.participants,
      selectedDate: _selectedDate,
    );
    _excludedIds.clear();
    _excludedIds.addAll(toExclude);
  }

  Map<String, double> _readCustomValues() {
    return ExpenseSplitCalculator.extractCustomValues(
      participants: widget.participants,
      textValues: {for (final p in widget.participants) p.id: _customValues[p.id]?.text.trim() ?? ''},
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null) return;
    setState(() {
      _selectedDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _selectedDate.hour,
        _selectedDate.minute,
      );
      _applyDateBasedDefaults();
      _validationError = null;
    });
  }

  Future<void> _pickReceipt(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 80,
    );
    if (file != null) setState(() => _receiptImage = file);
  }

  void _showReceiptSourceSheet() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.translate('attach_receipt'),
              style: AppTextStyles.h2.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            _buildReceiptOption(
              ctx,
              theme,
              LucideIcons.camera,
              context.translate('take_photo'),
              ImageSource.camera,
            ),
            const SizedBox(height: 4),
            _buildReceiptOption(
              ctx,
              theme,
              LucideIcons.image,
              context.translate('choose_from_gallery'),
              ImageSource.gallery,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptOption(
    BuildContext ctx,
    ThemeData theme,
    IconData icon,
    String label,
    ImageSource source,
  ) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.activeGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.activeGreen, size: 20),
      ),
      title: Text(
        label,
        style: AppTextStyles.bodyBold.copyWith(
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface,
        ),
      ),
      onTap: () {
        Navigator.pop(ctx);
        _pickReceipt(source);
      },
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final today = DateTime.now();
    final isToday =
        d.year == today.year && d.month == today.month && d.day == today.day;
    if (isToday) return context.translate('today');
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String? _validate() {
    final paidTotal = _paidByAmounts.values.fold(0.0, (a, b) => a + b);
    final roundedPaid = (paidTotal * 100).round();
    final roundedAmount = (_parsedAmount * 100).round();
    if (_paidByAmounts.isEmpty) return context.translate('select_who_paid_error');
    if (roundedPaid != roundedAmount) {
      return context.translate('total_paid_must_equal_expense', namedArgs: {'sym': _sym, 'paid': paidTotal.toStringAsFixed(0), 'amount': _parsedAmount.toStringAsFixed(0)});
    }
    return ExpenseSplitCalculator.validate(
      amount: _parsedAmount,
      paidById: _paidByAmounts.keys.first,
      participants: widget.participants,
      excludedIds: _excludedIds,
      customValues: _readCustomValues(),
      splitType: _splitType,
      currencySymbol: _sym,
    );
  }

  Future<String?> _persistReceipt(String? path) async {
    if (path == null || path.isEmpty) return null;
    final file = File(path);
    if (!file.existsSync()) return null;
    final dir = await getApplicationDocumentsDirectory();
    final receiptDir = Directory('${dir.path}/receipts');
    if (!receiptDir.existsSync()) receiptDir.createSync();
    final ext = path.contains('.') ? path.split('.').last : 'jpg';
    final newName = '${DateTime.now().microsecondsSinceEpoch}.$ext';
    final newPath = '${receiptDir.path}/$newName';
    await file.copy(newPath);
    return newPath;
  }

  Future<void> _save() async {
    setState(() => _validationError = _validate());
    if (_validationError != null) return;
    setState(() => _isSaving = true);

    final amount = _parsedAmount;
    final isEdit = widget.expenseToEdit != null;
    final expense = TourExpense(
      id: isEdit
          ? widget.expenseToEdit!.id
          : DateTime.now().microsecondsSinceEpoch.toString(),
      tourId: widget.tourId,
      title: _titleController.text.trim().isEmpty && _selectedCategory != null
          ? _selectedCategory!
          : _titleController.text.trim(),
      amount: amount,
      paidBy: _paidByAmounts,
      splitType: _splitType,
      category: _selectedCategory,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      date: _selectedDate,
      receiptPath: await _persistReceipt(_receiptImage?.path),
    );

    if (!mounted) return;
    final provider = context.read<TourProvider>();

    Map<String, double>? customValues;
    if (_splitType == 'exact' || _splitType == 'percentage') {
      customValues = {};
      for (final p in widget.participants) {
        final v = double.tryParse(_customValues[p.id]?.text.trim() ?? '');
        if (v != null) customValues[p.id] = v;
      }
    }

    final shares = provider.calculateShares(
      expense: expense,
      activeParticipants: widget.participants,
      customValues: customValues,
      excludedIds: _splitType == 'exclusion' || _splitType == 'equal'
          ? _excludedIds.toList()
          : null,
    );

    final success = isEdit
        ? await provider.updateExpense(expense, shares)
        : await provider.addExpense(expense, shares);
    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.translate('cannot_modify_completed')),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    if (mounted) Navigator.of(context).pop();
  }

  void _syncPaidByToAmount() {
    final total = _parsedAmount;
    if (_paidByAmounts.isEmpty || total <= 0) return;
    if (_paidByAmounts.length == 1) {
      final id = _paidByAmounts.keys.first;
      _paidByAmounts = {id: total};
      _paidByControllers[id]?.text = total.toStringAsFixed(0);
    } else {
      final currentSum = _paidByAmounts.values.fold(0.0, (a, b) => a + b);
      if (currentSum <= 0) return;
      final ratio = total / currentSum;
      final updated = <String, double>{};
      for (final e in _paidByAmounts.entries) {
        final newVal = (e.value * ratio * 100).round() / 100.0;
        updated[e.key] = newVal;
        _paidByControllers[e.key]?.text = newVal.toStringAsFixed(0);
      }
      _paidByAmounts = updated;
    }
    setState(() {});
  }

  // ─── Widget Callbacks ─────────────────────────────────────────────────

  void _onSplitTypeChanged(String type) {
    setState(() {
      _splitType = type;
      _validationError = null;
      _applyDateBasedDefaults();
    });
    if (type == 'percentage') {
      WidgetsBinding.instance.addPostFrameCallback((_) => _resetPercentSplit());
    } else if (type == 'exact') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_parsedAmount > 0) _resetExactSplit();
      });
    }
  }

  void _onExcludedChanged(String id, bool included) {
    setState(() {
      if (included) {
        _excludedIds.remove(id);
      } else {
        _excludedIds.add(id);
      }
    });
  }

  void _onCustomValueChanged(String id) {
    if (_isDistributing) return;
    setState(() => _validationError = null);
    if (_splitType == 'exact') {
      _manuallyEditedMembers.add(id);
      _redistributeExactSplit();
      setState(() {});
    } else if (_splitType == 'percentage') {
      _manuallyEditedPercentMembers.add(id);
      _redistributePercentSplit();
      setState(() {});
    }
  }

  Map<String, String> _computePreviews() {
    return ExpenseSplitCalculator.computePreviews(
      participants: widget.participants,
      totalAmount: _parsedAmount,
      excludedIds: _excludedIds,
      customValues: _readCustomValues(),
      splitType: _splitType,
      currencySymbol: _sym,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════

  Color _sectionBg(ThemeData theme) => theme.brightness == Brightness.dark
      ? Colors.white.withValues(alpha: 0.05)
      : const Color(0xFFF8F9FA);

  Widget _sectionWrapper(ThemeData theme, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.p20),
      decoration: BoxDecoration(
        color: _sectionBg(theme),
        borderRadius: BorderRadius.circular(AppSpacing.r16),
      ),
      child: child,
    );
  }

  Widget _sectionLabel(ThemeData theme, String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: AppSpacing.s12),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final customValues = _readCustomValues();
    final percentageError = _splitType == 'percentage' &&
        (ExpenseSplitCalculator.percentageTotal(
              participants: widget.participants,
              excludedIds: _excludedIds,
              customValues: customValues,
            ) * 100).round() != 10000;
    final exactExceedsError = ExpenseSplitCalculator.exactAmountsExceed(
      totalAmount: _parsedAmount,
      participants: widget.participants,
      excludedIds: _excludedIds,
      customValues: customValues,
    );

    final double maxHeight =
        (MediaQuery.of(context).size.height - bottom) * 0.85;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ExpenseSheetDragHandle(theme: theme),
                      const SizedBox(height: AppSpacing.s8),
                      ExpenseHeroSection(
                        theme: theme,
                        sym: _sym,
                        amountController: _amountController,
                        amountFocusNode: _amountFocusNode,
                        titleController: _titleController,
                        onChanged: () {
                          setState(() => _validationError = null);
                          _syncPaidByToAmount();
                        },
                      ),
                      const SizedBox(height: AppSpacing.h24),
                      ExpenseCategorySelector(
                        theme: theme,
                        selectedCategory: _selectedCategory,
                        customCategories: _customCategories,
                        onCategorySelected: (v) =>
                            setState(() => _selectedCategory = v),
                        onAddCategory: () async {
                          final result = await showAddCategoryDialog(context);
                          if (result != null && mounted) {
                            setState(() {
                              _customCategories.add(result);
                              _selectedCategory = result['name'] as String;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.h24),
                      ExpenseDatePicker(
                        theme: theme,
                        selectedDate: _selectedDate,
                        onPickDate: _pickDate,
                      ),
                      const SizedBox(height: AppSpacing.h24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ExpenseReceiptPicker(
                          theme: theme,
                          receiptPath: _receiptImage?.path,
                          receiptName: _receiptImage?.name,
                          onPick: _showReceiptSourceSheet,
                          onClear: () => setState(() => _receiptImage = null),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.h24),
                      // Paid By section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _sectionWrapper(
                          theme,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionLabel(theme, context.translate('paid_by_section')),
                              ExpenseParticipantSelector(
                                theme: theme,
                                participants: widget.participants,
                                paidByAmounts: _paidByAmounts,
                                amountControllers: _paidByControllers,
                                totalAmount: _parsedAmount,
                                currencySymbol: _sym,
                                onPaidByChanged: (updated) =>
                                    setState(() => _paidByAmounts = updated),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.h24),
                      // Split section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _sectionWrapper(
                          theme,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionLabel(theme, context.translate('split_section')),
                              ExpenseSplitTypeSelector(
                                theme: theme,
                                splitType: _splitType,
                                onSplitTypeChanged: _onSplitTypeChanged,
                              ),
                              if (_lateJoiners.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.s12),
                                ExpenseLateJoinerBanner(
                                  theme: theme,
                                  names: _lateJoiners.map((p) => p.name.split(' ').first).join(', '),
                                  dateText: _formatDate(_selectedDate),
                                ),
                              ],
                              const SizedBox(height: AppSpacing.s12),
                              ExpenseSplitAmountRow(
                                theme: theme,
                                participants: widget.participants,
                                splitType: _splitType,
                                excludedIds: _excludedIds,
                                customValues: _customValues,
                                previews: _computePreviews(),
                                lateJoinerIds: _lateJoiners
                                    .map((p) => p.id)
                                    .toSet(),
                                currencySymbol: _sym,
                                onExcludedChanged: _onExcludedChanged,
                                onCustomValueChanged: _onCustomValueChanged,
                                onResetSplit: _splitType == 'exact'
                                    ? _resetExactSplit
                                    : _resetPercentSplit,
                              ),
                              if (percentageError) ...[
                                const SizedBox(height: AppSpacing.s8),
                                Text(
                                  context.translate('sum_must_be_100'),
                                  style: AppTextStyles.label.copyWith(
                                    color: AppColors.activeRed,
                                  ),
                                ),
                              ],
                              if (exactExceedsError) ...[
                                const SizedBox(height: AppSpacing.s8),
                                Text(
                                  context.translate('amounts_exceed_total'),
                                  style: AppTextStyles.label.copyWith(
                                    color: AppColors.activeRed,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.h24),
                      // Notes section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _sectionWrapper(
                          theme,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionLabel(theme, context.translate('notes_section')),
                              ExpenseNoteField(theme: theme, controller: _noteController),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.h16),
                      ExpenseValidationBanner(error: _validationError),
                    ],
                  ),
                ),
              ),
              // Sticky save button
              ExpenseSaveButton(
                theme: theme,
                bottomInset: bottomInset,
                isSaving: _isSaving,
                hasError: percentageError || exactExceedsError,
                onSave: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
