class RegisterRequest {
  final String email;
  final String password;

  RegisterRequest({
    required this.email,
    required this.password,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => RegisterRequest(
    email: json['email'] as String,
    password: json['password'] as String,
  );

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}
