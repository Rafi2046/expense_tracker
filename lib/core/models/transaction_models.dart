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
  final String profileId;
  final String? partyName;

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
    this.profileId = 'default_profile',
    this.partyName,
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
    'profileId': profileId,
    'partyName': partyName,
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
        profileId: map['profileId'] as String? ?? 'default_profile',
        partyName: map['partyName'] as String?,
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
    'profileId': profileId,
    'partyName': partyName,
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
        profileId: json['profileId'] as String? ?? 'default_profile',
        partyName: json['partyName'] as String?,
      );

  static List<TransactionItem> dummyList() {
    final now = DateTime.now();
    final categories = ['Food', 'Transport', 'Shopping', 'Entertainment', 'Bills', 'Income'];
    final amounts = [250.0, 1200.0, 850.0, 450.0, 3000.0, 1500.0];
    final notes = ['Lunch', 'Bus fare', 'New shoes', 'Movie night', 'Electricity bill', 'Monthly Salary'];
    final incomes = [false, false, false, false, false, true];

    return List.generate(6, (i) {
      return TransactionItem(
        id: 'skeleton_$i',
        amount: amounts[i],
        category: categories[i],
        note: notes[i],
        isIncome: incomes[i],
        dateTime: now.subtract(Duration(days: i)),
        paymentMethod: i.isEven ? 'Cash' : 'Bank',
        partyName: i == 4 ? 'Rafi' : null,
      );
    });
  }
}

class CategoryItem {
  final String id;
  final String name;
  final bool isIncome;
  final DateTime lastModified;
  final String profileId;

  CategoryItem({
    required this.id,
    required this.name,
    required this.isIncome,
    DateTime? lastModified,
    this.profileId = 'default_profile',
  }) : lastModified = lastModified ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'name': name,
    'isIncome': isIncome,
    'lastModified': lastModified.toIso8601String(),
    'profileId': profileId,
  };

  factory CategoryItem.fromMap(String id, Map<String, dynamic> map) =>
      CategoryItem(
        id: id,
        name: map['name'] as String,
        isIncome: map['isIncome'] as bool,
        lastModified: map['lastModified'] != null
            ? DateTime.parse(map['lastModified'] as String)
            : null,
        profileId: map['profileId'] as String? ?? 'default_profile',
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isIncome': isIncome ? 1 : 0,
    'lastModified': lastModified.toIso8601String(),
    'profileId': profileId,
  };

  factory CategoryItem.fromJson(Map<String, dynamic> json) => CategoryItem(
    id: json['id'] as String,
    name: json['name'] as String,
    isIncome: (json['isIncome'] as int) == 1,
    lastModified: json['lastModified'] != null
        ? DateTime.parse(json['lastModified'] as String)
        : null,
    profileId: json['profileId'] as String? ?? 'default_profile',
  );
}
