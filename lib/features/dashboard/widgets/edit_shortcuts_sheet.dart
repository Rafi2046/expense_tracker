import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/shortcut_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EditShortcutsSheet extends StatefulWidget {
  const EditShortcutsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const EditShortcutsSheet(),
    );
  }

  @override
  State<EditShortcutsSheet> createState() => _EditShortcutsSheetState();
}

class _EditShortcutsSheetState extends State<EditShortcutsSheet> {
  late List<ShortcutItem> _draftShortcuts;

  @override
  void initState() {
    super.initState();
    // Read the current shortcuts from Provider and make a copy
    final shortcutProvider = Provider.of<ShortcutProvider>(context, listen: false);
    _draftShortcuts = List.from(shortcutProvider.shortcuts);
  }

  Widget _buildShortcutIcon(String id) {
    const Color activeGreen = AppColors.activeGreen;
    switch (id) {
      case 'payment_out':
        return const Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 5.0),
              child: Icon(Icons.account_balance_wallet_outlined, size: 20, color: activeGreen),
            ),
            Positioned(
              top: 0,
              child: Icon(Icons.arrow_upward, size: 10, color: activeGreen),
            ),
          ],
        );
      case 'income':
        return const Icon(Icons.payments_outlined, size: 22, color: activeGreen);
      case 'expense':
        return const Icon(Icons.account_balance_wallet_outlined, size: 22, color: activeGreen);
      case 'payment_in':
        return const Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 5.0),
              child: Icon(Icons.account_balance_wallet_outlined, size: 20, color: activeGreen),
            ),
            Positioned(
              top: 0,
              child: Icon(Icons.arrow_downward, size: 10, color: activeGreen),
            ),
          ],
        );
      case 'add_party':
        return const Icon(Icons.person_add_outlined, size: 22, color: activeGreen);
      default:
        return const Icon(Icons.help_outline, size: 22, color: activeGreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: mediaQuery.viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle pill
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Header title
          Text(
            'Edit Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: GoogleFonts.workSans().fontFamily,
            ),
          ),
          const SizedBox(height: 16),
          
          // Reorderable list
          Theme(
            data: theme.copyWith(
              canvasColor: Colors.transparent, // Prevents default background shadow during drag
            ),
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: _draftShortcuts.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = _draftShortcuts.removeAt(oldIndex);
                  _draftShortcuts.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final item = _draftShortcuts[index];
                return Container(
                  key: ValueKey(item.id),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Row(
                    children: [
                      // Reorder Drag Handle
                      ReorderableDragStartListener(
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          child: Icon(
                            Icons.drag_indicator_rounded,
                            color: Colors.grey.shade400,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                      // Circle icon background
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F8F5),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: _buildShortcutIcon(item.id),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Label
                      Expanded(
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF31394D),
                            fontFamily: GoogleFonts.workSans().fontFamily,
                          ),
                        ),
                      ),
                      
                      // Checkbox styled or Locked Icon
                      if (item.id == 'add_party')
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14.0),
                          child: Icon(
                            Icons.lock_rounded,
                            color: AppColors.activeGreen,
                            size: 20,
                          ),
                        )
                      else
                        Checkbox(
                          value: item.isEnabled,
                          activeColor: AppColors.activeGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                          onChanged: (val) {
                            setState(() {
                              _draftShortcuts[index] = item.copyWith(isEnabled: val ?? false);
                            });
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          
          // Action buttons row
          Row(
            children: [
              // Cancel Button
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontFamily: GoogleFonts.workSans().fontFamily,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Save Button
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // Save draft state to Provider
                      context.read<ShortcutProvider>().updateShortcuts(_draftShortcuts);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.activeGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: GoogleFonts.workSans().fontFamily,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
