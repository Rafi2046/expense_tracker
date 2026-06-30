import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/models/tour_expense.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';

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
  final _formKey = GlobalKey<FormState>();

  String? _selectedCategory;
  String _paidById = '';
  String _splitType = 'equal';
  final Set<String> _excludedIds = {};
  bool _isSaving = false;
  String? _validationError;

  final _categories = [
    'Food', 'Transport', 'Accommodation', 'Activities',
    'Shopping', 'Drinks', 'Groceries', 'Fuel', 'Tickets', 'Other',
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

  String _currencySymbol() {
    const symbols = {
      'BDT': '৳', 'USD': '\$', 'EUR': '€', 'GBP': '£',
      'INR': '₹', 'JPY': '¥', 'AED': 'د.إ', 'CAD': '\$',
    };
    return symbols[widget.currency] ?? '\$';
  }

  List<TourParticipant> get _includedParticipants =>
      widget.participants.where((p) => !_excludedIds.contains(p.id)).toList();

  String? _validate() {
    if (_titleController.text.trim().isEmpty) return 'Enter a title';
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return 'Enter a valid amount';

    if (_paidById.isEmpty) return 'Select who paid';

    if (_splitType == 'exact') {
      final total = widget.participants
          .where((p) => !_excludedIds.contains(p.id))
          .fold(0.0, (sum, p) {
        final v = double.tryParse(_customValues[p.id]?.text.trim() ?? '') ?? 0;
        return sum + v;
      });
      if ((total * 100).round() != (amount * 100).round()) {
        return 'Exact amounts must total ${_currencySymbol()}${amount.toStringAsFixed(2)}';
      }
    }

    if (_splitType == 'percentage') {
      final total = widget.participants
          .where((p) => !_excludedIds.contains(p.id))
          .fold(0.0, (sum, p) {
        final v = double.tryParse(_customValues[p.id]?.text.trim() ?? '') ?? 0;
        return sum + v;
      });
      if ((total * 100).round() != 10000) {
        return 'Percentages must total 100%';
      }
    }

    if (_splitType != 'exact' && _splitType != 'percentage') {
      if (_includedParticipants.isEmpty) {
        return 'At least one person must be included';
      }
    }

    return null;
  }

  Future<void> _save() async {
    setState(() {
      _validationError = _validate();
    });
    if (_validationError != null) return;

    setState(() => _isSaving = true);

    final amount = double.parse(_amountController.text.trim());
    final expense = TourExpense(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      tourId: widget.tourId,
      title: _titleController.text.trim(),
      amount: amount,
      paidBy: _paidById,
      splitType: _splitType,
      category: _selectedCategory,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      date: DateTime.now(),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHandle(theme),
                const SizedBox(height: 16),
                _buildHeader(theme),
                const SizedBox(height: 20),
                _buildTitleField(theme),
                const SizedBox(height: 12),
                _buildAmountField(theme),
                const SizedBox(height: 12),
                _buildCategoryField(theme),
                const SizedBox(height: 16),
                _buildPaidBySection(theme),
                const SizedBox(height: 16),
                _buildSplitTypeSelector(theme),
                const SizedBox(height: 12),
                _buildSplitDetails(theme),
                if (_validationError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _validationError!,
                    style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 8),
                _buildNoteField(theme),
                const SizedBox(height: 20),
                _buildSaveButton(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHandle(ThemeData theme) {
    return Center(
      child: Container(
        width: 36, height: 4,
        decoration: BoxDecoration(
          color: theme.dividerColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Text(
          'Add Expense',
          style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: Icon(Icons.close_rounded, color: theme.colorScheme.onSurfaceVariant),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildTitleField(ThemeData theme) {
    return TextField(
      controller: _titleController,
      decoration: _inputDecoration(theme, 'Title', 'e.g. Dinner'),
      style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 15),
    );
  }

  Widget _buildAmountField(ThemeData theme) {
    return TextField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
      decoration: _inputDecoration(theme, 'Amount', '0.00', prefix: _currencySymbol()),
      style: TextStyle(
        color: theme.colorScheme.onSurface, fontSize: 15,
        fontFamily: 'JetBrainsMono',
      ),
    );
  }

  Widget _buildCategoryField(ThemeData theme) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: _inputDecoration(theme, 'Category', null),
      dropdownColor: theme.colorScheme.surface,
      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
      onChanged: (v) => setState(() => _selectedCategory = v),
      style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
    );
  }

  Widget _buildPaidBySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Paid by', style: _labelStyle(theme)),
        const SizedBox(height: 8),
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.participants.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final p = widget.participants[index];
              final selected = p.id == _paidById;
              return GestureDetector(
                onTap: () => setState(() => _paidById = p.id),
                child: _AvatarChip(
                  name: p.name,
                  color: _avatarColors[index % _avatarColors.length],
                  selected: selected,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSplitTypeSelector(ThemeData theme) {
    final types = ['equal', 'exact', 'percentage', 'exclusion'];
    final labels = ['Equal', 'Exact', '%', 'Exclude'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Split type', style: _labelStyle(theme)),
        const SizedBox(height: 8),
        Row(
          children: List.generate(types.length, (i) {
            final active = _splitType == types[i];
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i > 0 ? 6 : 0),
                child: GestureDetector(
                  onTap: () => setState(() {
                    _splitType = types[i];
                    _validationError = null;
                    _excludedIds.clear();
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFF2EBD85)
                          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        labels[i],
                        style: TextStyle(
                          color: active ? Colors.white : theme.colorScheme.onSurfaceVariant,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSplitDetails(ThemeData theme) {
    final showCheckboxes = _splitType == 'equal' || _splitType == 'exclusion';
    final showInputs = _splitType == 'exact' || _splitType == 'percentage';

    if (showCheckboxes) {
      return Column(
        children: widget.participants.map((p) {
          final excluded = _excludedIds.contains(p.id);
          return _SplitRow(
            theme: theme,
            participant: p,
            leading: Checkbox(
              value: !excluded,
              activeColor: const Color(0xFF2EBD85),
              onChanged: (v) {
                setState(() {
                  if (v == true) {
                    _excludedIds.remove(p.id);
                  } else {
                    _excludedIds.add(p.id);
                  }
                });
              },
            ),
          );
        }).toList(),
      );
    }

    if (showInputs) {
      final suffix = _splitType == 'percentage' ? '%' : _currencySymbol();
      return Column(
        children: widget.participants.map((p) {
          return _SplitRow(
            theme: theme,
            participant: p,
            trailing: SizedBox(
              width: 90,
              child: TextField(
                controller: _customValues[p.id],
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: suffix == '%' ? '0%' : '0.00',
                  suffixText: suffix,
                  suffixStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  isDense: true,
                ),
                style: TextStyle(
                  color: theme.colorScheme.onSurface, fontSize: 13,
                  fontFamily: 'JetBrainsMono',
                ),
                onChanged: (_) => setState(() => _validationError = null),
              ),
            ),
          );
        }).toList(),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildNoteField(ThemeData theme) {
    return TextField(
      controller: _noteController,
      maxLines: 2,
      decoration: _inputDecoration(theme, 'Note (optional)', null),
      style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
    );
  }

  Widget _buildSaveButton(ThemeData theme) {
    return FilledButton(
      onPressed: _isSaving ? null : _save,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF2EBD85),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _isSaving
          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Text('Save Expense', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
    );
  }

  InputDecoration _inputDecoration(ThemeData theme, String label, String? hint, {String? prefix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefix,
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  TextStyle _labelStyle(ThemeData theme) => TextStyle(
    fontSize: 13, fontWeight: FontWeight.w600,
    color: theme.colorScheme.onSurfaceVariant,
  );

  static const _avatarColors = [
    Color(0xFF667eea), Color(0xFFf5576c), Color(0xFF43e97b),
    Color(0xFFfa709a), Color(0xFF4facfe), Color(0xFFa18cd1),
    Color(0xFFfccb90), Color(0xFF38f9d7),
  ];
}

// ─── Sub-widgets ──────────────────────────────────────────────────────

class _AvatarChip extends StatelessWidget {
  final String name;
  final Color color;
  final bool selected;

  const _AvatarChip({required this.name, required this.color, required this.selected});

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 56,
      decoration: BoxDecoration(
        color: selected ? color.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? color : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color,
            child: Text(_initials, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 3),
          Text(
            name.split(' ').first,
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9, color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _SplitRow extends StatelessWidget {
  final ThemeData theme;
  final TourParticipant participant;
  final Widget? leading;
  final Widget? trailing;

  const _SplitRow({
    required this.theme,
    required this.participant,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          ?leading,
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.grey.shade400,
            child: Text(
              participant.name.isNotEmpty ? participant.name[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 10),
          Text(participant.name, style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
          const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}
