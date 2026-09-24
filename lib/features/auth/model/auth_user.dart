class AuthUser {
  final String id;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String role;
  final String audience;
  final String? tenantId;
  final String? tenantSlug;

  AuthUser({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.audience,
    this.tenantId,
    this.tenantSlug,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'].toString(),
        email: json['email'] as String,
        role: json['role'] as String,
        username: json['username'] as String,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String,
        audience: json['audience'] as String,
        tenantId: json['tenant_id'] as String?,
        tenantSlug: json['tenant_slug'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'role': role,
        'username': username,
        'audience': audience,
        'first_name': firstName,
        'last_name': lastName,
        'tenant_id': tenantId,
        'tenant_slug': tenantSlug,
      };
}
