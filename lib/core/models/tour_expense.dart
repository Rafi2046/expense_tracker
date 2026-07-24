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
      return raw.map<String, double>(
        (k, v) => MapEntry(k.toString(), _parseAmount(v)),
      );
    }
    if (raw is String) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) return <String, double>{};
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map) {
          return decoded.map<String, double>(
            (k, v) => MapEntry(k.toString(), _parseAmount(v)),
          );
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
    if (raw is List) {
      return raw
          .map((e) => e.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    final s = raw.toString().trim();
    if (s.isEmpty) return [];
    if (s.startsWith('[')) {
      try {
        final decoded = jsonDecode(s);
        if (decoded is List) {
          return decoded
              .map((e) => e.toString().trim())
              .where((s) => s.isNotEmpty)
              .toList();
        }
      } catch (_) {}
    }
    return [s];
  }

  static bool _parseBoolFlag(dynamic raw) {
    if (raw == true || raw == 1) return true;
    if (raw == false || raw == 0 || raw == null) return false;
    if (raw is String) {
      final s = raw.trim().toLowerCase();
      return s == '1' || s == 'true';
    }
    return false;
  }

  static DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    try {
      return DateTime.parse(raw.toString());
    } catch (_) {
      return null;
    }
  }

  static double _parseAmount(dynamic raw) {
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw?.toString() ?? '') ?? 0.0;
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
    List<TourExpenseShare>? shares;
    final rawShares = map['shares'];
    if (rawShares is List) {
      shares = [];
      for (final item in rawShares) {
        if (item is! Map) continue;
        try {
          shares.add(
            TourExpenseShare.fromEmbeddedMap(
              item.map((k, v) => MapEntry(k.toString(), v)),
            ),
          );
        } catch (_) {}
      }
    }

    final amount = _parseAmount(map['amount']);
    final date = _parseDate(map['date']) ?? DateTime.now();
    return TourExpense(
      id: id,
      tourId: (map['tourId'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      amount: amount,
      paidBy: _parsePaidBy(map['paidBy'], amount),
      splitType: (map['splitType'] ?? 'equal').toString(),
      category: map['category']?.toString(),
      note: map['note']?.toString(),
      date: date,
      receiptPaths: _decodeReceiptPaths(
        map['receiptPath'] ?? map['receiptPaths'],
      ),
      createdAt: _parseDate(map['createdAt']),
      isDeleted: _parseBoolFlag(map['isDeleted']),
      lastModified: _parseDate(map['lastModified']),
      shares: shares,
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
    final amount = _parseAmount(json['amount']);
    final date = _parseDate(json['date']) ?? DateTime.now();
    return TourExpense(
      id: (json['id'] ?? '').toString(),
      tourId: (json['tourId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      amount: amount,
      paidBy: _parsePaidBy(json['paidBy'], amount),
      splitType: (json['splitType'] ?? 'equal').toString(),
      category: json['category']?.toString(),
      note: json['note']?.toString(),
      date: date,
      receiptPaths: _decodeReceiptPaths(
        json['receiptPath'] ?? json['receiptPaths'],
      ),
      createdAt: _parseDate(json['createdAt']),
      syncStatus: (json['syncStatus'] ?? 'synced').toString(),
      isDeleted: _parseBoolFlag(json['isDeleted']),
      lastModified: _parseDate(json['lastModified']) ?? DateTime.now(),
    );
  }
}
