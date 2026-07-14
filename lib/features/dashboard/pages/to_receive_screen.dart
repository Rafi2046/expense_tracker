import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_edit_debt_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/debt_item_row.dart';
import 'package:expense_tracker/features/dashboard/widgets/debt_total_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ToReceiveScreen extends StatefulWidget {
  const ToReceiveScreen({super.key});

  @override
  State<ToReceiveScreen> createState() => _ToReceiveScreenState();
}

class _ToReceiveScreenState extends State<ToReceiveScreen> {
  static bool _localMasked = false;
  bool _showGuide = true;

  void _confirmDelete(BuildContext context, DebtItem item, DebtProvider provider) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.dialogTheme.backgroundColor ?? theme.cardColor,
        title: Text(
          'Delete Debt',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: Text(
          'Are you sure you want to delete this debt?',
          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              provider.deleteDebtItem(item.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item.name}\'s debt deleted'),
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final debtProvider = context.watch<DebtProvider>();
    final items = debtProvider.toReceiveUnpaid;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            LucideIcons.arrowLeft,
            color: theme.appBarTheme.iconTheme?.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'To Receive',
          style: AppTextStyles.appbarTitle.copyWith(
            color: theme.appBarTheme.titleTextStyle?.color,
            fontFamily: GoogleFonts.workSans().fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 88,
        ),
        child: FloatingActionButton(
          onPressed: () => AddEditDebtSheet.show(
            context: context,
            payeeLabel: 'Client/Friend Name',
            themeColor: theme.primaryColor,
            isReceive: true,
          ),
          backgroundColor: theme.primaryColor,
          elevation: 2,
          child: Icon(LucideIcons.plus, color: Colors.white, size: 28),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DebtTotalCard(
                title: 'TOTAL OWED TO YOU',
                amount: debtProvider.totalToReceive,
                gradientColors: const [Color(0xFF0C4E3C), Color(0xFF197F63)],
                guideText:
                    'Swipe left on any item to quickly settle, or tap ✎ to edit details.',
                showGuide: _showGuide,
                onDismissGuide: () {
                  setState(() {
                    _showGuide = false;
                  });
                },
                cardIcon: LucideIcons.arrowDown,
                isMasked: _localMasked,
                onToggleMask: () => setState(() => _localMasked = !_localMasked),
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
                          'Pending Collections',
                          style: AppTextStyles.sectionHeaderTitle.copyWith(color: theme.colorScheme.onSurface),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${items.length}',
                            style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor),
                          ),
                        ),
                      ],
                    ),
                    if (!_showGuide)
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          LucideIcons.info,
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

            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AppImages.pendingPayments,
                              height: 120,
                              width: 120,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No pending payments!',
                              style: AppTextStyles.reportTileTitle.copyWith(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
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
                          themeColor: theme.primaryColor,
                          isMasked: _localMasked,
                          onEditTap: () => AddEditDebtSheet.show(
                            context: context,
                            item: item,
                            payeeLabel: 'Client/Friend Name',
                            themeColor: theme.primaryColor,
                            isReceive: true,
                          ),
                          onDelete: () => _confirmDelete(context, item, debtProvider),
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
