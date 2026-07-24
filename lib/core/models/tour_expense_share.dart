class TourExpenseShare {
  final String id;
  final String expenseId;
  final String participantId;
  final double shareAmount;
  final double? customValue;
  final bool isExcluded;
  final String syncStatus;
  final bool isDeleted;
  final DateTime lastModified;

  TourExpenseShare({
    required this.id,
    required this.expenseId,
    required this.participantId,
    required this.shareAmount,
    this.customValue,
    this.isExcluded = false,
    this.syncStatus = 'synced',
    this.isDeleted = false,
    DateTime? lastModified,
  }) : lastModified = lastModified ?? DateTime.now();

  TourExpenseShare copyWith({
    String? id,
    String? expenseId,
    String? participantId,
    double? shareAmount,
    double? customValue,
    bool? isExcluded,
    String? syncStatus,
    bool? isDeleted,
    DateTime? lastModified,
  }) =>
      TourExpenseShare(
        id: id ?? this.id,
        expenseId: expenseId ?? this.expenseId,
        participantId: participantId ?? this.participantId,
        shareAmount: shareAmount ?? this.shareAmount,
        customValue: customValue ?? this.customValue,
        isExcluded: isExcluded ?? this.isExcluded,
        syncStatus: syncStatus ?? this.syncStatus,
        isDeleted: isDeleted ?? this.isDeleted,
        lastModified: lastModified ?? this.lastModified,
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'expenseId': expenseId,
    'participantId': participantId,
    'shareAmount': shareAmount,
    'customValue': customValue,
    'isExcluded': isExcluded,
  };

  factory TourExpenseShare.fromMap(String id, Map<String, dynamic> map) =>
      TourExpenseShare(
        id: id,
        expenseId: map['expenseId'] as String,
        participantId: map['participantId'] as String,
        shareAmount: (map['shareAmount'] as num).toDouble(),
        customValue: (map['customValue'] as num?)?.toDouble(),
        isExcluded: map['isExcluded'] as bool? ?? false,
      );

  /// Parses a share embedded within an expense document (id is read from the map).
  factory TourExpenseShare.fromEmbeddedMap(Map<String, dynamic> map) =>
      TourExpenseShare(
        id: (map['id'] ?? '').toString(),
        expenseId: (map['expenseId'] ?? '').toString(),
        participantId: (map['participantId'] ?? '').toString(),
        shareAmount: (map['shareAmount'] is num)
            ? (map['shareAmount'] as num).toDouble()
            : double.tryParse('${map['shareAmount']}') ?? 0.0,
        customValue: map['customValue'] is num
            ? (map['customValue'] as num).toDouble()
            : double.tryParse('${map['customValue']}'),
        isExcluded: map['isExcluded'] == true ||
            map['isExcluded'] == 1 ||
            map['isExcluded']?.toString() == '1',
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'expenseId': expenseId,
    'participantId': participantId,
    'shareAmount': shareAmount,
    'customValue': customValue,
    'isExcluded': isExcluded ? 1 : 0,
    'syncStatus': syncStatus,
    'isDeleted': isDeleted ? 1 : 0,
    'lastModified': lastModified.toIso8601String(),
  };

  factory TourExpenseShare.fromJson(Map<String, dynamic> json) {
    bool flag(dynamic raw) =>
        raw == true || raw == 1 || raw?.toString() == '1' || raw?.toString() == 'true';

    return TourExpenseShare(
      id: (json['id'] ?? '').toString(),
      expenseId: (json['expenseId'] ?? '').toString(),
      participantId: (json['participantId'] ?? '').toString(),
      shareAmount: (json['shareAmount'] is num)
          ? (json['shareAmount'] as num).toDouble()
          : double.tryParse('${json['shareAmount']}') ?? 0.0,
      customValue: json['customValue'] is num
          ? (json['customValue'] as num).toDouble()
          : double.tryParse('${json['customValue']}'),
      isExcluded: flag(json['isExcluded']),
      syncStatus: json['syncStatus'] as String? ?? 'synced',
      isDeleted: flag(json['isDeleted']),
      lastModified: json['lastModified'] != null
          ? DateTime.tryParse(json['lastModified'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
