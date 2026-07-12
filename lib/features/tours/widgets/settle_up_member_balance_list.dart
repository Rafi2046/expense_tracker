import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'settle_up_summary_card.dart';

class SettleUpMemberBalanceList extends StatelessWidget {
  final String formattedTotalOutstanding;
  final List<Widget> settlementTiles;

  const SettleUpMemberBalanceList({
    super.key,
    required this.formattedTotalOutstanding,
    required this.settlementTiles,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.p16, AppSpacing.s8, AppSpacing.p16, 100),
      children: [
        SettleUpSummaryCard(formattedAmount: formattedTotalOutstanding),
        const SizedBox(height: AppSpacing.h24),
        ...settlementTiles.map((tile) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s16),
          child: tile,
        )),
      ],
    );
  }
}
