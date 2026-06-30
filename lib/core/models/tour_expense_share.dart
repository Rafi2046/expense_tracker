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

  factory TourExpenseShare.fromJson(Map<String, dynamic> json) =>
      TourExpenseShare(
        id: json['id'] as String,
        expenseId: json['expenseId'] as String,
        participantId: json['participantId'] as String,
        shareAmount: (json['shareAmount'] as num).toDouble(),
        customValue: (json['customValue'] as num?)?.toDouble(),
        isExcluded: (json['isExcluded'] as int? ?? 0) == 1,
        syncStatus: json['syncStatus'] as String? ?? 'synced',
        isDeleted: (json['isDeleted'] as int? ?? 0) == 1,
        lastModified: json['lastModified'] != null
            ? DateTime.parse(json['lastModified'] as String)
            : DateTime.now(),
      );
}
