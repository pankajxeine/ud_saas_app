import 'auth_user.dart';

class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final AuthUser user;
  final String expiresIn;

  LoginResponse(
      {required this.accessToken,
      required this.refreshToken,
      required this.user,
      required this.expiresIn});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        user: AuthUser.fromJson(
          Map<String, dynamic>.from(json['user'] as Map),
        ),
        expiresIn: json['expiresIn'] as String,
      );

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'user': user.toJson(),
        'expiresIn': expiresIn,
      };
}
