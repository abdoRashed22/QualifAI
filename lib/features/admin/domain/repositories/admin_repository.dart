// lib/features/admin/domain/repositories/admin_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class AdminRepository {
  Future<Either<Failure, List<dynamic>>> getEmployees();
  Future<Either<Failure, void>> createEmployee(Map<String, dynamic> data);
  Future<Either<Failure, void>> updateEmployee(int id, Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteEmployee(int id);
  Future<Either<Failure, List<dynamic>>> getRoles();
  Future<Either<Failure, void>> createRole(String name, String description);
  Future<Either<Failure, void>> deleteRole(int id);
  Future<Either<Failure, List<dynamic>>> getPermissions();
  Future<Either<Failure, void>> setRolePermissions(int roleId, List<int> permIds);
  Future<Either<Failure, List<dynamic>>> getColleges();
  Future<Either<Failure, void>> deleteCollege(int id);
  Future<Either<Failure, List<dynamic>>> getPlans();
  Future<Either<Failure, List<dynamic>>> getActivityLog();
}
