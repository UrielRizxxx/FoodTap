class UserModel {
  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.isSeller,
    required this.isAdmin,
    required this.emailVerified,
    required this.createdAt,
    this.photoUrl,
  });

  final String uid;
  final String name;
  final String email;
  final String role;

  final bool isSeller;
  final bool isAdmin;

  final bool emailVerified;
  final DateTime createdAt;
  final String? photoUrl;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
      isSeller: map['isSeller'] ?? false,
      isAdmin: map['isAdmin'] ?? false,
      emailVerified: map['emailVerified'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      photoUrl: map['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'isSeller': isSeller,
      'isAdmin': isAdmin,
      'emailVerified': emailVerified,
      'createdAt': createdAt.toIso8601String(),
      'photoUrl': photoUrl,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    bool? isSeller,
    bool? isAdmin,
    bool? emailVerified,
    DateTime? createdAt,
    String? photoUrl,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isSeller: isSeller ?? this.isSeller,
      isAdmin: isAdmin ?? this.isAdmin,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}