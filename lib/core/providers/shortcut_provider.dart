import 'package:flutter/material.dart';

class ShortcutItem {
  final String id;
  final String label;
  final bool isEnabled;

  ShortcutItem({
    required this.id,
    required this.label,
    this.isEnabled = true,
  });

  ShortcutItem copyWith({
    String? id,
    String? label,
    bool? isEnabled,
  }) {
    return ShortcutItem(
      id: id ?? this.id,
      label: label ?? this.label,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

class ShortcutProvider extends ChangeNotifier {
  List<ShortcutItem> _shortcuts = [
    ShortcutItem(id: 'add_party', label: 'Add Party', isEnabled: true),
    ShortcutItem(id: 'payment_out', label: 'Payment Out'),
    ShortcutItem(id: 'income', label: 'Income'),
    ShortcutItem(id: 'expense', label: 'Daily Expense'),
    ShortcutItem(id: 'payment_in', label: 'Payment In'),
  ];

  List<ShortcutItem> get shortcuts => List.unmodifiable(_shortcuts);

  List<ShortcutItem> get activeShortcuts =>
      _shortcuts.where((item) => item.id == 'add_party' || item.isEnabled).toList();

  void updateShortcuts(List<ShortcutItem> updatedList) {
    _shortcuts = updatedList.map((item) {
      if (item.id == 'add_party') {
        return item.copyWith(isEnabled: true);
      }
      return item;
    }).toList();
    notifyListeners();
  }
}
