class AppUser {
  final String id;
  final String? username;
  final String name;
  final String email;
  final String passwordHash;
  final String? photoUrl;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    this.username,
    required this.name,
    required this.email,
    this.passwordHash = '',
    this.photoUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'passwordHash': passwordHash,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      username: map['username'] as String?,
      name: map['name'] as String,
      email: map['email'] as String,
      passwordHash: (map['passwordHash'] as String?) ?? '',
      photoUrl: map['photoUrl'] as String?,
      createdAt:
          DateTime.tryParse((map['createdAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}
