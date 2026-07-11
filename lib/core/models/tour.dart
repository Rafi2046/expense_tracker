import 'dart:convert';

class Tour {
  final String id;
  final String name;
  final String? coverPhoto;
  final String currency;
  final DateTime createdAt;
  final String profileId;
  final String syncStatus;
  final bool isDeleted;
  final bool isCompleted;
  final DateTime lastModified;
  final String? inviteCode;
  final String? ownerUid;
  final List<String> memberUids;

  Tour({
    required this.id,
    required this.name,
    this.coverPhoto,
    this.currency = 'USD',
    required this.createdAt,
    this.profileId = 'default_profile',
    this.syncStatus = 'synced',
    this.isDeleted = false,
    this.isCompleted = false,
    DateTime? lastModified,
    this.inviteCode,
    this.ownerUid,
    List<String>? memberUids,
  })  : lastModified = lastModified ?? createdAt,
        memberUids = memberUids ?? [];

  Tour copyWith({
    String? id,
    String? name,
    String? coverPhoto,
    String? currency,
    DateTime? createdAt,
    String? profileId,
    String? syncStatus,
    bool? isDeleted,
    bool? isCompleted,
    DateTime? lastModified,
    String? inviteCode,
    String? ownerUid,
    List<String>? memberUids,
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
        isCompleted: isCompleted ?? this.isCompleted,
        lastModified: lastModified ?? this.lastModified,
        inviteCode: inviteCode ?? this.inviteCode,
        ownerUid: ownerUid ?? this.ownerUid,
        memberUids: memberUids ?? this.memberUids,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'coverPhoto': coverPhoto,
        'currency': currency,
        'createdAt': createdAt.toIso8601String(),
        'profileId': profileId,
        'inviteCode': inviteCode,
        'ownerUid': ownerUid,
        'memberUids': memberUids,
        'isCompleted': isCompleted,
        'lastModified': lastModified.toIso8601String(),
        'syncStatus': syncStatus,
        'isDeleted': isDeleted,
      };

  factory Tour.fromMap(String id, Map<String, dynamic> map) => Tour(
        id: id,
        name: map['name'] as String,
        coverPhoto: map['coverPhoto'] as String?,
        currency: map['currency'] as String? ?? 'USD',
        createdAt: DateTime.parse(map['createdAt'] as String),
        profileId: map['profileId'] as String? ?? 'default_profile',
        inviteCode: map['inviteCode'] as String?,
        ownerUid: map['ownerUid'] as String?,
        memberUids: map['memberUids'] != null
            ? List<String>.from(map['memberUids'] as List)
            : [],
        isCompleted: map['isCompleted'] == true,
        lastModified: map['lastModified'] != null
            ? DateTime.parse(map['lastModified'] as String)
            : null,
        syncStatus: map['syncStatus'] as String? ?? 'synced',
        isDeleted: map['isDeleted'] == true,
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
        'isCompleted': isCompleted ? 1 : 0,
        'lastModified': lastModified.toIso8601String(),
        'inviteCode': inviteCode,
        'ownerUid': ownerUid,
        'memberUids': jsonEncode(memberUids),
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
        isCompleted: (json['isCompleted'] as int? ?? 0) == 1,
        lastModified: json['lastModified'] != null
            ? DateTime.parse(json['lastModified'] as String)
            : null,
        inviteCode: json['inviteCode'] as String?,
        ownerUid: json['ownerUid'] as String?,
        memberUids: json['memberUids'] != null
            ? List<String>.from(jsonDecode(json['memberUids'] as String) as List)
            : [],
      );
}
