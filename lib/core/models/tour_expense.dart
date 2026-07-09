import 'tour_expense_share.dart';

class TourExpense {
  final String id;
  final String tourId;
  final String title;
  final double amount;
  final String paidBy;
  final String splitType;
  final String? category;
  final String? note;
  final DateTime date;
  final String? receiptPath;
  final DateTime createdAt;
  final String syncStatus;
  final bool isDeleted;
  final DateTime lastModified;
  final List<TourExpenseShare>? shares;

  TourExpense({
    required this.id,
    required this.tourId,
    required this.title,
    required this.amount,
    required this.paidBy,
    this.splitType = 'equal',
    this.category,
    this.note,
    required this.date,
    this.receiptPath,
    DateTime? createdAt,
    this.syncStatus = 'synced',
    this.isDeleted = false,
    DateTime? lastModified,
    this.shares,
  }) : createdAt = createdAt ?? date,
       lastModified = lastModified ?? DateTime.now();

  TourExpense copyWith({
    String? id,
    String? tourId,
    String? title,
    double? amount,
    String? paidBy,
    String? splitType,
    String? category,
    String? note,
    DateTime? date,
    String? receiptPath,
    DateTime? createdAt,
    String? syncStatus,
    bool? isDeleted,
    DateTime? lastModified,
    List<TourExpenseShare>? shares,
  }) =>
      TourExpense(
        id: id ?? this.id,
        tourId: tourId ?? this.tourId,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        paidBy: paidBy ?? this.paidBy,
        splitType: splitType ?? this.splitType,
        category: category ?? this.category,
        note: note ?? this.note,
        date: date ?? this.date,
        receiptPath: receiptPath ?? this.receiptPath,
        createdAt: createdAt ?? this.createdAt,
        syncStatus: syncStatus ?? this.syncStatus,
        isDeleted: isDeleted ?? this.isDeleted,
        lastModified: lastModified ?? this.lastModified,
        shares: shares ?? this.shares,
      );

  Map<String, dynamic> toMap() => {
    'tourId': tourId,
    'title': title,
    'amount': amount,
    'paidBy': paidBy,
    'splitType': splitType,
    'category': category,
    'note': note,
    'date': date.toIso8601String(),
    'receiptPath': receiptPath,
    'createdAt': createdAt.toIso8601String(),
    if (shares != null)
      'shares': shares!.map((s) => s.toMap()).toList(),
  };

  factory TourExpense.fromMap(String id, Map<String, dynamic> map) {
    final shareMaps = (map['shares'] as List<dynamic>?)
        ?.cast<Map<String, dynamic>>();
    return TourExpense(
      id: id,
      tourId: map['tourId'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      paidBy: map['paidBy'] as String,
      splitType: map['splitType'] as String? ?? 'equal',
      category: map['category'] as String?,
      note: map['note'] as String?,
      date: DateTime.parse(map['date'] as String),
      receiptPath: map['receiptPath'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      shares: shareMaps
          ?.map((s) => TourExpenseShare.fromEmbeddedMap(s))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tourId': tourId,
    'title': title,
    'amount': amount,
    'paidBy': paidBy,
    'splitType': splitType,
    'category': category,
    'note': note,
    'date': date.toIso8601String(),
    'receiptPath': receiptPath,
    'createdAt': createdAt.toIso8601String(),
    'syncStatus': syncStatus,
    'isDeleted': isDeleted ? 1 : 0,
    'lastModified': lastModified.toIso8601String(),
  };

  factory TourExpense.fromJson(Map<String, dynamic> json) => TourExpense(
    id: json['id'] as String,
    tourId: json['tourId'] as String,
    title: json['title'] as String,
    amount: (json['amount'] as num).toDouble(),
    paidBy: json['paidBy'] as String,
    splitType: json['splitType'] as String? ?? 'equal',
    category: json['category'] as String?,
    note: json['note'] as String?,
    date: DateTime.parse(json['date'] as String),
    receiptPath: json['receiptPath'] as String?,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : null,
    syncStatus: json['syncStatus'] as String? ?? 'synced',
    isDeleted: (json['isDeleted'] as int? ?? 0) == 1,
    lastModified: json['lastModified'] != null
        ? DateTime.parse(json['lastModified'] as String)
        : DateTime.now(),
  );
}
