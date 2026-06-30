class TourParticipant {
  final String id;
  final String tourId;
  final String name;
  final int avatarColor;
  final DateTime joinedAt;
  final String? joinedExpenseId;
  final bool isActive;
  final String syncStatus;
  final bool isDeleted;
  final DateTime lastModified;

  TourParticipant({
    required this.id,
    required this.tourId,
    required this.name,
    this.avatarColor = 0,
    required this.joinedAt,
    this.joinedExpenseId,
    this.isActive = true,
    this.syncStatus = 'synced',
    this.isDeleted = false,
    DateTime? lastModified,
  }) : lastModified = lastModified ?? DateTime.now();

  TourParticipant copyWith({
    String? id,
    String? tourId,
    String? name,
    int? avatarColor,
    DateTime? joinedAt,
    String? joinedExpenseId,
    bool? isActive,
    String? syncStatus,
    bool? isDeleted,
    DateTime? lastModified,
  }) =>
      TourParticipant(
        id: id ?? this.id,
        tourId: tourId ?? this.tourId,
        name: name ?? this.name,
        avatarColor: avatarColor ?? this.avatarColor,
        joinedAt: joinedAt ?? this.joinedAt,
        joinedExpenseId: joinedExpenseId ?? this.joinedExpenseId,
        isActive: isActive ?? this.isActive,
        syncStatus: syncStatus ?? this.syncStatus,
        isDeleted: isDeleted ?? this.isDeleted,
        lastModified: lastModified ?? this.lastModified,
      );

  Map<String, dynamic> toMap() => {
    'tourId': tourId,
    'name': name,
    'avatarColor': avatarColor,
    'joinedAt': joinedAt.toIso8601String(),
    'joinedExpenseId': joinedExpenseId,
    'isActive': isActive,
  };

  factory TourParticipant.fromMap(String id, Map<String, dynamic> map) =>
      TourParticipant(
        id: id,
        tourId: map['tourId'] as String,
        name: map['name'] as String,
        avatarColor: map['avatarColor'] as int? ?? 0,
        joinedAt: DateTime.parse(map['joinedAt'] as String),
        joinedExpenseId: map['joinedExpenseId'] as String?,
        isActive: map['isActive'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'tourId': tourId,
    'name': name,
    'avatarColor': avatarColor,
    'joinedAt': joinedAt.toIso8601String(),
    'joinedExpenseId': joinedExpenseId,
    'isActive': isActive ? 1 : 0,
    'syncStatus': syncStatus,
    'isDeleted': isDeleted ? 1 : 0,
    'lastModified': lastModified.toIso8601String(),
  };

  factory TourParticipant.fromJson(Map<String, dynamic> json) =>
      TourParticipant(
        id: json['id'] as String,
        tourId: json['tourId'] as String,
        name: json['name'] as String,
        avatarColor: json['avatarColor'] as int? ?? 0,
        joinedAt: DateTime.parse(json['joinedAt'] as String),
        joinedExpenseId: json['joinedExpenseId'] as String?,
        isActive: (json['isActive'] as int? ?? 1) == 1,
        syncStatus: json['syncStatus'] as String? ?? 'synced',
        isDeleted: (json['isDeleted'] as int? ?? 0) == 1,
        lastModified: json['lastModified'] != null
            ? DateTime.parse(json['lastModified'] as String)
            : DateTime.now(),
      );
}
