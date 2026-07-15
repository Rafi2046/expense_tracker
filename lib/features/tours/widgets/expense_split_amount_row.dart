import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';
import 'package:expense_tracker/features/tours/widgets/expense_participant_avatar.dart';

class ExpenseSplitAmountRow extends StatelessWidget {
  final ThemeData theme;
  final List<TourParticipant> participants;
  final String splitType;
  final Set<String> excludedIds;
  final Map<String, TextEditingController> customValues;
  final Map<String, String?> previews;
  final Set<String> lateJoinerIds;
  final String currencySymbol;
  final void Function(String id, bool included) onExcludedChanged;
  final void Function(String id) onCustomValueChanged;
  final VoidCallback onResetSplit;

  const ExpenseSplitAmountRow({
    super.key,
    required this.theme,
    required this.participants,
    required this.splitType,
    required this.excludedIds,
    required this.customValues,
    required this.previews,
    required this.lateJoinerIds,
    required this.currencySymbol,
    required this.onExcludedChanged,
    required this.onCustomValueChanged,
    required this.onResetSplit,
  });

  @override
  Widget build(BuildContext context) {
    final showCheckboxes = splitType == 'equal' || splitType == 'exclusion';
    final showInputs = splitType == 'exact' || splitType == 'percentage';

    if (showCheckboxes) {
      return _buildCheckboxRows(context);
    }

    if (showInputs) {
      return _buildInputRows(context);
    }

    return const SizedBox.shrink();
  }

  Widget _buildCheckboxRows(BuildContext context) {
    return Column(
      children: participants.asMap().entries.map((entry) {
        final p = entry.value;
        final index = entry.key;
        final excluded = excludedIds.contains(p.id);
        final preview = previews[p.id];
        return Padding(
          padding: EdgeInsets.only(bottom: index < participants.length - 1 ? AppSpacing.s8 : 0),
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
                    onChanged: (v) => onExcludedChanged(p.id, v == true),
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                ExpenseParticipantAvatar(
                  name: p.name,
                  color: avatarColors[index % avatarColors.length],
                  radius: 14,
                  fontSize: AppFontSizes.size10,
                  backgroundColor: excluded
                      ? theme.dividerColor.withValues(alpha: 0.3)
                      : null,
                  textColor: excluded
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                      : null,
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
                      if (lateJoinerIds.contains(p.id))
                        Text(
                          context.translate('joined_later'),
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

  Widget _buildInputRows(BuildContext context) {
    final isPercentage = splitType == 'percentage';
    final isExact = splitType == 'exact';
    final suffix = isPercentage ? '%' : currencySymbol;
    return Column(
      children: [
        ...participants.asMap().entries.map((entry) {
          final p = entry.value;
          final index = entry.key;
          final preview = previews[p.id];
          return Padding(
            padding: EdgeInsets.only(bottom: index < participants.length - 1 ? AppSpacing.s8 : 0),
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
                  ExpenseParticipantAvatar(
                    name: p.name,
                    color: avatarColors[index % avatarColors.length],
                    radius: 14,
                    fontSize: AppFontSizes.size10,
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
                      controller: customValues[p.id],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                      ],
                      textAlign: TextAlign.right,
                      onChanged: (_) => onCustomValueChanged(p.id),
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
              onTap: onResetSplit,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.s6),
                decoration: BoxDecoration(
                  color: AppColors.activeGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSpacing.r8),
                ),
                child: Text(
                  context.translate('reset_split'),
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
}
