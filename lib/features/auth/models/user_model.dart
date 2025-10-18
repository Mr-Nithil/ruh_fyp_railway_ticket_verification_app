class UserModel {
  final String uid;
  final String name;
  final String email;
  final String nic;
  final String checkerId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String postgresId;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.nic,
    required this.checkerId,
    required this.createdAt,
    this.updatedAt,
    required this.postgresId,
  });

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'nic': nic,
      'checkerId': checkerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'postgresId': postgresId,
    };
  }

  // Create UserModel from Firestore Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      nic: map['nic'] ?? '',
      checkerId: map['checkerId'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
      postgresId: map['postgresId'] ?? '',
    );
  }

  // CopyWith method for updates
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? nic,
    String? checkerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? postgresId,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      nic: nic ?? this.nic,
      checkerId: checkerId ?? this.checkerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      postgresId: postgresId ?? this.postgresId,
    );
  }
}
