import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpenseTimeFrameSelector extends StatelessWidget {
  final List<String> timeFrames;
  final String selectedTimeFrame;
  final Function(String) onTimeFrameChanged;

  const ExpenseTimeFrameSelector({
    super.key,
    required this.timeFrames,
    required this.selectedTimeFrame,
    required this.onTimeFrameChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: timeFrames.map((tf) {
          final isSelected = tf == selectedTimeFrame;

          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () => onTimeFrameChanged(tf),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.expensePink : AppColors.chipBackground,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  tf,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black87,
                    fontFamily: GoogleFonts.workSans().fontFamily,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
