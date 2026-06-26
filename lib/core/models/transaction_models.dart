class TransactionItem {
  final String id;
  final double amount;
  final String category;
  final String note;
  final bool isIncome;
  final DateTime dateTime;
  final String? incomeMonth;
  final String paymentMethod; // 'Cash' or 'Bank'
  final DateTime lastModified;

  TransactionItem({
    required this.id,
    required this.amount,
    required this.category,
    required this.note,
    required this.isIncome,
    required this.dateTime,
    this.incomeMonth,
    this.paymentMethod = 'Cash',
    DateTime? lastModified,
  }) : lastModified = lastModified ?? dateTime;

  Map<String, dynamic> toMap() => {
    'amount': amount,
    'category': category,
    'note': note,
    'isIncome': isIncome,
    'dateTime': dateTime.toIso8601String(),
    'incomeMonth': incomeMonth,
    'paymentMethod': paymentMethod,
    'lastModified': lastModified.toIso8601String(),
  };

  factory TransactionItem.fromMap(String id, Map<String, dynamic> map) =>
      TransactionItem(
        id: id,
        amount: (map['amount'] as num).toDouble(),
        category: map['category'] as String,
        note: map['note'] as String? ?? '',
        isIncome: map['isIncome'] as bool,
        dateTime: DateTime.parse(map['dateTime'] as String),
        incomeMonth: map['incomeMonth'] as String?,
        paymentMethod: map['paymentMethod'] as String? ?? 'Cash',
        lastModified: map['lastModified'] != null
            ? DateTime.parse(map['lastModified'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'category': category,
    'note': note,
    'isIncome': isIncome ? 1 : 0,
    'dateTime': dateTime.toIso8601String(),
    'incomeMonth': incomeMonth,
    'paymentMethod': paymentMethod,
    'lastModified': lastModified.toIso8601String(),
  };

  factory TransactionItem.fromJson(Map<String, dynamic> json) =>
      TransactionItem(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        category: json['category'] as String,
        note: json['note'] as String? ?? '',
        isIncome: (json['isIncome'] as int) == 1,
        dateTime: DateTime.parse(json['dateTime'] as String),
        incomeMonth: json['incomeMonth'] as String?,
        paymentMethod: json['paymentMethod'] as String? ?? 'Cash',
        lastModified: json['lastModified'] != null
            ? DateTime.parse(json['lastModified'] as String)
            : null,
      );
}

class CategoryItem {
  final String id;
  final String name;
  final bool isIncome;
  final DateTime lastModified;

  CategoryItem({
    required this.id,
    required this.name,
    required this.isIncome,
    DateTime? lastModified,
  }) : lastModified = lastModified ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'name': name,
    'isIncome': isIncome,
    'lastModified': lastModified.toIso8601String(),
  };

  factory CategoryItem.fromMap(String id, Map<String, dynamic> map) =>
      CategoryItem(
        id: id,
        name: map['name'] as String,
        isIncome: map['isIncome'] as bool,
        lastModified: map['lastModified'] != null
            ? DateTime.parse(map['lastModified'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isIncome': isIncome ? 1 : 0,
    'lastModified': lastModified.toIso8601String(),
  };

  factory CategoryItem.fromJson(Map<String, dynamic> json) => CategoryItem(
    id: json['id'] as String,
    name: json['name'] as String,
    isIncome: (json['isIncome'] as int) == 1,
    lastModified: json['lastModified'] != null
        ? DateTime.parse(json['lastModified'] as String)
        : null,
  );
}
