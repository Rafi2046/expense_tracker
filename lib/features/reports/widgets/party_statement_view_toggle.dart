import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PartyStatementViewToggle extends StatelessWidget {
  const PartyStatementViewToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final mode = reportsProvider.partyStatementViewMode;

    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTab(
            isActive: mode == PartyStatementViewMode.card,
            icon: Icons.layers_outlined,
            onTap: () => reportsProvider.setPartyStatementViewMode(PartyStatementViewMode.card),
          ),
          _buildTab(
            isActive: mode == PartyStatementViewMode.table,
            icon: Icons.insert_chart_outlined_rounded,
            onTap: () => reportsProvider.setPartyStatementViewMode(PartyStatementViewMode.table),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required bool isActive,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 36,
        height: 32,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.black87 : Colors.grey.shade500,
          size: 20,
        ),
      ),
    );
  }
}
