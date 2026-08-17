import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/role_model.dart';

abstract class RolesRepository {
  Future<Either<Failure, List<RoleModel>>> getRoles();
  Future<Either<Failure, void>> createRole(String name, String description);
  Future<Either<Failure, void>> deleteRole(int id);
  Future<Either<Failure, List<int>>> fetchRolePermissions(int roleId);
  Future<Either<Failure, Map<String, dynamic>?>> fetchRoleDetails(int roleId);
  Future<Either<Failure, void>> assignRolePermissions(
      int roleId, List<int> permissionIds);
  Future<Either<Failure, List<dynamic>>> getPermissions();
}
