import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/models/tour_expense.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';

class AddExpenseSheet extends StatefulWidget {
  final String tourId;
  final List<TourParticipant> participants;
  final String currency;

  const AddExpenseSheet({
    super.key,
    required this.tourId,
    required this.participants,
    required this.currency,
  });

  static Future<void> show(
    BuildContext context, {
    required String tourId,
    required List<TourParticipant> participants,
    required String currency,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddExpenseSheet(
        tourId: tourId,
        participants: participants,
        currency: currency,
      ),
    );
  }

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _customValues = <String, TextEditingController>{};
  final _picker = ImagePicker();

  String? _selectedCategory;
  String _paidById = '';
  String _splitType = 'equal';
  final Set<String> _excludedIds = {};
  bool _isSaving = false;
  String? _validationError;
  DateTime _selectedDate = DateTime.now();
  XFile? _receiptImage;

  static const _categories = [
    ('Food', Icons.restaurant_rounded),
    ('Transport', Icons.directions_car_rounded),
    ('Accommodation', Icons.hotel_rounded),
    ('Activities', Icons.hiking_rounded),
    ('Shopping', Icons.shopping_bag_rounded),
    ('Drinks', Icons.local_bar_rounded),
    ('Groceries', Icons.shopping_cart_rounded),
    ('Fuel', Icons.local_gas_station_rounded),
    ('Tickets', Icons.confirmation_num_rounded),
    ('Other', Icons.more_horiz_rounded),
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
    if (widget.participants.isNotEmpty) {
      _paidById = widget.participants.first.id;
    }
    for (final p in widget.participants) {
      _customValues[p.id] = TextEditingController();
    }
    _applyDateBasedDefaults();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
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
    final included = _includedCount;
    if (included == 0) return null;
    final excluded = _excludedIds.contains(participantId);

    switch (_splitType) {
      case 'equal':
      case 'exclusion':
        if (excluded) return '${_sym}0';
        final perPerson = amount / included;
        return '$_sym${perPerson.toStringAsFixed(perPerson == perPerson.roundToDouble() ? 0 : 2)}';
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
    if (_titleController.text.trim().isEmpty) return 'Enter a title';
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

  Future<void> _save() async {
    setState(() => _validationError = _validate());
    if (_validationError != null) return;
    setState(() => _isSaving = true);

    final amount = _parsedAmount;
    final expense = TourExpense(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      tourId: widget.tourId,
      title: _titleController.text.trim(),
      amount: amount,
      paidBy: _paidById,
      splitType: _splitType,
      category: _selectedCategory,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      date: _selectedDate,
      receiptPath: _receiptImage?.path,
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

    await provider.addExpense(expense, shares);
    if (mounted) Navigator.of(context).pop();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
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
                    _buildHandle(theme),
                    _buildHeroSection(theme),
                    const SizedBox(height: 6),
                    _buildCategoryChips(theme),
                    const SizedBox(height: 16),
                    _buildMetaRow(theme),
                    const SizedBox(height: 16),
                    _buildReceiptSection(theme),
                    const SizedBox(height: 20),
                    _buildPaidBySection(theme),
                    const SizedBox(height: 16),
                    _buildSplitSection(theme),
                    if (_validationError != null) ...[
                      const SizedBox(height: 8),
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
                    ],
                    const SizedBox(height: 8),
                    _buildNoteField(theme),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // Sticky save button
            _buildSaveButton(theme, bottomInset),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Center(
        child: Container(
          width: 36, height: 4,
          decoration: BoxDecoration(
            color: theme.dividerColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
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
                    decoration: InputDecoration(
                      hintText: '0',
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
          const SizedBox(height: 8),
          // Title field
          TextField(
            controller: _titleController,
            textAlign: TextAlign.center,
            onChanged: (_) => setState(() => _validationError = null),
            style: GoogleFonts.workSans(
              fontSize: 15,
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'What was the expense for?',
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
        ],
      ),
    );
  }

  // ─── Category Chips (inline) ─────────────────────────────────────────

  Widget _buildCategoryChips(ThemeData theme) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final (label, icon) = _categories[index];
          final isSelected = _selectedCategory == label;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedCategory = isSelected ? null : label;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.activeGreen.withValues(alpha: 0.12)
                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.activeGreen.withValues(alpha: 0.3)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 14,
                    color: isSelected
                        ? AppColors.activeGreen
                        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.activeGreen
                          : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Meta Row ────────────────────────────────────────────────────────

  Widget _buildMetaRow(ThemeData theme) {
    final payerName = widget.participants
        .firstWhere((p) => p.id == _paidById, orElse: () => widget.participants.first)
        .name.split(' ').first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildMetaChip(theme, Icons.person_outline_rounded, payerName, _pickPayer),
          const SizedBox(width: 8),
          _buildMetaChip(theme, Icons.calendar_today_rounded, _formatDate(_selectedDate), _pickDate),
        ],
      ),
    );
  }

  void _pickPayer() async {
    final selected = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(100, 300, 100, 300),
      items: widget.participants
          .map((p) => PopupMenuItem(value: p.id, child: Text(p.name)))
          .toList(),
    );
    if (selected != null) setState(() => _paidById = selected);
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

  Widget _buildPaidBySection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 10),
            child: Text(
              'PAID BY',
              style: GoogleFonts.workSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
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
            ),
          ),
        ],
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
            if (selected) ...[
              const SizedBox(width: 6),
              Text(
                p.name.split(' ').first,
                style: GoogleFonts.workSans(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.activeGreen),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Split Section ───────────────────────────────────────────────────

  Widget _buildSplitSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 10),
            child: Text(
              'SPLIT',
              style: GoogleFonts.workSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildSplitTypePills(theme),
                const SizedBox(height: 14),
                if (_lateJoiners.isNotEmpty) ...[
                  _buildLateJoinerBanner(theme),
                  const SizedBox(height: 10),
                ],
                _buildSplitDetails(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
                onTap: () => setState(() {
                  _splitType = types[i];
                  _validationError = null;
                  _applyDateBasedDefaults();
                }),
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
        children: widget.participants.map((p) {
          final excluded = _excludedIds.contains(p.id);
          final preview = _previewAmount(p.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: excluded ? Colors.transparent : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 24, height: 24,
                    child: Checkbox(
                      value: !excluded,
                      activeColor: AppColors.activeGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: excluded
                        ? theme.dividerColor.withValues(alpha: 0.3)
                        : _avatarColors[widget.participants.indexOf(p) % _avatarColors.length],
                    child: Text(
                      p.name[0].toUpperCase(),
                      style: TextStyle(
                        color: excluded ? theme.colorScheme.onSurface.withValues(alpha: 0.3) : Colors.white,
                        fontSize: 10, fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
      final suffix = _splitType == 'percentage' ? '%' : _sym;
      return Column(
        children: widget.participants.map((p) {
          final preview = _previewAmount(p.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: _avatarColors[widget.participants.indexOf(p) % _avatarColors.length],
                    child: Text(
                      p.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      p.name,
                      style: GoogleFonts.workSans(
                        fontSize: 13, fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (preview != null) ...[
                    Text(
                      preview,
                      style: GoogleFonts.workSans(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _customValues[p.id],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                      ],
                      textAlign: TextAlign.right,
                      onChanged: (_) => setState(() => _validationError = null),
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
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }

    return const SizedBox.shrink();
  }

  // ─── Note Field ──────────────────────────────────────────────────────

  Widget _buildNoteField(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: _noteController,
          maxLines: 1,
          style: GoogleFonts.workSans(fontSize: 14, color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Add a note...',
            hintStyle: GoogleFonts.workSans(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(Icons.sticky_note_2_outlined, size: 18,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.25)),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          ),
        ),
      ),
    );
  }

  // ─── Save Button (Sticky) ────────────────────────────────────────────

  Widget _buildSaveButton(ThemeData theme, double bottomInset) {
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
          onPressed: _isSaving ? null : _save,
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
