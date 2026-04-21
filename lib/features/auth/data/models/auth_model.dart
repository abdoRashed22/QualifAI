// lib/features/auth/data/models/auth_model.dart

class LoginRequestModel {
  final String email;
  final String password;

  const LoginRequestModel({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class ForgotPasswordModel {
  final String email;
  const ForgotPasswordModel({required this.email});
  Map<String, dynamic> toJson() => {'email': email};
}

class LoginResponseModel {
  final String token;
  final String firstName;
  final String lastName;
  final String email;
  final String role;

  const LoginResponseModel({
    required this.token,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['token'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
    );
  }
}
