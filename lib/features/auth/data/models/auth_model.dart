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

  final String roleName;

  final String action;

  final int? employeeId;

  const LoginResponseModel({
    required this.token,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.roleName,
    required this.action,
    this.employeeId,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    // Flexible parsing - handle multiple possible field names

    final token = json['token'] ??
        json['accessToken'] ??
        json['jwt'] ??
        json['Token'] ??
        '';

    final firstName =
        json['firstName'] ?? json['first_name'] ?? json['FirstName'] ?? '';

    final lastName =
        json['lastName'] ?? json['last_name'] ?? json['LastName'] ?? '';

    final email = json['email'] ?? json['Email'] ?? '';

    // Role can be a string, list, or numeric role ID

    String role = 'quality_employee';

    final rawRole = json['role'] ??
        json['roles'] ??
        json['userRole'] ??
        json['roleName'] ??
        json['roleId'] ??
        json['role_id'] ??
        json['id'];

    if (rawRole is String && rawRole.isNotEmpty) {
      role = rawRole;
    } else if (rawRole is int || rawRole is double) {
      role = rawRole.toString();
    } else if (rawRole is List && rawRole.isNotEmpty) {
      role = rawRole.first.toString();
    }

    final roleName =
        json['roleName'] ?? json['role_name'] ?? json['role'] ?? '';
    final action =
        json['action'] ?? json['permissionAction'] ?? json['scope'] ?? '';

    final rawEmployeeId =
        json['employeeId'] ?? json['employee_id'] ?? json['id'];
    int? employeeId;
    if (rawEmployeeId is int) {
      employeeId = rawEmployeeId;
    } else if (rawEmployeeId is String && rawEmployeeId.isNotEmpty) {
      employeeId = int.tryParse(rawEmployeeId);
    }

    return LoginResponseModel(
      token: token.toString(),
      firstName: firstName.toString(),
      lastName: lastName.toString(),
      email: email.toString(),
      role: role.toLowerCase(),
      roleName: roleName.toString(),
      action: action.toString(),
      employeeId: employeeId,
    );
  }
}
