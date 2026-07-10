import 'permission_model.dart';

class PermissionMapper {
  const PermissionMapper();

  PermissionModel fromJson(Map<String, dynamic> json) {
    final idRaw = json['id'] ?? json['permissionId'] ?? 0;
    final id = idRaw is int ? idRaw : int.tryParse(idRaw.toString()) ?? 0;

    final name = (json['name'] ?? json['permissionName'] ?? '').toString();
    final description = (json['description'] ?? '').toString();

    return PermissionModel(
      id: id,
      name: name,
      description: description,
    );
  }
}
