import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';

class SelectDateInputDialogResult {
  final DateTimeRange range;
  final bool shouldSubmit;

  SelectDateInputDialogResult({
    required this.range,
    required this.shouldSubmit,
  });
}

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
    final isOkEnabled = _startDate != null && _endDate != null && !_startDate!.isAfter(_endDate!);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.white,
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
                  color: Colors.grey.shade500,
                  fontSize: 12,
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
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today_outlined, color: Colors.black87),
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
                            fontSize: 11,
                            color: _startError != null ? AppColors.activeRed : AppColors.activeGreen,
                          ),
                        ),
                        TextField(
                          controller: _startDateController,
                          onChanged: _onStartDateChanged,
                          keyboardType: TextInputType.datetime,
                          decoration: InputDecoration(
                            hintText: 'm/d/yyyy',
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: AppColors.activeGreen, width: 2),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            errorText: _startError,
                          ),
                          style: AppTextStyles.partyFormInput.copyWith(fontSize: 15),
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
                            fontSize: 11,
                            color: _endError != null ? AppColors.activeRed : Colors.grey.shade600,
                          ),
                        ),
                        TextField(
                          controller: _endDateController,
                          onChanged: _onEndDateChanged,
                          keyboardType: TextInputType.datetime,
                          decoration: InputDecoration(
                            hintText: 'm/d/yyyy',
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: AppColors.activeGreen, width: 2),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            errorText: _endError,
                          ),
                          style: AppTextStyles.partyFormInput.copyWith(fontSize: 15),
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
                        color: AppColors.activeGreen,
                        fontSize: 15,
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
                        color: isOkEnabled ? AppColors.activeGreen : Colors.grey.shade400,
                        fontSize: 15,
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
