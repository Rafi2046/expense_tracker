import 'package:flutter/material.dart';

class DebtItem {
  final String id;
  final String name;
  final String detail;
  final double amount;
  final bool isReceive; // true = To Receive, false = To Give
  final bool isSettled;
  final DateTime createdAt;

  DebtItem({
    required this.id,
    required this.name,
    required this.detail,
    required this.amount,
    required this.isReceive,
    this.isSettled = false,
    required this.createdAt,
  });

  DebtItem copyWith({
    String? id,
    String? name,
    String? detail,
    double? amount,
    bool? isReceive,
    bool? isSettled,
    DateTime? createdAt,
  }) {
    return DebtItem(
      id: id ?? this.id,
      name: name ?? this.name,
      detail: detail ?? this.detail,
      amount: amount ?? this.amount,
      isReceive: isReceive ?? this.isReceive,
      isSettled: isSettled ?? this.isSettled,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class DebtProvider extends ChangeNotifier {
  final List<DebtItem> _items = [
    // To Receive items
    DebtItem(
      id: 'r1',
      name: 'Julian Smith',
      detail: 'KFC Split • Lunch',
      amount: 42.00,
      isReceive: true,
      isSettled: false,
      createdAt: DateTime.now(),
    ),
    DebtItem(
      id: 'r2',
      name: 'Marcus Aurelius',
      detail: 'Office Rent • July',
      amount: 850.00,
      isReceive: true,
      isSettled: false,
      createdAt: DateTime.now(),
    ),
    DebtItem(
      id: 'r3',
      name: 'Elena White',
      detail: 'Concert Tickets',
      amount: 128.50,
      isReceive: true,
      isSettled: false,
      createdAt: DateTime.now(),
    ),
    DebtItem(
      id: 'r4',
      name: 'David Chen',
      detail: 'Grocery Run',
      amount: 400.00,
      isReceive: true,
      isSettled: false,
      createdAt: DateTime.now(),
    ),

    // To Give items
    DebtItem(
      id: 'g1',
      name: 'James Dalton',
      detail: 'Uber Ride to Airport',
      amount: 42.50,
      isReceive: false,
      isSettled: false,
      createdAt: DateTime.now(),
    ),
    DebtItem(
      id: 'g2',
      name: 'Sarah Chen',
      detail: 'Dinner at Le Petit',
      amount: 128.00,
      isReceive: false,
      isSettled: false,
      createdAt: DateTime.now(),
    ),
    DebtItem(
      id: 'g3',
      name: 'Marcus King',
      detail: 'Concert Tickets',
      amount: 250.00,
      isReceive: false,
      isSettled: false,
      createdAt: DateTime.now(),
    ),
    DebtItem(
      id: 'g4',
      name: 'Anna Lopez',
      detail: 'Shared Groceries',
      amount: 85.30,
      isReceive: false,
      isSettled: false,
      createdAt: DateTime.now(),
    ),
    DebtItem(
      id: 'g5',
      name: 'Robert Taylor',
      detail: 'Electric Bill Split',
      amount: 947.00,
      isReceive: false,
      isSettled: false,
      createdAt: DateTime.now(),
    ),
  ];

  List<DebtItem> get items => List.unmodifiable(_items);

  // Getters for To Receive
  List<DebtItem> get toReceiveUnpaid => _items.where((i) => i.isReceive && !i.isSettled).toList();
  List<DebtItem> get toReceiveSettled => _items.where((i) => i.isReceive && i.isSettled).toList();
  double get totalToReceive => toReceiveUnpaid.fold(0.0, (sum, i) => sum + i.amount);

  // Getters for To Give
  List<DebtItem> get toGiveUnpaid => _items.where((i) => !i.isReceive && !i.isSettled).toList();
  List<DebtItem> get toGiveSettled => _items.where((i) => !i.isReceive && i.isSettled).toList();
  double get totalToGive => toGiveUnpaid.fold(0.0, (sum, i) => sum + i.amount);

  void addDebtItem(DebtItem item) {
    _items.insert(0, item);
    notifyListeners();
  }

  void settleDebtItem(String id) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(isSettled: true);
      notifyListeners();
    }
  }

  void toggleSettledStatus(String id) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(isSettled: !_items[index].isSettled);
      notifyListeners();
    }
  }

  void deleteDebtItem(String id) {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
  }
}
