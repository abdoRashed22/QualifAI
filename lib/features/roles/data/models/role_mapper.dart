import 'role_model.dart';

class RoleMapper {
  const RoleMapper();

  RoleModel fromJson(Map<String, dynamic> json) {
    final idRaw = json['id'] ?? json['roleId'] ?? 0;
    final id = idRaw is int ? idRaw : int.tryParse(idRaw.toString()) ?? 0;

    final roleName = (json['roleName'] ?? json['name'] ?? '').toString();
    final description =
        (json['description'] ?? json['roleDescription'] ?? '').toString();

    final employeesCountRaw = json['employeesCount'] ?? json['employees'] ?? 0;
    final employeesCount = employeesCountRaw is int
        ? employeesCountRaw
        : int.tryParse(employeesCountRaw.toString()) ?? 0;

    return RoleModel(
      id: id,
      roleName: roleName,
      description: description,
      employeesCount: employeesCount,
    );
  }
}
