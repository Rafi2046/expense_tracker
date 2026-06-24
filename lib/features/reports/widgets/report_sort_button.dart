import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/features/reports/widgets/sort_by_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportSortButton extends StatelessWidget {
  const ReportSortButton({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();

    return IconButton(
      icon: const Icon(Icons.filter_list_rounded, color: Colors.black87),
      onPressed: () async {
        final selected = await SortBySheet.show(
          context,
          currentOption: reportsProvider.sortOption,
        );
        if (selected != null) {
          reportsProvider.setSortOption(selected);
        }
      },
    );
  }
}
