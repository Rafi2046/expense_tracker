import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:expense_tracker/core/models/tour_expense.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';

const Color _green = Color(0xFF2EBD85);
const Color _greenLight = Color(0xFFE8F8F5);
const Color _dark = Color(0xFF1F2937);
const Color _muted = Color(0xFF9CA3AF);
const Color _bgCard = Color(0xFFF9FAFB);
const Color _red = Color(0xFFDC3545);
const Color _redLight = Color(0xFFFEF2F2);

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

  static Future<void> show(BuildContext context, {
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
    'Food', 'Transport', 'Accommodation', 'Activities',
    'Shopping', 'Drinks', 'Groceries', 'Fuel', 'Tickets', 'Other',
  ];
  static const _avatarColors = [
    Color(0xFF6366F1), Color(0xFFEC4899), Color(0xFF10B981),
    Color(0xFFF59E0B), Color(0xFF06B6D4), Color(0xFF8B5CF6),
    Color(0xFFEF4444), Color(0xFF14B8A6),
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

  double get _parsedAmount => double.tryParse(_amountController.text.trim()) ?? 0;

  int get _includedCount => widget.participants.where((p) => !_excludedIds.contains(p.id)).length;

  bool _hadNotJoinedYet(TourParticipant p) {
    final endOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);
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
      _selectedDate = DateTime(picked.year, picked.month, picked.day,
          _selectedDate.hour, _selectedDate.minute);
      _applyDateBasedDefaults();
      _validationError = null;
    });
  }

  Future<void> _pickReceipt(ImageSource source) async {
    final file = await _picker.pickImage(source: source, maxWidth: 1200, imageQuality: 80);
    if (file != null) setState(() => _receiptImage = file);
  }

  void _showReceiptSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Attach Receipt', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _dark)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: _green),
              title: const Text('Take Photo', style: TextStyle(fontSize: 15)),
              onTap: () { Navigator.pop(ctx); _pickReceipt(ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: _green),
              title: const Text('Choose from Gallery', style: TextStyle(fontSize: 15)),
              onTap: () { Navigator.pop(ctx); _pickReceipt(ImageSource.gallery); },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
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

  // ═══════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHandle(),
              const SizedBox(height: 8),
              _buildHeroAmount(),
              const SizedBox(height: 8),
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildMetaRow(),
              const SizedBox(height: 16),
              _buildReceiptSection(),
              const SizedBox(height: 20),
              _buildPaidBySection(),
              const SizedBox(height: 16),
              _buildSplitSection(),
              if (_validationError != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(_validationError!, style: const TextStyle(color: _red, fontSize: 12)),
                ),
              ],
              const SizedBox(height: 8),
              _buildNoteField(),
              const SizedBox(height: 20),
              _buildSaveButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return const Padding(
      padding: EdgeInsets.only(top: 10),
      child: Center(
        child: SizedBox(width: 36, height: 4, child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFFD1D5DB), borderRadius: BorderRadius.all(Radius.circular(2))))),
      ),
    );
  }

  // ─── Hero Amount ─────────────────────────────────────────────────────

  Widget _buildHeroAmount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
            textAlign: TextAlign.center,
            onChanged: (_) => setState(() => _validationError = null),
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w700, color: _dark, height: 1.2),
            decoration: InputDecoration(
              hintText: '${_sym}0',
              hintStyle: TextStyle(fontSize: 40, fontWeight: FontWeight.w300, color: Colors.grey.shade300),
              border: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            scrollPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChip('Today', Icons.calendar_today_rounded, _pickDate),
              const SizedBox(width: 8),
              _buildChip(
                _selectedCategory ?? 'Category',
                Icons.category_outlined,
                () => _showCategoryPicker(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 16, left: 0),
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const Text('Category', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _dark)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _categories.map((c) => ActionChip(
                label: Text(c, style: const TextStyle(fontSize: 13)),
                backgroundColor: _selectedCategory == c ? _greenLight : _bgCard,
                side: BorderSide.none,
                onPressed: () { setState(() => _selectedCategory = c); Navigator.pop(ctx); },
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String text, IconData icon, VoidCallback onTap) {
    final isDate = text == _formatDate(_selectedDate) || text == 'Today';
    final displayText = isDate ? text : text;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: _bgCard,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: _muted),
            const SizedBox(width: 5),
            Text(displayText, style: const TextStyle(fontSize: 12, color: _muted, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // ─── Title Field ─────────────────────────────────────────────────────

  Widget _buildTitleField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _titleController,
        textAlign: TextAlign.center,
        onChanged: (_) => setState(() => _validationError = null),
        style: const TextStyle(fontSize: 16, color: _dark, fontWeight: FontWeight.w500),
        decoration: const InputDecoration(
          hintText: 'What was the expense for?',
          hintStyle: TextStyle(fontSize: 16, color: Color(0xFFD1D5DB), fontWeight: FontWeight.w400),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  // ─── Meta Row ────────────────────────────────────────────────────────

  Widget _buildMetaRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildMetaChip(Icons.person_outline_rounded, widget.participants.firstWhere((p) => p.id == _paidById, orElse: () => widget.participants.first).name.split(' ').first, _pickPayer),
          const SizedBox(width: 8),
          _buildMetaChip(Icons.date_range_rounded, _formatDate(_selectedDate), _pickDate),
        ],
      ),
    );
  }

  void _pickPayer() async {
    final selected = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(100, 300, 100, 300),
      items: widget.participants.map((p) => PopupMenuItem(value: p.id, child: Text(p.name))).toList(),
    );
    if (selected != null) setState(() => _paidById = selected);
  }

  Widget _buildMetaChip(IconData icon, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: _bgCard, borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: _dark),
            const SizedBox(width: 4),
            Text(text, style: const TextStyle(fontSize: 12, color: _dark, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // ─── Receipt Attach ──────────────────────────────────────────────────

  Widget _buildReceiptSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _receiptImage != null
          ? _buildReceiptThumbnail()
          : _buildReceiptButton(),
    );
  }

  Widget _buildReceiptButton() {
    return GestureDetector(
      onTap: _showReceiptSourceSheet,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1.5, strokeAlign: BorderSide.strokeAlignInside),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 18, color: Colors.grey.shade400),
            const SizedBox(width: 8),
            Text('Add Receipt', style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptThumbnail() {
    return GestureDetector(
      onTap: _showReceiptSourceSheet,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _bgCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(File(_receiptImage!.path), width: 44, height: 44, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _receiptImage!.name,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: _dark),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _receiptImage = null),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: _redLight, shape: BoxShape.circle),
                child: const Icon(Icons.close_rounded, size: 14, color: _red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Paid By Section ─────────────────────────────────────────────────

  Widget _buildPaidBySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 2, bottom: 10),
            child: Text('Paid by', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _muted, letterSpacing: 0.3)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _bgCard,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 1))],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.participants.map((p) {
                  final selected = p.id == _paidById;
                  final idx = widget.participants.indexOf(p);
                  return Padding(
                    padding: EdgeInsets.only(right: idx < widget.participants.length - 1 ? 8 : 0),
                    child: _buildPayerAvatar(p, selected, idx),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayerAvatar(TourParticipant p, bool selected, int index) {
    final color = _avatarColors[index % _avatarColors.length];
    return GestureDetector(
      onTap: () => setState(() => _paidById = p.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? color : Colors.transparent, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: color,
              child: Text(
                p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 6),
              Text(p.name.split(' ').first, style: const TextStyle(fontSize: 12, color: _dark, fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              const Icon(Icons.check_circle_rounded, size: 14, color: _green),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Split Section ───────────────────────────────────────────────────

  Widget _buildSplitSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 2, bottom: 10),
            child: Text('Split', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _muted, letterSpacing: 0.3)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: _bgCard,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 1))],
            ),
            child: Column(
              children: [
                _buildSplitTypePills(),
                const SizedBox(height: 14),
                if (_lateJoiners.isNotEmpty) ...[
                  _buildLateJoinerBanner(),
                  const SizedBox(height: 10),
                ],
                _buildSplitDetails(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitTypePills() {
    final types = ['equal', 'exact', 'percentage', 'exclusion'];
    final labels = ['Equal', 'Exact', 'Percent', 'Exclude'];
    return Row(
      children: List.generate(types.length, (i) {
        final active = _splitType == types[i];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: i > 0 ? 6 : 0),
            child: GestureDetector(
              onTap: () => setState(() {
                _splitType = types[i];
                _validationError = null;
                _applyDateBasedDefaults();
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? _green : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: active ? _green : const Color(0xFFE5E7EB), width: 1),
                ),
                child: Center(
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      color: active ? Colors.white : _muted,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLateJoinerBanner() {
    final names = _lateJoiners.map((p) => p.name.split(' ').first).join(', ');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _greenLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 14, color: _green),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$names joined after ${_formatDate(_selectedDate)} — unchecked by default.',
              style: const TextStyle(fontSize: 11, color: _green),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Split Details (with live preview) ───────────────────────────────

  Widget _buildSplitDetails() {
    final showCheckboxes = _splitType == 'equal' || _splitType == 'exclusion';
    final showInputs = _splitType == 'exact' || _splitType == 'percentage';

    if (showCheckboxes) {
      return Column(
        children: widget.participants.map((p) {
          final excluded = _excludedIds.contains(p.id);
          final preview = _previewAmount(p.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: excluded ? Colors.transparent : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 24, height: 24,
                    child: Checkbox(
                      value: !excluded,
                      activeColor: _green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      side: WidgetStateBorderSide.resolveWith((_) => BorderSide(color: excluded ? Colors.grey.shade300 : _green)),
                      onChanged: (v) => setState(() {
                        if (v == true) { _excludedIds.remove(p.id); } else { _excludedIds.add(p.id); }
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: excluded ? Colors.grey.shade300 : _avatarColors[widget.participants.indexOf(p) % _avatarColors.length],
                    child: Text(p.name[0].toUpperCase(), style: TextStyle(color: excluded ? Colors.grey.shade500 : Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          p.name,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: excluded ? _muted : _dark),
                        ),
                        if (_hadNotJoinedYet(p))
                          Text('Joined later', style: TextStyle(fontSize: 10, color: excluded ? Colors.grey.shade400 : _muted)),
                      ],
                    ),
                  ),
                  if (preview != null)
                    Text(
                      preview,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: excluded ? Colors.grey.shade400 : _green,
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
            padding: const EdgeInsets.only(bottom: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: _avatarColors[widget.participants.indexOf(p) % _avatarColors.length],
                    child: Text(p.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      p.name,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _dark),
                    ),
                  ),
                  if (preview != null) ...[
                    Text(preview, style: const TextStyle(fontSize: 12, color: _muted, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 8),
                  ],
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _customValues[p.id],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                      textAlign: TextAlign.right,
                      onChanged: (_) => setState(() => _validationError = null),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _dark),
                      decoration: InputDecoration(
                        hintText: suffix == '%' ? '0' : '0',
                        suffixText: suffix,
                        suffixStyle: const TextStyle(fontSize: 12, color: _muted),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: _bgCard,
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

  Widget _buildNoteField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: _bgCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _noteController,
          maxLines: 1,
          style: const TextStyle(fontSize: 14, color: _dark),
          decoration: const InputDecoration(
            hintText: 'Add a note...',
            hintStyle: TextStyle(fontSize: 14, color: Color(0xFFD1D5DB)),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  // ─── Save Button ─────────────────────────────────────────────────────

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: FilledButton(
          onPressed: _isSaving ? null : _save,
          style: FilledButton.styleFrom(
            backgroundColor: _green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: _isSaving
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Save Expense', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
        ),
      ),
    );
  }
}
