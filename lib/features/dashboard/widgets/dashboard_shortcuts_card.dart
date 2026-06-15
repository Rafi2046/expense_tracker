import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/shortcut_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/edit_shortcuts_sheet.dart';
import 'package:expense_tracker/features/notes/pages/add_note_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DashboardShortcutsCard extends StatelessWidget {
  const DashboardShortcutsCard({super.key});

  Widget _buildShortcutIcon(String id) {
    const Color activeGreen = AppColors.activeGreen;
    switch (id) {
      case 'add_note':
        return const Icon(Icons.notes, size: 28, color: activeGreen);
      case 'payment_out':
        return const Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 6.0),
              child: Icon(Icons.account_balance_wallet_outlined, size: 24, color: activeGreen),
            ),
            Positioned(
              top: 0,
              child: Icon(Icons.arrow_upward, size: 12, color: activeGreen),
            ),
          ],
        );
      case 'income':
        return const Icon(Icons.payments_outlined, size: 28, color: activeGreen);
      case 'expense':
        return const Icon(Icons.account_balance_wallet_outlined, size: 28, color: activeGreen);
      case 'payment_in':
        return const Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 6.0),
              child: Icon(Icons.account_balance_wallet_outlined, size: 24, color: activeGreen),
            ),
            Positioned(
              top: 0,
              child: Icon(Icons.arrow_downward, size: 12, color: activeGreen),
            ),
          ],
        );
      case 'add_party':
        return const Icon(Icons.person_add_outlined, size: 28, color: activeGreen);
      default:
        return const Icon(Icons.help_outline, size: 28, color: activeGreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shortcutProvider = context.watch<ShortcutProvider>();
    final activeShortcuts = shortcutProvider.activeShortcuts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: GoogleFonts.workSans().fontFamily,
              ),
            ),
            GestureDetector(
              onTap: () => EditShortcutsSheet.show(context),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.edit_square,
                      size: 18,
                      color: AppColors.activeGreen,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Edit Menu',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.activeGreen,
                        fontFamily: GoogleFonts.workSans().fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Container Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: const Color(0xFFF0F0F0),
              width: 1,
            ),
          ),
          child: activeShortcuts.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No quick actions enabled. Tap "Edit Menu" to add some.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        fontFamily: GoogleFonts.workSans().fontFamily,
                      ),
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activeShortcuts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemBuilder: (context, index) {
                    final item = activeShortcuts[index];
                    return GestureDetector(
                      onTap: () {
                        if (item.id == 'add_note') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddNoteScreen(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${item.label} shortcut clicked'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Round Icon Container
                          Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8F8F5),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: _buildShortcutIcon(item.id),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Label
                          Text(
                            item.label,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF31394D),
                              fontFamily: GoogleFonts.workSans().fontFamily,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
