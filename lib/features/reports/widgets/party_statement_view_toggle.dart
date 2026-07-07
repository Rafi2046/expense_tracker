import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PartyStatementViewToggle extends StatelessWidget {
  const PartyStatementViewToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final mode = reportsProvider.partyStatementViewMode;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.onSurface.withValues(alpha: 0.08) : const Color(0xFFF1F2F4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTab(
            context: context,
            isActive: mode == PartyStatementViewMode.card,
            icon: Symbols.layers,
            onTap: () => reportsProvider.setPartyStatementViewMode(PartyStatementViewMode.card),
          ),
          _buildTab(
            context: context,
            isActive: mode == PartyStatementViewMode.table,
            icon: Symbols.insert_chart_rounded,
            onTap: () => reportsProvider.setPartyStatementViewMode(PartyStatementViewMode.table),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required BuildContext context,
    required bool isActive,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 36,
        height: 32,
        decoration: BoxDecoration(
          color: isActive ? theme.cardColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: isActive ? theme.colorScheme.onSurface : (isDark ? Colors.white38 : Colors.grey.shade500),
          size: 20,
        ),
      ),
    );
  }
}
