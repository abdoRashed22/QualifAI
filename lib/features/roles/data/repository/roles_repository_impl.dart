import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/role_mapper.dart';
import '../../data/models/role_model.dart';
import '../../data/remote/roles_remote_ds.dart';
import '../../domain/repositories/roles_repository.dart';

class RolesRepositoryImpl implements RolesRepository {
  final RolesRemoteDs remoteDs;
  final _mapper = const RoleMapper();

  RolesRepositoryImpl(this.remoteDs);

  @override
  Future<Either<Failure, List<RoleModel>>> getRoles() async {
    try {
      final data = await remoteDs.getRoles();
      final roles = data
          .whereType<Map>()
          .map((e) => _mapper.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      return Right(roles);
    } catch (e) {
      return Left(e is Failure ? e : ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createRole(
      String name, String description) async {
    try {
      await remoteDs.createRole(name, description);
      return const Right(null);
    } catch (e) {
      return Left(e is Failure ? e : ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRole(int id) async {
    try {
      await remoteDs.deleteRole(id);
      return const Right(null);
    } catch (e) {
      return Left(e is Failure ? e : ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<int>>> fetchRolePermissions(int roleId) async {
    try {
      final ids = await remoteDs.fetchRolePermissions(roleId);
      return Right(ids);
    } catch (e) {
      return Left(e is Failure ? e : ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>?>> fetchRoleDetails(
      int roleId) async {
    try {
      final result = await remoteDs.fetchRoleDetails(roleId);
      return Right(result);
    } catch (e) {
      return Left(e is Failure ? e : ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> assignRolePermissions(
      int roleId, List<int> permissionIds) async {
    try {
      await remoteDs.assignRolePermissions(roleId, permissionIds);
      return const Right(null);
    } catch (e) {
      return Left(e is Failure ? e : ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getPermissions() async {
    try {
      final data = await remoteDs.getPermissions();
      return Right(data);
    } catch (e) {
      return Left(e is Failure ? e : ServerFailure(e.toString()));
    }
  }
}
