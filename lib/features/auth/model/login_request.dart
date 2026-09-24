class LoginRequest {
  final String email;
  final String password;
  final String audience;

  LoginRequest({
    required this.email,
    required this.password,
    required this.audience,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
        email: json['email'] as String,
        password: json['password'] as String,
        audience: json['audience'] as String,
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'audience': audience,
      };
}
