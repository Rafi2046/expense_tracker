import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:expense_tracker/core/models/tour_expense.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
  String _paidById = '';
  String _splitType = 'equal';
  final Set<String> _excludedIds = {};
  final Set<String> _manuallyEditedMembers = {};
  final Set<String> _manuallyEditedPercentMembers = {};
  bool _isDistributing = false;
  bool _isSaving = false;
  String? _validationError;
  DateTime _selectedDate = DateTime.now();
  XFile? _receiptImage;

  static const _categories = [
    ('Food', LucideIcons.utensilsCrossed),
    ('Transport', LucideIcons.car),
    ('Accommodation', LucideIcons.hotel),
    ('Activities', LucideIcons.mountain),
    ('Shopping', LucideIcons.shoppingBag),
    ('Drinks', LucideIcons.beer),
    ('Groceries', LucideIcons.shoppingCart),
    ('Fuel', LucideIcons.fuel),
    ('Tickets', LucideIcons.ticket),
    ('Other', LucideIcons.moreHorizontal),
  ];

  static const _avatarColors = [
    Color(0xFF6366F1),
    Color(0xFFEC4899),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFF06B6D4),
    Color(0xFF8B5CF6),
    Color(0xFFEF4444),
    Color(0xFF14B8A6),
  ];

  @override
  void initState() {
    super.initState();
    final edit = widget.expenseToEdit;
    if (edit != null) {
      _titleController.text = edit.title;
      _amountController.text = edit.amount.toStringAsFixed(0);
      _paidById = edit.paidBy;
      _splitType = edit.splitType;
      _selectedCategory = edit.category;
      if (edit.note != null) _noteController.text = edit.note!;
      _selectedDate = edit.date;
      if (edit.receiptPath != null) {
        _receiptImage = XFile(edit.receiptPath!);
      }
    } else {
      if (widget.participants.isNotEmpty) {
        _paidById = widget.participants.first.id;
      }
    }
    for (final p in widget.participants) {
      _customValues[p.id] = TextEditingController();
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
      'BDT': '৳', 'USD': r'$', 'EUR': '€', 'GBP': '£',
      'INR': '₹', 'JPY': '¥', 'AED': 'د.إ', 'CAD': r'$',
    };
    return symbols[widget.currency] ?? r'$';
  }

  double get _parsedAmount =>
      double.tryParse(_amountController.text.trim()) ?? 0;

  int get _includedCount =>
      widget.participants.where((p) => !_excludedIds.contains(p.id)).length;

  bool _hadNotJoinedYet(TourParticipant p) {
    final endOfDay = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59,
    );
    return p.joinedAt.isAfter(endOfDay);
  }

  List<TourParticipant> get _lateJoiners =>
      widget.participants.where(_hadNotJoinedYet).toList();

  double get _percentageTotal {
    if (_splitType != 'percentage') return 100;
    double total = 0;
    for (final p in widget.participants) {
      if (!_excludedIds.contains(p.id)) {
        total += double.tryParse(_customValues[p.id]?.text.trim() ?? '') ?? 0;
      }
    }
    return total;
  }

  bool get _exactAmountsExceed {
    if (_splitType != 'exact' || _parsedAmount <= 0) return false;
    double sum = 0;
    for (final p in widget.participants) {
      if (!_excludedIds.contains(p.id)) {
        sum += double.tryParse(_customValues[p.id]?.text.trim() ?? '') ?? 0;
      }
    }
    return (sum * 100).round() > (_parsedAmount * 100).round();
  }

  void _redistributeExactSplit() {
    if (_splitType != 'exact') return;
    final total = _parsedAmount;
    if (total <= 0) return;
    final included = widget.participants.where((p) => !_excludedIds.contains(p.id)).toList();
    if (included.isEmpty) return;

    double editedSum = 0;
    for (final p in included) {
      if (_manuallyEditedMembers.contains(p.id)) {
        editedSum += double.tryParse(_customValues[p.id]?.text.trim() ?? '') ?? 0;
      }
    }

    final remaining = total - editedSum;
    final unedited = included.where((p) => !_manuallyEditedMembers.contains(p.id)).toList();

    if (unedited.isEmpty) return;

    final totalCents = (remaining * 100).round();
    final baseCents = totalCents ~/ unedited.length;
    final remainderCents = totalCents - (baseCents * unedited.length);

    _isDistributing = true;
    for (var i = 0; i < unedited.length; i++) {
      final cents = baseCents + (i < remainderCents ? 1 : 0);
      final value = cents / 100.0;
      final text = value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
      _customValues[unedited[i].id]?.text = text;
    }
    _isDistributing = false;
  }

  void _resetExactSplit() {
    _manuallyEditedMembers.clear();
    final included = widget.participants.where((p) => !_excludedIds.contains(p.id)).toList();
    if (included.isEmpty) return;
    final total = _parsedAmount;
    if (total <= 0) return;

    final totalCents = (total * 100).round();
    final baseCents = totalCents ~/ included.length;
    final remainderCents = totalCents - (baseCents * included.length);

    _isDistributing = true;
    for (var i = 0; i < included.length; i++) {
      final cents = baseCents + (i < remainderCents ? 1 : 0);
      final value = cents / 100.0;
      final text = value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
      _customValues[included[i].id]?.text = text;
    }
    _isDistributing = false;
    setState(() {});
  }

  void _redistributePercentSplit() {
    if (_splitType != 'percentage') return;
    final included = widget.participants.where((p) => !_excludedIds.contains(p.id)).toList();
    if (included.isEmpty) return;

    double editedSum = 0;
    for (final p in included) {
      if (_manuallyEditedPercentMembers.contains(p.id)) {
        editedSum += double.tryParse(_customValues[p.id]?.text.trim() ?? '') ?? 0;
      }
    }

    if (editedSum >= 100) return;

    final remaining = 100 - editedSum;
    final unedited = included.where((p) => !_manuallyEditedPercentMembers.contains(p.id)).toList();
    if (unedited.isEmpty) return;

    final totalCents = (remaining * 100).round();
    final baseCents = totalCents ~/ unedited.length;
    final remainderCents = totalCents - (baseCents * unedited.length);

    _isDistributing = true;
    for (var i = 0; i < unedited.length; i++) {
      final cents = baseCents + (i < remainderCents ? 1 : 0);
      final value = cents / 100.0;
      final text = value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
      _customValues[unedited[i].id]?.text = text;
    }
    _isDistributing = false;
  }

  void _resetPercentSplit() {
    _manuallyEditedPercentMembers.clear();
    final included = widget.participants.where((p) => !_excludedIds.contains(p.id)).toList();
    if (included.isEmpty) return;

    final totalCents = 10000;
    final baseCents = totalCents ~/ included.length;
    final remainderCents = totalCents - (baseCents * included.length);

    _isDistributing = true;
    for (var i = 0; i < included.length; i++) {
      final cents = baseCents + (i < remainderCents ? 1 : 0);
      final value = cents / 100.0;
      final text = value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
      _customValues[included[i].id]?.text = text;
    }
    _isDistributing = false;
    setState(() {});
  }

  void _applyDateBasedDefaults() {
    _excludedIds.clear();
    for (final p in widget.participants) {
      if (_hadNotJoinedYet(p)) {
        _excludedIds.add(p.id);
      }
    }
  }

  String? _previewAmount(String participantId) {
    final amount = _parsedAmount;
    if (amount <= 0) return null;
    final includedCount = _includedCount;
    if (includedCount == 0) return null;
    final excluded = _excludedIds.contains(participantId);

    switch (_splitType) {
      case 'equal':
      case 'exclusion':
        if (excluded) return '${_sym}0';
        final included = widget.participants.where((p) => !_excludedIds.contains(p.id)).toList();
        final idx = included.indexWhere((p) => p.id == participantId);
        if (idx == -1) return null;
        final totalCents = (amount * 100).round();
        final baseCents = totalCents ~/ includedCount;
        final remainderCents = totalCents - (baseCents * includedCount);
        final cents = baseCents + (idx < remainderCents ? 1 : 0);
        final share = cents / 100.0;
        return '$_sym${share.toStringAsFixed(share == share.roundToDouble() ? 0 : 2)}';
      case 'percentage':
        if (excluded) return null;
        final pct = double.tryParse(_customValues[participantId]?.text.trim() ?? '') ?? 0;
        final share = amount * pct / 100;
        return '$_sym${share.toStringAsFixed(share == share.roundToDouble() ? 0 : 2)}';
      case 'exact':
        if (excluded) return null;
        final val = double.tryParse(_customValues[participantId]?.text.trim() ?? '');
        if (val == null) return null;
        return '$_sym${val.toStringAsFixed(val == val.roundToDouble() ? 0 : 2)}';
      default:
        return null;
    }
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
        picked.year, picked.month, picked.day,
        _selectedDate.hour, _selectedDate.minute,
      );
      _applyDateBasedDefaults();
      _validationError = null;
    });
  }

  Future<void> _pickReceipt(ImageSource source) async {
    final file = await _picker.pickImage(source: source, maxWidth: 1200, imageQuality: 80);
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
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Attach Receipt',
              style: AppTextStyles.h2.copyWith(color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 20),
            _buildReceiptOption(ctx, theme, LucideIcons.camera, 'Take Photo', ImageSource.camera),
            const SizedBox(height: 4),
            _buildReceiptOption(ctx, theme, LucideIcons.image, 'Choose from Gallery', ImageSource.gallery),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptOption(BuildContext ctx, ThemeData theme, IconData icon, String label, ImageSource source) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: AppColors.activeGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.activeGreen, size: 20),
      ),
      title: Text(label, style: AppTextStyles.bodyBold.copyWith(fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
      onTap: () {
        Navigator.pop(ctx);
        _pickReceipt(source);
      },
    );
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final today = DateTime.now();
    final isToday = d.year == today.year && d.month == today.month && d.day == today.day;
    if (isToday) return 'Today';
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String? _validate() {
    final amount = _parsedAmount;
    if (amount <= 0) return 'Enter a valid amount';
    if (_paidById.isEmpty) return 'Select who paid';

    if (_splitType == 'exact') {
      final total = widget.participants
          .where((p) => !_excludedIds.contains(p.id))
          .fold(0.0, (s, p) {
            final v = double.tryParse(_customValues[p.id]?.text.trim() ?? '') ?? 0;
            return s + v;
          });
      if ((total * 100).round() != (amount * 100).round()) {
        return 'Exact amounts must total $_sym${amount.toStringAsFixed(amount == amount.roundToDouble() ? 0 : 2)}';
      }
    }

    if (_splitType == 'percentage') {
      final total = widget.participants
          .where((p) => !_excludedIds.contains(p.id))
          .fold(0.0, (s, p) {
            final v = double.tryParse(_customValues[p.id]?.text.trim() ?? '') ?? 0;
            return s + v;
          });
      if ((total * 100).round() != 10000) return 'Percentages must total 100%';
    }

    if (_splitType != 'exact' && _splitType != 'percentage') {
      if (_includedCount == 0) return 'At least one person must be included';
    }

    return null;
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
      id: isEdit ? widget.expenseToEdit!.id : DateTime.now().microsecondsSinceEpoch.toString(),
      tourId: widget.tourId,
      title: _titleController.text.trim().isEmpty && _selectedCategory != null
          ? _selectedCategory!
          : _titleController.text.trim(),
      amount: amount,
      paidBy: _paidById,
      splitType: _splitType,
      category: _selectedCategory,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      date: _selectedDate,
      receiptPath: await _persistReceipt(_receiptImage?.path),
    );

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
          const SnackBar(
            content: Text('Cannot modify expense — tour is completed'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    if (mounted) Navigator.of(context).pop();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════

  Color _sectionBg(ThemeData theme) =>
      theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8F9FA);

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
    final percentageError = _splitType == 'percentage' && (_percentageTotal * 100).round() != 10000;
    final exactExceedsError = _exactAmountsExceed;

    final double maxHeight = (MediaQuery.of(context).size.height - bottom) * 0.85;

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
                    _buildDragHandle(theme),
                    const SizedBox(height: AppSpacing.s8),
                    _buildHeroSection(theme),
                    const SizedBox(height: AppSpacing.h24),
                    _buildCategoryChips(theme),
                    const SizedBox(height: AppSpacing.h24),
                    _buildMetaRow(theme),
                    const SizedBox(height: AppSpacing.h24),
                    _buildReceiptSection(theme),
                    const SizedBox(height: AppSpacing.h24),
                    // Paid By section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _sectionWrapper(theme,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionLabel(theme, 'PAID BY'),
                            _buildPayerContent(theme),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.h24),
                    // Split section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _sectionWrapper(theme,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionLabel(theme, 'SPLIT'),
                            _buildSplitTypePills(theme),
                            if (_lateJoiners.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.s12),
                              _buildLateJoinerBanner(theme),
                            ],
                            const SizedBox(height: AppSpacing.s12),
                            _buildSplitDetails(theme),
                            if (percentageError) ...[
                              const SizedBox(height: AppSpacing.s8),
                              Text(
                                'Sum must be 100%',
                                style: AppTextStyles.label.copyWith(color: AppColors.activeRed),
                              ),
                            ],
                            if (exactExceedsError) ...[
                              const SizedBox(height: AppSpacing.s8),
                              Text(
                                'Amounts exceed total',
                                style: AppTextStyles.label.copyWith(color: AppColors.activeRed),
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
                      child: _sectionWrapper(theme,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionLabel(theme, 'NOTES'),
                            _buildNoteContent(theme),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.h16),
                    if (_validationError != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.activeRed.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(LucideIcons.alertCircle, size: 16, color: AppColors.activeRed.withValues(alpha: 0.8)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _validationError!,
                                  style: AppTextStyles.label.copyWith(color: AppColors.activeRed),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                    ],
                  ],
                ),
              ),
            ),
            // Sticky save button
            _buildSaveButton(theme, bottomInset, percentageError || exactExceedsError),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildDragHandle(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Center(
        child: Container(
          width: 40, height: 5,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  // ─── Hero Section (Amount + Title) ─────────────────────────────────────

  Widget _buildHeroSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.activeGreen.withValues(alpha: 0.06),
            AppColors.activeGreen.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.activeGreen.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Amount input
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _sym,
                style: AppTextStyles.displayLarge.copyWith(
                  fontWeight: FontWeight.w300,
                  color: AppColors.activeGreen.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(width: 4),
              IntrinsicWidth(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 60, maxWidth: 200),
                  child: TextField(
                    controller: _amountController,
                    focusNode: _amountFocusNode,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    textAlign: TextAlign.center,
                    onChanged: (_) => setState(() => _validationError = null),
                    style: AppTextStyles.displayLarge.copyWith(
                      fontSize: AppFontSizes.size36,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                      height: 1.2,
                    ),
                    autofocus: true,
                    cursorColor: AppColors.activeGreen,
                    cursorWidth: 3,
                    cursorHeight: 44,
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: AppTextStyles.displayLarge.copyWith(
                        fontSize: AppFontSizes.size36,
                        fontWeight: FontWeight.w300,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                      ),
                      border: InputBorder.none,
                      filled: false,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    scrollPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Title field — visible input container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p14, vertical: AppSpacing.p12),
            decoration: BoxDecoration(
              color: _sectionBg(theme),
              borderRadius: BorderRadius.circular(AppSpacing.r10),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _titleController,
              textAlign: TextAlign.start,
              onChanged: (_) => setState(() => _validationError = null),
              style: AppTextStyles.bodyBold.copyWith(
                fontSize: AppFontSizes.size15,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. Kacchi Bhai Dinner',
                hintStyle: AppTextStyles.bodyBold.copyWith(
                  fontSize: AppFontSizes.size15,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Category Chips (inline) ─────────────────────────────────────────

  Widget _buildCategoryChips(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CATEGORY',
            style: AppTextStyles.caption.copyWith(
              fontSize: AppFontSizes.size10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 1.3,
            ),
            itemCount: _categories.length + _customCategories.length + 1,
            itemBuilder: (context, index) {
              if (index < _categories.length) {
                final (label, icon) = _categories[index];
                return _buildCategoryGridItem(theme, label, icon, _selectedCategory == label);
              }
              final ci = index - _categories.length;
              if (ci < _customCategories.length) {
                final cat = _customCategories[ci];
                return _buildCategoryGridItem(
                  theme, cat['name'] as String, cat['icon'] as IconData,
                  _selectedCategory == cat['name'],
                  onTap: () => setState(() {
                    _selectedCategory = _selectedCategory == cat['name'] ? null : cat['name'];
                  }),
                );
              }
              return _buildAddGridItem(theme);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGridItem(ThemeData theme, String label, IconData icon, bool selected, {VoidCallback? onTap}) {
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap ?? () => setState(() => _selectedCategory = selected ? null : label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.activeGreen.withValues(alpha: 0.12)
              : (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF0F0F0)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.activeGreen.withValues(alpha: 0.3)
                : (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE5E5E5)),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected
                  ? AppColors.activeGreen
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                fontSize: AppFontSizes.size9,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? AppColors.activeGreen
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddGridItem(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _showAddCategoryDialog(),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE5E5E5),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.plus,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 3),
            Text(
              'Add',
              style: AppTextStyles.caption.copyWith(
                fontSize: AppFontSizes.size9,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static final _categoryIcons = <IconData>[
    LucideIcons.tag,
    LucideIcons.utensilsCrossed,
    LucideIcons.coffee,
    LucideIcons.cigarette,
    LucideIcons.droplets,
    LucideIcons.car,
    LucideIcons.hotel,
    LucideIcons.mountain,
    LucideIcons.shoppingBag,
    LucideIcons.beer,
    LucideIcons.shoppingCart,
    LucideIcons.fuel,
    LucideIcons.ticket,
    LucideIcons.moreHorizontal,
    LucideIcons.plane,
    LucideIcons.music,
    LucideIcons.checkCircle,
    LucideIcons.arrowDown,
    LucideIcons.users,
    LucideIcons.compass,
    LucideIcons.image,
    LucideIcons.fileText,
    LucideIcons.arrowLeftRight,
    LucideIcons.camera,
    LucideIcons.image,
    LucideIcons.info,
    LucideIcons.trash,
    LucideIcons.plus,
    LucideIcons.x,
    LucideIcons.gripHorizontal,
    LucideIcons.pin,
    LucideIcons.percent,
    LucideIcons.user,
    LucideIcons.check,
    LucideIcons.calendar,
    LucideIcons.receipt,
    LucideIcons.wallet,
    LucideIcons.chevronDown,
    LucideIcons.alertCircle,
    LucideIcons.minusCircle,
    LucideIcons.arrowLeft,
    LucideIcons.chevronRight,
    LucideIcons.arrowLeft,
    LucideIcons.home,
    LucideIcons.pawPrint,
    LucideIcons.heartPulse,
    LucideIcons.zap,
    LucideIcons.sparkles,
    LucideIcons.cake,
    LucideIcons.gift,
    LucideIcons.wifi,
    LucideIcons.phone,
    LucideIcons.hardHat,
    LucideIcons.paintbrush,
    LucideIcons.trees,
    LucideIcons.umbrella,
  ];

  static final _iconSearchData = <IconData, String>{
    LucideIcons.tag: 'label tag category other misc general',
    LucideIcons.utensilsCrossed: 'food restaurant dining meal eat dinner lunch',
    LucideIcons.coffee: 'coffee tea breakfast cafe drink beverage morning',
    LucideIcons.cigarette: 'cigarette smoking tobacco cigar',
    LucideIcons.droplets: 'water drink hydration bottle liquid',
    LucideIcons.car: 'transport car vehicle travel drive ride',
    LucideIcons.hotel: 'hotel accommodation stay lodging room',
    LucideIcons.mountain: 'activity outdoor adventure sport hiking trek',
    LucideIcons.shoppingBag: 'shopping bag purchase retail store',
    LucideIcons.beer: 'bar drink alcohol beer wine cocktail party',
    LucideIcons.shoppingCart: 'grocery supermarket food shopping cart',
    LucideIcons.fuel: 'fuel gas station petrol car vehicle',
    LucideIcons.ticket: 'ticket ticket booking event movie show',
    LucideIcons.moreHorizontal: 'more other misc extra additional',
    LucideIcons.plane: 'flight plane travel airport trip vacation',
    LucideIcons.music: 'music song entertainment party concert',
    LucideIcons.checkCircle: 'check done complete confirm yes verified',
    LucideIcons.arrowDown: 'down arrow download receive incoming',
    LucideIcons.users: 'people group team friends family members',
    LucideIcons.compass: 'explore adventure discover compass navigate',
    LucideIcons.image: 'photo image picture gallery photography',
    LucideIcons.fileText: 'document description file report text',
    LucideIcons.arrowLeftRight: 'swap transfer exchange switch change',
    LucideIcons.camera: 'camera photo image picture photography',
    LucideIcons.image: 'gallery photo image picture library album',
    LucideIcons.info: 'info information help details notice',
    LucideIcons.trash: 'delete remove trash discard',
    LucideIcons.plus: 'add new create plus additional',
    LucideIcons.x: 'close cancel exit remove stop',
    LucideIcons.gripHorizontal: 'drag handle move reorder',
    LucideIcons.pin: 'pin save bookmark important',
    LucideIcons.percent: 'percent percentage discount offer sale',
    LucideIcons.user: 'person user people individual',
    LucideIcons.check: 'check done yes confirm verify',
    LucideIcons.calendar: 'calendar date event schedule appointment',
    LucideIcons.receipt: 'receipt bill invoice payment transaction',
    LucideIcons.wallet: 'wallet account balance finance money bank payment',
    LucideIcons.chevronDown: 'keyboard arrow down dropdown expand',
    LucideIcons.alertCircle: 'error warning alert problem issue',
    LucideIcons.minusCircle: 'remove circle delete clear cancel',
    LucideIcons.arrowLeft: 'arrow back left previous return',
    LucideIcons.chevronRight: 'chevron right next forward continue',
    LucideIcons.arrowLeft: 'arrow back left ios previous',
    LucideIcons.home: 'home house rent lodging accommodation',
    LucideIcons.pawPrint: 'pets animal dog cat pet veterinary',
    LucideIcons.heartPulse: 'health medical medicine hospital doctor pharmacy',
    LucideIcons.zap: 'flash electricity power energy utility bill',
    LucideIcons.sparkles: 'celebration party event occasion festival',
    LucideIcons.cake: 'cake dessert birthday sweet bakery',
    LucideIcons.gift: 'gift present card giftcard occasion',
    LucideIcons.wifi: 'wifi internet network connection data',
    LucideIcons.phone: 'phone mobile call communication mobile',
    LucideIcons.hardHat: 'construction repair maintenance tool fix',
    LucideIcons.paintbrush: 'paint color decoration design art renovate brush',
    LucideIcons.trees: 'forest nature tree park outdoor environment',
    LucideIcons.umbrella: 'beach ocean sea water vacation holiday',
  };

  Future<void> _showAddCategoryDialog() async {
    IconData selectedIcon = _categoryIcons.first;
    final nameController = TextEditingController();
    var searchQuery = '';

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.r16),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text(
            'New Category',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: AppFontSizes.size18),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search icons...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.r10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.p12,
                        vertical: AppSpacing.p12,
                      ),
                    ),
                    onChanged: (value) {
                      setDialogState(() => searchQuery = value.trim().toLowerCase());
                    },
                    onSubmitted: (value) {
                      final name = value.trim();
                      if (name.isNotEmpty) {
                        Navigator.pop(ctx, {'name': name, 'icon': selectedIcon});
                      }
                    },
                  ),
          const SizedBox(height: 6),
                  const Text(
                    'Choose an icon',
                    style: TextStyle(
                      fontSize: AppFontSizes.size12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 10),
                Expanded(
                  child: Builder(builder: (ctx) {
                    final filtered = searchQuery.isEmpty
                        ? _categoryIcons
                        : _iconSearchData.entries
                            .where((e) => e.value.contains(searchQuery))
                            .map((e) => e.key)
                            .toList();
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) {
                        final icon = filtered[i];
                        final isSelected = icon == selectedIcon;
                        return GestureDetector(
                          onTap: () => setDialogState(() => selectedIcon = icon),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.activeGreen.withValues(alpha: 0.12)
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(AppSpacing.r10),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.activeGreen
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Icon(icon, size: 22,
                                color: isSelected
                                    ? AppColors.activeGreen
                                    : const Color(0xFF6B7280)),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: Color(0xFF6B7280))),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  Navigator.pop(ctx, {'name': name, 'icon': selectedIcon});
                }
              },
              child: const Text('Add',
                  style: TextStyle(
                      color: AppColors.activeGreen,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _customCategories.add(result);
        _selectedCategory = result['name'] as String;
      });
    }
  }

  // ─── Meta Row ────────────────────────────────────────────────────────

  Widget _buildMetaRow(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildMetaChip(theme, LucideIcons.calendar, _formatDate(_selectedDate), _pickDate),
        ],
      ),
    );
  }

  Widget _buildMetaChip(ThemeData theme, IconData icon, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            const SizedBox(width: 6),
            Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Icon(LucideIcons.chevronDown, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }

  // ─── Receipt Section ──────────────────────────────────────────────────

  Widget _buildReceiptSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _receiptImage != null
          ? _buildReceiptThumbnail(theme)
          : _buildReceiptButton(theme),
    );
  }

  Widget _buildReceiptButton(ThemeData theme) {
    return GestureDetector(
      onTap: _showReceiptSourceSheet,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.receipt, size: 18,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            const SizedBox(width: 8),
            Text(
              'Add Receipt',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptThumbnail(ThemeData theme) {
    return GestureDetector(
      onTap: _showReceiptSourceSheet,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(_receiptImage!.path),
                width: 44, height: 44, fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _receiptImage!.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(color: theme.colorScheme.onSurface),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _receiptImage = null),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.activeRed.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.x, size: 14, color: AppColors.activeRed.withValues(alpha: 0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Paid By Section ─────────────────────────────────────────────────

  Widget _buildPayerContent(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.participants.map((p) {
          final selected = p.id == _paidById;
          final idx = widget.participants.indexOf(p);
          return Padding(
            padding: EdgeInsets.only(
              right: idx < widget.participants.length - 1 ? 8 : 0,
            ),
            child: _buildPayerAvatar(theme, p, selected, idx),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPayerAvatar(ThemeData theme, TourParticipant p, bool selected, int index) {
    final color = _avatarColors[index % _avatarColors.length];
    return GestureDetector(
      onTap: () => setState(() => _paidById = p.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: color,
              child: Text(
                p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white, fontSize: AppFontSizes.size11, fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              p.name.split(' ').first,
              style: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: selected ? 1 : 0.6),
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 4),
              Icon(LucideIcons.checkCircle, size: 14, color: AppColors.activeGreen),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Split Section ───────────────────────────────────────────────────

  Widget _buildSplitTypePills(ThemeData theme) {
    final types = ['equal', 'exact', 'percentage', 'exclusion'];
    final labels = ['Equal', 'Exact', 'Percent', 'Exclude'];
    final icons = [LucideIcons.gripHorizontal, LucideIcons.pin, LucideIcons.percent, LucideIcons.userX];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(types.length, (i) {
          final active = _splitType == types[i];
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: i > 0 ? 4 : 0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _splitType = types[i];
                    _validationError = null;
                    _applyDateBasedDefaults();
                  });
                  if (types[i] == 'percentage') {
                    WidgetsBinding.instance.addPostFrameCallback((_) => _resetPercentSplit());
                  } else if (types[i] == 'exact') {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_parsedAmount > 0) _resetExactSplit();
                    });
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? AppColors.activeGreen : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: active
                        ? [BoxShadow(color: AppColors.activeGreen.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Icon(icons[i], size: 16, color: active ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                      const SizedBox(height: 2),
                      Text(
                        labels[i],
                        style: AppTextStyles.caption.copyWith(
                          fontSize: AppFontSizes.size10,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                          color: active ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLateJoinerBanner(ThemeData theme) {
    final names = _lateJoiners.map((p) => p.name.split(' ').first).join(', ');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.activeGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.info, size: 14, color: AppColors.activeGreen),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$names joined after ${_formatDate(_selectedDate)} — unchecked by default.',
              style: AppTextStyles.caption.copyWith(color: AppColors.activeGreen),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Split Details (with live preview) ───────────────────────────────

  Widget _buildSplitDetails(ThemeData theme) {
    final showCheckboxes = _splitType == 'equal' || _splitType == 'exclusion';
    final showInputs = _splitType == 'exact' || _splitType == 'percentage';

    if (showCheckboxes) {
      return Column(
        children: widget.participants.asMap().entries.map((entry) {
          final p = entry.value;
          final excluded = _excludedIds.contains(p.id);
          final preview = _previewAmount(p.id);
          final index = entry.key;
          return Padding(
            padding: EdgeInsets.only(bottom: index < widget.participants.length - 1 ? AppSpacing.s8 : 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppSpacing.r10),
                border: Border.all(
                  color: excluded
                      ? theme.dividerColor.withValues(alpha: 0.08)
                      : theme.dividerColor.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 22, height: 22,
                    child: Checkbox(
                      value: !excluded,
                      activeColor: AppColors.activeGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.r4)),
                      side: WidgetStateBorderSide.resolveWith(
                        (_) => BorderSide(
                          color: excluded
                              ? theme.dividerColor.withValues(alpha: 0.3)
                              : AppColors.activeGreen,
                        ),
                      ),
                      onChanged: (v) => setState(() {
                        if (v == true) {
                          _excludedIds.remove(p.id);
                        } else {
                          _excludedIds.add(p.id);
                        }
                      }),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: excluded
                        ? theme.dividerColor.withValues(alpha: 0.3)
                        : _avatarColors[index % _avatarColors.length],
                    child: Text(
                      p.name[0].toUpperCase(),
                      style: TextStyle(
                        color: excluded ? theme.colorScheme.onSurface.withValues(alpha: 0.3) : Colors.white,
                        fontSize: AppFontSizes.size10, fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          p.name,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w500,
                            color: excluded
                                ? theme.colorScheme.onSurface.withValues(alpha: 0.35)
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        if (_hadNotJoinedYet(p))
                          Text(
                            'Joined later',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: AppFontSizes.size10,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (preview != null)
                    Text(
                      preview,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: excluded
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.2)
                            : AppColors.activeGreen,
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }

    if (showInputs) {
      final isPercentage = _splitType == 'percentage';
      final isExact = _splitType == 'exact';
      final suffix = isPercentage ? '%' : _sym;
      return Column(
        children: [
          ...widget.participants.asMap().entries.map((entry) {
            final p = entry.value;
            final preview = _previewAmount(p.id);
            final index = entry.key;
            return Padding(
              padding: EdgeInsets.only(bottom: index < widget.participants.length - 1 ? AppSpacing.s8 : 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.r10),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: _avatarColors[index % _avatarColors.length],
                      child: Text(
                        p.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white, fontSize: AppFontSizes.size10, fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            p.name,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          if (preview != null && (isPercentage || isExact))
                            Text(
                              preview,
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.activeGreen,
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _customValues[p.id],
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                        ],
                        textAlign: TextAlign.right,
                        onChanged: (_) {
                          if (_isDistributing) return;
                          setState(() => _validationError = null);
                          if (isExact) {
                            _manuallyEditedMembers.add(p.id);
                            _redistributeExactSplit();
                            setState(() {});
                          } else if (isPercentage) {
                            _manuallyEditedPercentMembers.add(p.id);
                            _redistributePercentSplit();
                            setState(() {});
                          }
                        },
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          suffixText: suffix,
                          suffixStyle: AppTextStyles.label.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.r8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: AppSpacing.s6),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (isExact || isPercentage) ...[
            const SizedBox(height: AppSpacing.s12),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: isExact ? _resetExactSplit : _resetPercentSplit,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.s6),
                  decoration: BoxDecoration(
                    color: AppColors.activeGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSpacing.r8),
                  ),
                  child: Text(
                    'Reset split',
                    style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.activeGreen,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    }

    return const SizedBox.shrink();
  }

  // ─── Note Field ──────────────────────────────────────────────────────

  Widget _buildNoteContent(ThemeData theme) {
    return TextField(
      controller: _noteController,
      maxLines: 1,
      style: AppTextStyles.bodyBold.copyWith(fontWeight: FontWeight.w400, color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: 'Add a note...',
        hintStyle: AppTextStyles.bodyBold.copyWith(fontWeight: FontWeight.w400, color: theme.colorScheme.onSurface.withValues(alpha: 0.25)),
        border: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 2),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Icon(LucideIcons.stickyNote, size: 18,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.25)),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }

  // ─── Save Button (Sticky) ────────────────────────────────────────────

  Widget _buildSaveButton(ThemeData theme, double bottomInset, bool percentageError) {
    final canSave = !_isSaving && !percentageError;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomInset + 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: FilledButton(
          onPressed: canSave ? _save : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.activeGreen,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.check, size: 20, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Save Expense',
                      style: AppTextStyles.bodyBold.copyWith(
                        fontSize: AppFontSizes.size15, color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
