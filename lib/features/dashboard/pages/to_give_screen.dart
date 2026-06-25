import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_edit_debt_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/debt_item_row.dart';
import 'package:expense_tracker/features/dashboard/widgets/debt_total_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ToGiveScreen extends StatefulWidget {
  const ToGiveScreen({super.key});

  @override
  State<ToGiveScreen> createState() => _ToGiveScreenState();
}

class _ToGiveScreenState extends State<ToGiveScreen> {
  bool _showGuide = true;

  @override
  Widget build(BuildContext context) {
    final debtProvider = context.watch<DebtProvider>();
    final items = debtProvider.toGiveUnpaid;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.appBarTheme.iconTheme?.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'To Give',
          style: AppTextStyles.appbarTitle.copyWith(
            color: theme.appBarTheme.titleTextStyle?.color,
            fontFamily: GoogleFonts.workSans().fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddEditDebtSheet.show(
          context: context,
          payeeLabel: 'Payee Name',
          themeColor: AppColors.activeRed,
          isReceive: false,
        ),
        backgroundColor: theme.primaryColor,
        elevation: 2,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DebtTotalCard(
                title: 'TOTAL YOU OWE',
                amount: debtProvider.totalToGive,
                gradientColors: const [Color(0xFFB01D2E), Color(0xFFDC3545)],
                guideText:
                    'Swipe left on any item to quickly settle, or tap ✎ to edit details.',
                showGuide: _showGuide,
                onDismissGuide: () {
                  setState(() {
                    _showGuide = false;
                  });
                },
                cardIcon: Icons.arrow_upward_rounded,
              ),
            ),
            if (items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Active Payables',
                          style: GoogleFonts.workSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.activeRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${items.length}',
                            style: GoogleFonts.workSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.activeRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!_showGuide)
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.info_outline_rounded,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _showGuide = true;
                          });
                        },
                        tooltip: 'Show Guide',
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No pending debts!',
                            style: GoogleFonts.workSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return DebtItemRow(
                          item: item,
                          themeColor: AppColors.activeRed,
                          onEditTap: () => AddEditDebtSheet.show(
                            context: context,
                            item: item,
                            payeeLabel: 'Payee Name',
                            themeColor: AppColors.activeRed,
                            isReceive: false,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
