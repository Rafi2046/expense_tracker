import 'package:material_symbols_icons/symbols.dart';
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
      backgroundColor: Colors.transparent,
      builder: (_) => const EditShortcutsSheet(),
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
              child: Icon(Symbols.account_balance_wallet, size: 20, color: activeGreen),
            ),
            Positioned(top: 0, child: Icon(Symbols.arrow_upward, size: 10, color: activeGreen)),
          ],
        );
      case 'income':
        return const Icon(Symbols.payments, size: 22, color: activeGreen);
      case 'expense':
        return const Icon(Symbols.account_balance_wallet, size: 22, color: activeGreen);
      case 'payment_in':
        return const Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 5.0),
              child: Icon(Symbols.account_balance_wallet, size: 20, color: activeGreen),
            ),
            Positioned(top: 0, child: Icon(Symbols.arrow_downward, size: 10, color: activeGreen)),
          ],
        );
      case 'add_party':
        return const Icon(Symbols.person_add, size: 22, color: activeGreen);
      default:
        return const Icon(Symbols.help_outline, size: 22, color: activeGreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          color: theme.colorScheme.surface,
          child: Padding(
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
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text(
            'Edit Quick Actions',
            style: GoogleFonts.workSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 16),

          Theme(
            data: theme.copyWith(canvasColor: Colors.transparent),
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: _draftShortcuts.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) newIndex -= 1;
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
                    color: isDark
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.06)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? theme.dividerColor
                          : Colors.grey.shade100,
                    ),
                  ),
                  child: Row(
                    children: [
                      ReorderableDragStartListener(
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          child: Icon(
                            Symbols.drag_indicator_rounded,
                            color: theme.textTheme.bodySmall?.color,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F8F5),
                          shape: BoxShape.circle,
                        ),
                        child: Center(child: _buildShortcutIcon(item.id)),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          item.label,
                          style: GoogleFonts.workSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: theme.textTheme.titleMedium?.color,
                          ),
                        ),
                      ),

                      if (item.id == 'add_party')
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14.0),
                          child: Icon(Symbols.lock_rounded, color: AppColors.activeGreen, size: 20),
                        )
                      else
                        Checkbox(
                          value: item.isEnabled,
                          activeColor: AppColors.activeGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          side: BorderSide(
                            color: theme.dividerColor,
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

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.dividerColor, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: theme.colorScheme.surface,
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.workSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
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
                      style: GoogleFonts.workSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    ),
  ),
);
  }
}
