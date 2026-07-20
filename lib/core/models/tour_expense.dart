import 'dart:convert';
import 'tour_expense_share.dart';

class TourExpense {
  final String id;
  final String tourId;
  final String title;
  final double amount;
  final Map<String, double> paidBy;
  final String splitType;
  final String? category;
  final String? note;
  final DateTime date;
  final List<String> receiptPaths;
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
    this.receiptPaths = const [],
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
    Map<String, double>? paidBy,
    String? splitType,
    String? category,
    String? note,
    DateTime? date,
    List<String>? receiptPaths,
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
        receiptPaths: receiptPaths ?? this.receiptPaths,
        createdAt: createdAt ?? this.createdAt,
        syncStatus: syncStatus ?? this.syncStatus,
        isDeleted: isDeleted ?? this.isDeleted,
        lastModified: lastModified ?? this.lastModified,
        shares: shares ?? this.shares,
      );

  static Map<String, double> _parsePaidBy(dynamic raw, double amount) {
    if (raw == null) {
      return <String, double>{};
    }
    if (raw is Map) {
      return raw.map<String, double>((k, v) => MapEntry(k.toString(), (v as num).toDouble()));
    }
    if (raw is String) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) return <String, double>{};
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map) {
          return decoded.map<String, double>((k, v) => MapEntry(k.toString(), (v as num).toDouble()));
        }
        return <String, double>{trimmed: amount};
      } catch (_) {
        return <String, double>{trimmed: amount};
      }
    }
    return <String, double>{};
  }

  static String? _encodeReceiptPaths(List<String> paths) {
    if (paths.isEmpty) return null;
    return jsonEncode(paths);
  }

  static List<String> _decodeReceiptPaths(dynamic raw) {
    if (raw == null) return [];
    final s = raw.toString();
    if (s.isEmpty) return [];
    if (s.startsWith('[')) {
      try {
        final decoded = jsonDecode(s);
        if (decoded is List) return decoded.cast<String>();
      } catch (_) {}
    }
    return [s];
  }

  Map<String, dynamic> toMap() => {
    'tourId': tourId,
    'title': title,
    'amount': amount,
    'paidBy': jsonEncode(paidBy),
    'splitType': splitType,
    'category': category,
    'note': note,
    'date': date.toIso8601String(),
    'receiptPath': _encodeReceiptPaths(receiptPaths),
    'createdAt': createdAt.toIso8601String(),
    'isDeleted': isDeleted,
    'lastModified': lastModified.toIso8601String(),
    if (shares != null)
      'shares': shares!.map((s) => s.toMap()).toList(),
  };

  factory TourExpense.fromMap(String id, Map<String, dynamic> map) {
    final shareMaps = (map['shares'] as List<dynamic>?)
        ?.cast<Map<String, dynamic>>();
    final amount = (map['amount'] as num).toDouble();
    return TourExpense(
      id: id,
      tourId: map['tourId'] as String,
      title: map['title'] as String,
      amount: amount,
      paidBy: _parsePaidBy(map['paidBy'], amount),
      splitType: map['splitType'] as String? ?? 'equal',
      category: map['category'] as String?,
      note: map['note'] as String?,
      date: DateTime.parse(map['date'] as String),
      receiptPaths: _decodeReceiptPaths(map['receiptPath']),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      isDeleted: map['isDeleted'] == true,
      lastModified: map['lastModified'] != null
          ? DateTime.parse(map['lastModified'] as String)
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
    'paidBy': jsonEncode(paidBy),
    'splitType': splitType,
    'category': category,
    'note': note,
    'date': date.toIso8601String(),
    'receiptPath': _encodeReceiptPaths(receiptPaths),
    'createdAt': createdAt.toIso8601String(),
    'syncStatus': syncStatus,
    'isDeleted': isDeleted ? 1 : 0,
    'lastModified': lastModified.toIso8601String(),
  };

  factory TourExpense.fromJson(Map<String, dynamic> json) {
    final amount = (json['amount'] as num).toDouble();
    return TourExpense(
      id: json['id'] as String,
      tourId: json['tourId'] as String,
      title: json['title'] as String,
      amount: amount,
      paidBy: _parsePaidBy(json['paidBy'], amount),
      splitType: json['splitType'] as String? ?? 'equal',
      category: json['category'] as String?,
      note: json['note'] as String?,
      date: DateTime.parse(json['date'] as String),
      receiptPaths: _decodeReceiptPaths(json['receiptPath']),
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
}
