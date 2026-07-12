import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/features/tours/widgets/expense_participant_avatar.dart';

class ExpenseParticipantSelector extends StatefulWidget {
  final ThemeData theme;
  final List<TourParticipant> participants;
  final Map<String, double> paidByAmounts;
  final Map<String, TextEditingController> amountControllers;
  final double totalAmount;
  final void Function(Map<String, double>) onPaidByChanged;

  const ExpenseParticipantSelector({
    super.key,
    required this.theme,
    required this.participants,
    required this.paidByAmounts,
    required this.amountControllers,
    required this.totalAmount,
    required this.onPaidByChanged,
  });

  @override
  State<ExpenseParticipantSelector> createState() =>
      _ExpenseParticipantSelectorState();
}

class _ExpenseParticipantSelectorState
    extends State<ExpenseParticipantSelector> {
  double _totalPaid = 0;

  @override
  void initState() {
    super.initState();
    _recalcTotal();
  }

  @override
  void didUpdateWidget(covariant ExpenseParticipantSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.paidByAmounts != widget.paidByAmounts) {
      _recalcTotal();
    }
  }

  void _recalcTotal() {
    double sum = 0;
    for (final v in widget.paidByAmounts.values) {
      sum += v;
    }
    _totalPaid = (sum * 100).round() / 100.0;
  }

  void _togglePayer(String id) {
    final updated = Map<String, double>.from(widget.paidByAmounts);
    if (updated.containsKey(id)) {
      updated.remove(id);
    } else {
      final remaining = widget.totalAmount - _totalPaid;
      if (remaining > 0) {
        updated[id] = (remaining * 100).round() / 100.0;
      } else if (widget.paidByAmounts.isEmpty) {
        updated[id] = widget.totalAmount;
      } else {
        updated[id] = 0;
      }
      // Focus the new amount field
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.amountControllers[id]?.selection = TextSelection.collapsed(offset: 0);
      });
    }
    widget.onPaidByChanged(updated);
  }

  void _updateAmount(String id, String text) {
    final value = double.tryParse(text) ?? 0;
    final updated = Map<String, double>.from(widget.paidByAmounts);
    if (value <= 0 && text.trim().isEmpty) {
      updated.remove(id);
    } else {
      updated[id] = value;
    }
    widget.onPaidByChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final diff = (widget.totalAmount * 100).round() - (_totalPaid * 100).round();
    final isBalanced = diff == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...widget.participants.asMap().entries.map((entry) {
          final p = entry.value;
          final index = entry.key;
          final selected = widget.paidByAmounts.containsKey(p.id);
          final color = avatarColors[index % avatarColors.length];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < widget.participants.length - 1
                  ? AppSpacing.s8
                  : 0,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.p12,
                vertical: AppSpacing.p8,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? color.withValues(alpha: 0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSpacing.r10),
                border: Border.all(
                  color: selected
                      ? color.withValues(alpha: 0.4)
                      : widget.theme.dividerColor.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _togglePayer(p.id),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: Checkbox(
                            value: selected,
                            activeColor: AppColors.activeGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.r4),
                            ),
                            side: WidgetStateBorderSide.resolveWith(
                              (_) => BorderSide(
                                color: selected
                                    ? AppColors.activeGreen
                                    : widget.theme.dividerColor,
                              ),
                            ),
                            onChanged: (_) => _togglePayer(p.id),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s8),
                        ExpenseParticipantAvatar(
                          name: p.name,
                          color: color,
                          radius: 14,
                          fontSize: AppFontSizes.size10,
                          backgroundColor: selected ? null : null,
                        ),
                        const SizedBox(width: AppSpacing.s8),
                        Text(
                          p.name.split(' ').first,
                          style: AppTextStyles.label.copyWith(
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? widget.theme.colorScheme.onSurface
                                : widget.theme.colorScheme.onSurface
                                    .withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selected) ...[
                    const Spacer(),
                    SizedBox(
                      width: 90,
                      child: TextField(
                        controller: widget.amountControllers[p.id],
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                        ],
                        textAlign: TextAlign.right,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: widget.theme.colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.r8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: widget.theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s8,
                            vertical: AppSpacing.s6,
                          ),
                          isDense: true,
                        ),
                        onChanged: (v) => _updateAmount(p.id, v),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: AppSpacing.s8),
        Row(
          children: [
            Icon(
              isBalanced ? LucideIcons.checkCircle : LucideIcons.alertCircle,
              size: 14,
              color: isBalanced ? AppColors.activeGreen : AppColors.activeRed,
            ),
            const SizedBox(width: AppSpacing.s6),
            Text(
              'Total paid: $_totalPaid / ${widget.totalAmount}',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: isBalanced
                    ? AppColors.activeGreen
                    : AppColors.activeRed,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
