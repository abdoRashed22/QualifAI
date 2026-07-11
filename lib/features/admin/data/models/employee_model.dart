import 'package:equatable/equatable.dart';

class EmployeeModel extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String role;
  final String profileImage;

  const EmployeeModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    required this.role,
    required this.profileImage,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id'] ?? json['employeeId'] ?? 0;
    final id = idRaw is int ? idRaw : int.tryParse(idRaw.toString()) ?? 0;

    final firstName =
        (json['firstName'] ?? json['first_name'] ?? json['name'] ?? '')
            .toString();
    final lastName = (json['lastName'] ?? json['last_name'] ?? '').toString();
    final fullName = (json['fullName'] ?? json['full_name'] ?? '').toString();
    final email = (json['email'] ?? json['userEmail'] ?? json['userName'] ?? '')
        .toString();
    final role =
        (json['role'] ?? json['roleName'] ?? json['roleDisplayName'] ?? 'موظف')
            .toString();
    final profileImage = (json['profileImage'] ??
            json['image'] ??
            json['photo'] ??
            json['avatarUrl'] ??
            '')
        .toString();

    return EmployeeModel(
      id: id,
      firstName: firstName,
      lastName: lastName,
      fullName: fullName.isNotEmpty ? fullName : '$firstName $lastName'.trim(),
      email: email,
      role: role,
      profileImage: profileImage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'email': email,
      'role': role,
      'profileImage': profileImage,
    };
  }

  EmployeeModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? fullName,
    String? email,
    String? role,
    String? profileImage,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        fullName,
        email,
        role,
        profileImage,
      ];
}
