import 'package:flutter/material.dart';

class ExpenseSheetDragHandle extends StatelessWidget {
  final ThemeData theme;

  const ExpenseSheetDragHandle({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Center(
        child: Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
