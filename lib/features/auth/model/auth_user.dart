class AuthUser {
  final String id;
  final String email;
  final String username;
  final String? fullName;
  final String? role;

  AuthUser({
    required this.id,
    required this.email,
    required this.username,
    this.fullName,
    this.role,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'].toString(),
    email: json['email'] as String,
    role: json['role'] as String?,
    username: json['username'] as String,
    fullName: json['full_name'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'role': role,
    'username': username,
    'fullName': fullName,
  };
}
