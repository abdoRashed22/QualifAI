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
    // Flexible parsing - handle multiple possible field names
    final token = json['token'] ?? json['accessToken'] ?? json['jwt'] ?? json['Token'] ?? '';
    final firstName = json['firstName'] ?? json['first_name'] ?? json['FirstName'] ?? '';
    final lastName = json['lastName'] ?? json['last_name'] ?? json['LastName'] ?? '';
    final email = json['email'] ?? json['Email'] ?? '';

    // Role can be a string or a list
    String role = 'quality_employee';
    final rawRole = json['role'] ?? json['roles'] ?? json['userRole'] ?? json['roleName'];
    if (rawRole is String && rawRole.isNotEmpty) {
      role = rawRole;
    } else if (rawRole is List && rawRole.isNotEmpty) {
      role = rawRole.first.toString();
    }

    return LoginResponseModel(
      token: token.toString(),
      firstName: firstName.toString(),
      lastName: lastName.toString(),
      email: email.toString(),
      role: role.toLowerCase(),
    );
  }
}
