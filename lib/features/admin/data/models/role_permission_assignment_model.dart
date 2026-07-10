class RolePermissionAssignmentModel {
  final int roleId;
  final List<int> permissionIds;

  const RolePermissionAssignmentModel({
    required this.roleId,
    required this.permissionIds,
  });
}
