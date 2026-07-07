import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/shortcut_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
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
      builder: (context) => const EditShortcutsSheet(),
    );
  }

  @override
  State<EditShortcutsSheet> createState() => _EditShortcutsSheetState();
}

class _EditShortcutsSheetState extends State<EditShortcutsSheet> {
  // Local working copy so Cancel can discard changes without touching the provider
  late List<ShortcutItem> _items;

  static const String _lockedId = 'add_party';

  @override
  void initState() {
    super.initState();
    _items = List.of(context.read<ShortcutProvider>().shortcuts);
  }

  Color _themeColor(String id) {
    switch (id) {
      case 'income':
        return const Color(0xFF16A34A);
      case 'expense':
        return const Color(0xFFDC2626);
      case 'payment_in':
        return const Color(0xFF2563EB);
      case 'payment_out':
        return const Color(0xFFEA580C);
      case 'add_party':
        return const Color(0xFF7C3AED);
      default:
        return AppColors.activeGreen;
    }
  }

  IconData _icon(String id) {
    switch (id) {
      case 'income':
        return Symbols.arrow_downward_rounded;
      case 'expense':
        return Symbols.arrow_upward_rounded;
      case 'payment_in':
      case 'payment_out':
        return Symbols.account_balance_wallet_rounded;
      case 'add_party':
        return Symbols.person_add_rounded;
      default:
        return Symbols.help_outline_rounded;
    }
  }

  void _save() {
    context.read<ShortcutProvider>().updateShortcuts(_items);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = Theme.of(context).cardColor;
    final rowBg = isDark
        ? Theme.of(context).cardColor.withValues(alpha: 0.5)
        : const Color(0xFFF7F7F5);
    final divider = Theme.of(context).dividerTheme.color ?? AppColors.dividerColor;

    // DraggableScrollableSheet রিমুভ করে সরাসরি Container দেওয়া হলো
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min, // ম্যাজিক: শিট এখন শুধু কন্টেন্ট অনুযায়ী সাইজ হবে
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.translate('edit_quick_actions'),
                    style: GoogleFonts.workSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.translate('drag_to_reorder_toggle_to_show'),
                    style: GoogleFonts.workSans(
                      fontSize: 12.5,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Flexible( // Expanded এর বদলে Flexible দেওয়া হলো যেন জোর করে বড় না হয়
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: rowBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: divider, width: 0.5),
                  ),
                  child: ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    itemCount: _items.length,
                    onReorder: (oldIndex, newIndex) {
                      if (oldIndex == 0) return;
                      setState(() {
                        if (newIndex > oldIndex) newIndex -= 1;
                        if (newIndex == 0) newIndex = 1;
                        final item = _items.removeAt(oldIndex);
                        _items.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final isLocked = item.id == _lockedId;
                      final isLast = index == _items.length - 1;
                      final themeColor = _themeColor(item.id);

                      return Container(
                        key: ValueKey(item.id),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          border: isLast
                              ? null
                              : Border(bottom: BorderSide(color: divider, width: 0.5)),
                        ),
                        child: Row(
                          children: [
                            isLocked
                                ? Icon(Symbols.drag_indicator, size: 18, color: Colors.grey.shade300)
                                : ReorderableDragStartListener(
                              index: index,
                              child: Icon(Symbols.drag_indicator, size: 18, color: Colors.grey.shade400),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: themeColor.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(_icon(item.id), size: 16, color: themeColor),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                context.translate(item.id),
                                style: GoogleFonts.workSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            if (isLocked)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  context.translate('always_on'),
                                  style: GoogleFonts.workSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              )
                            else
                              Checkbox(
                                value: item.isEnabled,
                                activeColor: AppColors.activeGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (checked) {
                                  setState(() {
                                    _items[index] = item.copyWith(isEnabled: checked ?? false);
                                  });
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              // নিচের বাটনের স্পেস কমানো হয়েছে (৪০ থেকে ২৪ করা হলো)
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        context.translate('cancel'),
                        style: GoogleFonts.workSans(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.activeGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text(
                        context.translate('save'),
                        style: GoogleFonts.workSans(fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}