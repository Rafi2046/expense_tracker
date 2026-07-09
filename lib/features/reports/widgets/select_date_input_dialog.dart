import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/reports/models/select_date_input_dialog_result.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SelectDateInputDialog extends StatefulWidget {
  final DateTimeRange initialRange;

  const SelectDateInputDialog({
    super.key,
    required this.initialRange,
  });

  static Future<SelectDateInputDialogResult?> show(
    BuildContext context, {
    required DateTimeRange initialRange,
  }) {
    return showDialog<SelectDateInputDialogResult>(
      context: context,
      barrierDismissible: true,
      builder: (context) => SelectDateInputDialog(initialRange: initialRange),
    );
  }

  @override
  State<SelectDateInputDialog> createState() => _SelectDateInputDialogState();
}

class _SelectDateInputDialogState extends State<SelectDateInputDialog> {
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _startError;
  String? _endError;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialRange.start;
    _endDate = widget.initialRange.end;

    _startDateController = TextEditingController(text: _formatDateForInput(_startDate));
    _endDateController = TextEditingController(text: _formatDateForInput(_endDate));
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  String _formatDateForInput(DateTime? date) {
    if (date == null) return '';
    return '${date.month}/${date.day}/${date.year}';
  }

  DateTime? _parseDate(String text) {
    try {
      final parts = text.split('/');
      if (parts.length != 3) return null;
      final month = int.tryParse(parts[0]);
      final day = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);

      if (month == null || day == null || year == null) return null;
      if (month < 1 || month > 12) return null;
      if (day < 1 || day > 31) return null;
      if (year < 1000 || year > 3000) return null;

      final date = DateTime(year, month, day);
      if (date.year != year || date.month != month || date.day != day) return null;
      return date;
    } catch (_) {
      return null;
    }
  }

  void _onStartDateChanged(String val) {
    final parsed = _parseDate(val);
    setState(() {
      _startDate = parsed;
      _startError = val.isNotEmpty && parsed == null ? 'Invalid date' : null;
    });
  }

  void _onEndDateChanged(String val) {
    final parsed = _parseDate(val);
    setState(() {
      _endDate = parsed;
      _endError = val.isNotEmpty && parsed == null ? 'Invalid date' : null;
    });
  }

  String get _rangeText {
    if (_startDate == null && _endDate == null) return 'Select date';
    final startFormat = _startDate != null ? DateFormat('MMM d').format(_startDate!) : '?';
    final endFormat = _endDate != null ? DateFormat('MMM d').format(_endDate!) : '?';
    return '$startFormat – $endFormat';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isOkEnabled = _startDate != null && _endDate != null && !_startDate!.isAfter(_endDate!);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: theme.cardColor,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Date',
                style: AppTextStyles.reportStatLabel.copyWith(
                  color: isDark ? Colors.white30 : Colors.grey.shade500,
                  fontSize: AppFontSizes.size12,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _rangeText,
                      style: AppTextStyles.reportAppBarTitle.copyWith(
                        fontSize: AppFontSizes.size22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.calendar, color: theme.colorScheme.onSurface),
                    onPressed: () {
                      final currentStart = _startDate ?? widget.initialRange.start;
                      final currentEnd = _endDate ?? widget.initialRange.end;
                      Navigator.pop(
                        context,
                        SelectDateInputDialogResult(
                          range: DateTimeRange(
                            start: currentStart,
                            end: currentStart.isAfter(currentEnd) ? currentStart : currentEnd,
                          ),
                          shouldSubmit: false,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start date',
                          style: AppTextStyles.reportStatLabel.copyWith(
                            color: _startError != null ? AppColors.activeRed : theme.primaryColor,
                          ),
                        ),
                        TextField(
                          controller: _startDateController,
                          onChanged: _onStartDateChanged,
                          keyboardType: TextInputType.datetime,
                          decoration: InputDecoration(
                            hintText: 'm/d/yyyy',
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: theme.primaryColor, width: 2),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: theme.dividerTheme.color ?? Colors.grey.shade300),
                            ),
                            errorText: _startError,
                          ),
                          style: AppTextStyles.partyFormInput.copyWith(fontSize: AppFontSizes.size15, color: theme.colorScheme.onSurface),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'End date',
                          style: AppTextStyles.reportStatLabel.copyWith(
                            color: _endError != null ? AppColors.activeRed : (isDark ? Colors.white60 : Colors.grey.shade600),
                          ),
                        ),
                        TextField(
                          controller: _endDateController,
                          onChanged: _onEndDateChanged,
                          keyboardType: TextInputType.datetime,
                          decoration: InputDecoration(
                            hintText: 'm/d/yyyy',
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: theme.primaryColor, width: 2),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: theme.dividerTheme.color ?? Colors.grey.shade300),
                            ),
                            errorText: _endError,
                          ),
                          style: AppTextStyles.partyFormInput.copyWith(fontSize: AppFontSizes.size15, color: theme.colorScheme.onSurface),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.dialogCloseButton.copyWith(
                        color: theme.primaryColor,
                        fontSize: AppFontSizes.size15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: isOkEnabled
                        ? () {
                            Navigator.pop(
                              context,
                              SelectDateInputDialogResult(
                                range: DateTimeRange(start: _startDate!, end: _endDate!),
                                shouldSubmit: true,
                              ),
                            );
                          }
                        : null,
                    child: Text(
                      'Ok',
                      style: AppTextStyles.dialogCloseButton.copyWith(
                        color: isOkEnabled ? theme.primaryColor : (isDark ? Colors.white24 : Colors.grey.shade400),
                        fontSize: AppFontSizes.size15,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
