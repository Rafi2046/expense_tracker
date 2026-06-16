import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_edit_debt_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/debt_item_row.dart';
import 'package:expense_tracker/features/dashboard/widgets/debt_total_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ToReceiveScreen extends StatelessWidget {
  const ToReceiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final debtProvider = context.watch<DebtProvider>();
    final items = debtProvider.toReceiveUnpaid;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'To Receive',
          style: AppTextStyles.appbarTitle.copyWith(
            fontFamily: GoogleFonts.workSans().fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddEditDebtSheet.show(
          context: context,
          payeeLabel: 'Client/Friend Name',
          themeColor: AppColors.buttonColor,
          isReceive: true,
        ),
        backgroundColor: AppColors.buttonColor,
        elevation: 2,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DebtTotalCard(
                title: 'TOTAL OWED TO YOU',
                amount: debtProvider.totalToReceive,
                amountColor: AppColors.buttonColor,
                borderColor: const Color(0xFFEBF5FB),
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
                            'No pending payments!',
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return DebtItemRow(
                          item: item,
                          themeColor: AppColors.buttonColor,
                          onEditTap: () => AddEditDebtSheet.show(
                            context: context,
                            item: item,
                            payeeLabel: 'Client/Friend Name',
                            themeColor: AppColors.buttonColor,
                            isReceive: true,
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
