import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';
import 'package:expense_tracker/core/models/tour_expense.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';

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
    ('Food', Symbols.restaurant),
    ('Transport', Symbols.directions_car),
    ('Accommodation', Symbols.hotel),
    ('Activities', Symbols.hiking),
    ('Shopping', Symbols.shopping_bag),
    ('Drinks', Symbols.local_bar),
    ('Groceries', Symbols.shopping_cart),
    ('Fuel', Symbols.local_gas_station),
    ('Tickets', Symbols.confirmation_number),
    ('Other', Symbols.more_horiz),
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
              style: GoogleFonts.workSans(
                fontSize: 17, fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            _buildReceiptOption(ctx, theme, Icons.camera_alt_rounded, 'Take Photo', ImageSource.camera),
            const SizedBox(height: 4),
            _buildReceiptOption(ctx, theme, Icons.photo_library_rounded, 'Choose from Gallery', ImageSource.gallery),
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
      title: Text(label, style: GoogleFonts.workSans(fontSize: 14, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
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
        style: GoogleFonts.workSans(
          fontSize: 11,
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
                                style: GoogleFonts.workSans(
                                  fontSize: 12,
                                  color: AppColors.activeRed,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            if (exactExceedsError) ...[
                              const SizedBox(height: AppSpacing.s8),
                              Text(
                                'Amounts exceed total',
                                style: GoogleFonts.workSans(
                                  fontSize: 12,
                                  color: AppColors.activeRed,
                                  fontWeight: FontWeight.w500,
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
                              Icon(Icons.error_outline_rounded, size: 16, color: AppColors.activeRed.withValues(alpha: 0.8)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _validationError!,
                                  style: GoogleFonts.workSans(color: AppColors.activeRed, fontSize: 12, fontWeight: FontWeight.w500),
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
                style: GoogleFonts.workSans(
                  fontSize: 28,
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
                    style: GoogleFonts.workSans(
                      fontSize: 38,
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
                      hintStyle: GoogleFonts.workSans(
                        fontSize: 38,
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
              style: GoogleFonts.workSans(
                fontSize: 15,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. Kacchi Bhai Dinner',
                hintStyle: GoogleFonts.workSans(
                  fontSize: 15,
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
            style: GoogleFonts.workSans(
              fontSize: 10,
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
              style: GoogleFonts.workSans(
                fontSize: 9,
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
              Icons.add_rounded,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 3),
            Text(
              'Add',
              style: GoogleFonts.workSans(
                fontSize: 9,
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
    Symbols.label,
    Symbols.restaurant,
    Symbols.coffee,
    Symbols.smoking_rooms,
    Symbols.water_drop,
    Symbols.directions_car,
    Symbols.hotel,
    Symbols.hiking,
    Symbols.shopping_bag,
    Symbols.local_bar,
    Symbols.shopping_cart,
    Symbols.local_gas_station,
    Symbols.confirmation_number,
    Symbols.more_horiz,
    Symbols.flight,
    Symbols.music_note,
    Symbols.check_circle,
    Symbols.arrow_downward,
    Symbols.people_alt,
    Symbols.explore,
    Symbols.image,
    Symbols.description,
    Symbols.swap_horiz,
    Symbols.camera_alt,
    Symbols.photo_library,
    Symbols.info,
    Symbols.delete_outline,
    Symbols.add,
    Symbols.close,
    Symbols.drag_handle,
    Symbols.pin,
    Symbols.percent,
    Symbols.person_off,
    Symbols.check,
    Symbols.calendar_today,
    Symbols.receipt_long,
    Symbols.account_balance_wallet,
    Symbols.keyboard_arrow_down,
    Symbols.error_outline,
    Symbols.remove_circle_outline,
    Symbols.arrow_back,
    Symbols.chevron_right,
    Symbols.arrow_back_ios,
    Symbols.home,
    Symbols.pets,
    Symbols.health_and_safety,
    Symbols.flash_on,
    Symbols.celebration,
    Symbols.cake,
    Symbols.card_giftcard,
    Symbols.wifi,
    Symbols.phone,
    Symbols.construction,
    Symbols.brush,
    Symbols.forest,
    Symbols.beach_access,
  ];

  static final _iconSearchData = <IconData, String>{
    Symbols.label: 'label tag category other misc general',
    Symbols.restaurant: 'food restaurant dining meal eat dinner lunch',
    Symbols.coffee: 'coffee tea breakfast cafe drink beverage morning',
    Symbols.smoking_rooms: 'cigarette smoking tobacco cigar',
    Symbols.water_drop: 'water drink hydration bottle liquid',
    Symbols.directions_car: 'transport car vehicle travel drive ride',
    Symbols.hotel: 'hotel accommodation stay lodging room',
    Symbols.hiking: 'activity outdoor adventure sport hiking trek',
    Symbols.shopping_bag: 'shopping bag purchase retail store',
    Symbols.local_bar: 'bar drink alcohol beer wine cocktail party',
    Symbols.shopping_cart: 'grocery supermarket food shopping cart',
    Symbols.local_gas_station: 'fuel gas station petrol car vehicle',
    Symbols.confirmation_number: 'ticket ticket booking event movie show',
    Symbols.more_horiz: 'more other misc extra additional',
    Symbols.flight: 'flight plane travel airport trip vacation',
    Symbols.music_note: 'music song entertainment party concert',
    Symbols.check_circle: 'check done complete confirm yes verified',
    Symbols.arrow_downward: 'down arrow download receive incoming',
    Symbols.people_alt: 'people group team friends family members',
    Symbols.explore: 'explore adventure discover compass navigate',
    Symbols.image: 'photo image picture gallery photography',
    Symbols.description: 'document description file report text',
    Symbols.swap_horiz: 'swap transfer exchange switch change',
    Symbols.camera_alt: 'camera photo image picture photography',
    Symbols.photo_library: 'gallery photo image picture library album',
    Symbols.info: 'info information help details notice',
    Symbols.delete_outline: 'delete remove trash discard',
    Symbols.add: 'add new create plus additional',
    Symbols.close: 'close cancel exit remove stop',
    Symbols.drag_handle: 'drag handle move reorder',
    Symbols.pin: 'pin save bookmark important',
    Symbols.percent: 'percent percentage discount offer sale',
    Symbols.person_off: 'person user people individual',
    Symbols.check: 'check done yes confirm verify',
    Symbols.calendar_today: 'calendar date event schedule appointment',
    Symbols.receipt_long: 'receipt bill invoice payment transaction',
    Symbols.account_balance_wallet: 'wallet account balance finance money bank payment',
    Symbols.keyboard_arrow_down: 'keyboard arrow down dropdown expand',
    Symbols.error_outline: 'error warning alert problem issue',
    Symbols.remove_circle_outline: 'remove circle delete clear cancel',
    Symbols.arrow_back: 'arrow back left previous return',
    Symbols.chevron_right: 'chevron right next forward continue',
    Symbols.arrow_back_ios: 'arrow back left ios previous',
    Symbols.home: 'home house rent lodging accommodation',
    Symbols.pets: 'pets animal dog cat pet veterinary',
    Symbols.health_and_safety: 'health medical medicine hospital doctor pharmacy',
    Symbols.flash_on: 'flash electricity power energy utility bill',
    Symbols.celebration: 'celebration party event occasion festival',
    Symbols.cake: 'cake dessert birthday sweet bakery',
    Symbols.card_giftcard: 'gift present card giftcard occasion',
    Symbols.wifi: 'wifi internet network connection data',
    Symbols.phone: 'phone mobile call communication mobile',
    Symbols.construction: 'construction repair maintenance tool fix',
    Symbols.brush: 'paint color decoration design art renovate brush',
    Symbols.forest: 'forest nature tree park outdoor environment',
    Symbols.beach_access: 'beach ocean sea water vacation holiday',
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
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
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
                      fontSize: 12,
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
          _buildMetaChip(theme, Icons.calendar_today_rounded, _formatDate(_selectedDate), _pickDate),
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
              style: GoogleFonts.workSans(
                fontSize: 13,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
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
            Icon(Icons.receipt_long_outlined, size: 18,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            const SizedBox(width: 8),
            Text(
              'Add Receipt',
              style: GoogleFonts.workSans(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                fontWeight: FontWeight.w500,
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
                style: GoogleFonts.workSans(fontSize: 13, color: theme.colorScheme.onSurface),
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
                child: Icon(Icons.close_rounded, size: 14, color: AppColors.activeRed.withValues(alpha: 0.7)),
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
                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              p.name.split(' ').first,
              style: GoogleFonts.workSans(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: selected ? 1 : 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 4),
              const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.activeGreen),
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
    final icons = [Icons.drag_handle_rounded, Icons.pin_rounded, Icons.percent_rounded, Icons.person_off_rounded];

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
                        style: GoogleFonts.workSans(
                          fontSize: 10,
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
          const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.activeGreen),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$names joined after ${_formatDate(_selectedDate)} — unchecked by default.',
              style: GoogleFonts.workSans(fontSize: 11, color: AppColors.activeGreen),
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
                        fontSize: 10, fontWeight: FontWeight.w600,
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
                          style: GoogleFonts.workSans(
                            fontSize: 13, fontWeight: FontWeight.w500,
                            color: excluded
                                ? theme.colorScheme.onSurface.withValues(alpha: 0.35)
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        if (_hadNotJoinedYet(p))
                          Text(
                            'Joined later',
                            style: GoogleFonts.workSans(
                              fontSize: 10,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (preview != null)
                    Text(
                      preview,
                      style: GoogleFonts.workSans(
                        fontSize: 13, fontWeight: FontWeight.w600,
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
                          color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600,
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
                            style: GoogleFonts.workSans(
                              fontSize: 13, fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          if (preview != null && (isPercentage || isExact))
                            Text(
                              preview,
                              style: GoogleFonts.workSans(
                                fontSize: 11,
                                color: AppColors.activeGreen,
                                fontWeight: FontWeight.w600,
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
                        style: GoogleFonts.workSans(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          suffixText: suffix,
                          suffixStyle: GoogleFonts.workSans(
                            fontSize: 12,
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
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      color: AppColors.activeGreen,
                      fontWeight: FontWeight.w600,
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
      style: GoogleFonts.workSans(fontSize: 14, color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: 'Add a note...',
        hintStyle: GoogleFonts.workSans(
          fontSize: 14,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
        ),
        border: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 2),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Icon(Icons.sticky_note_2_outlined, size: 18,
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
                    const Icon(Icons.check_rounded, size: 20, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Save Expense',
                      style: GoogleFonts.workSans(
                        fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
