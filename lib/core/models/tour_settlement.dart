class TourSettlement {
  final String id;
  final String tourId;
  final String fromParticipant;
  final String toParticipant;
  final double amount;
  final DateTime date;
  final String? note;
  final String syncStatus;
  final bool isDeleted;
  final DateTime lastModified;

  TourSettlement({
    required this.id,
    required this.tourId,
    required this.fromParticipant,
    required this.toParticipant,
    required this.amount,
    required this.date,
    this.note,
    this.syncStatus = 'synced',
    this.isDeleted = false,
    DateTime? lastModified,
  }) : lastModified = lastModified ?? DateTime.now();

  TourSettlement copyWith({
    String? id,
    String? tourId,
    String? fromParticipant,
    String? toParticipant,
    double? amount,
    DateTime? date,
    String? note,
    String? syncStatus,
    bool? isDeleted,
    DateTime? lastModified,
  }) =>
      TourSettlement(
        id: id ?? this.id,
        tourId: tourId ?? this.tourId,
        fromParticipant: fromParticipant ?? this.fromParticipant,
        toParticipant: toParticipant ?? this.toParticipant,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        note: note ?? this.note,
        syncStatus: syncStatus ?? this.syncStatus,
        isDeleted: isDeleted ?? this.isDeleted,
        lastModified: lastModified ?? this.lastModified,
      );

  Map<String, dynamic> toMap() => {
    'tourId': tourId,
    'fromParticipant': fromParticipant,
    'toParticipant': toParticipant,
    'amount': amount,
    'date': date.toIso8601String(),
    'note': note,
  };

  factory TourSettlement.fromMap(String id, Map<String, dynamic> map) =>
      TourSettlement(
        id: id,
        tourId: map['tourId'] as String,
        fromParticipant: map['fromParticipant'] as String,
        toParticipant: map['toParticipant'] as String,
        amount: (map['amount'] as num).toDouble(),
        date: DateTime.parse(map['date'] as String),
        note: map['note'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'tourId': tourId,
    'fromParticipant': fromParticipant,
    'toParticipant': toParticipant,
    'amount': amount,
    'date': date.toIso8601String(),
    'note': note,
    'syncStatus': syncStatus,
    'isDeleted': isDeleted ? 1 : 0,
    'lastModified': lastModified.toIso8601String(),
  };

  factory TourSettlement.fromJson(Map<String, dynamic> json) =>
      TourSettlement(
        id: json['id'] as String,
        tourId: json['tourId'] as String,
        fromParticipant: json['fromParticipant'] as String,
        toParticipant: json['toParticipant'] as String,
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
        note: json['note'] as String?,
        syncStatus: json['syncStatus'] as String? ?? 'synced',
        isDeleted: (json['isDeleted'] as int? ?? 0) == 1,
        lastModified: json['lastModified'] != null
            ? DateTime.parse(json['lastModified'] as String)
            : DateTime.now(),
      );
}
