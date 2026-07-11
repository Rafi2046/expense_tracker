import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/features/reports/widgets/sort_by_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ReportSortButton extends StatelessWidget {
  const ReportSortButton({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final theme = Theme.of(context);

    return IconButton(
      icon: Icon(LucideIcons.filter, color: theme.appBarTheme.iconTheme?.color ?? theme.colorScheme.onSurface),
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
