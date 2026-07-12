class AccountModel {
  final String id;
  final String name;
  final String type;
  final double initialBalance;
  final String createdAt;
  final String profileId;

  const AccountModel({
    required this.id,
    required this.name,
    required this.type,
    this.initialBalance = 0.0,
    required this.createdAt,
    this.profileId = 'default_profile',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'initialBalance': initialBalance,
        'createdAt': createdAt,
        'profileId': profileId,
      };

  factory AccountModel.fromJson(Map<String, dynamic> map) => AccountModel(
        id: map['id'] as String,
        name: map['name'] as String,
        type: map['type'] as String,
        initialBalance: (map['initialBalance'] as num?)?.toDouble() ?? 0.0,
        createdAt: map['createdAt'] as String,
        profileId: map['profileId'] as String? ?? 'default_profile',
      );
}
