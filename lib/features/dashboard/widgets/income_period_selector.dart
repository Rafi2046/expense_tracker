import 'package:expense_tracker/features/dashboard/widgets/time_frame_selector.dart';
import 'package:flutter/material.dart';

class IncomePeriodSelector extends StatelessWidget {
  final String selectedTimeFrame;
  final ValueChanged<String> onTimeFrameChanged;

  const IncomePeriodSelector({
    super.key,
    required this.selectedTimeFrame,
    required this.onTimeFrameChanged,
  });

  static const List<String> timeFrames = ['Daily', 'Weekly', 'Monthly', 'Quarterly'];

  @override
  Widget build(BuildContext context) {
    return TimeFrameSelector(
      timeFrames: timeFrames,
      selectedTimeFrame: selectedTimeFrame,
      onTimeFrameChanged: onTimeFrameChanged,
    );
  }
}
