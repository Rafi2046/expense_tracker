class Tour {
  final String id;
  final String name;
  final String? coverPhoto;
  final String currency;
  final DateTime createdAt;
  final String profileId;
  final String syncStatus;
  final bool isDeleted;
  final DateTime lastModified;

  Tour({
    required this.id,
    required this.name,
    this.coverPhoto,
    this.currency = 'USD',
    required this.createdAt,
    this.profileId = 'default_profile',
    this.syncStatus = 'synced',
    this.isDeleted = false,
    DateTime? lastModified,
  }) : lastModified = lastModified ?? createdAt;

  Tour copyWith({
    String? id,
    String? name,
    String? coverPhoto,
    String? currency,
    DateTime? createdAt,
    String? profileId,
    String? syncStatus,
    bool? isDeleted,
    DateTime? lastModified,
  }) =>
      Tour(
        id: id ?? this.id,
        name: name ?? this.name,
        coverPhoto: coverPhoto ?? this.coverPhoto,
        currency: currency ?? this.currency,
        createdAt: createdAt ?? this.createdAt,
        profileId: profileId ?? this.profileId,
        syncStatus: syncStatus ?? this.syncStatus,
        isDeleted: isDeleted ?? this.isDeleted,
        lastModified: lastModified ?? this.lastModified,
      );

  Map<String, dynamic> toMap() => {
    'name': name,
    'coverPhoto': coverPhoto,
    'currency': currency,
    'createdAt': createdAt.toIso8601String(),
    'profileId': profileId,
  };

  factory Tour.fromMap(String id, Map<String, dynamic> map) => Tour(
    id: id,
    name: map['name'] as String,
    coverPhoto: map['coverPhoto'] as String?,
    currency: map['currency'] as String? ?? 'USD',
    createdAt: DateTime.parse(map['createdAt'] as String),
    profileId: map['profileId'] as String? ?? 'default_profile',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'coverPhoto': coverPhoto,
    'currency': currency,
    'createdAt': createdAt.toIso8601String(),
    'profileId': profileId,
    'syncStatus': syncStatus,
    'isDeleted': isDeleted ? 1 : 0,
    'lastModified': lastModified.toIso8601String(),
  };

  factory Tour.fromJson(Map<String, dynamic> json) => Tour(
    id: json['id'] as String,
    name: json['name'] as String,
    coverPhoto: json['coverPhoto'] as String?,
    currency: json['currency'] as String? ?? 'USD',
    createdAt: DateTime.parse(json['createdAt'] as String),
    profileId: json['profileId'] as String? ?? 'default_profile',
    syncStatus: json['syncStatus'] as String? ?? 'synced',
    isDeleted: (json['isDeleted'] as int? ?? 0) == 1,
    lastModified: json['lastModified'] != null
        ? DateTime.parse(json['lastModified'] as String)
        : null,
  );
}
