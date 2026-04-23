// lib/features/admin/repository/admin_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../data/remote/admin_remote_ds.dart';
import '../domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDs _r;
  const AdminRepositoryImpl(this._r);

  Either<Failure, T> _wrap<T>(T val) => Right(val);
  Either<Failure, T> _err<T>(Object e) => e is Failure ? Left(e) : Left(const UnknownFailure());

  @override Future<Either<Failure, List<dynamic>>> getEmployees() async {
    try { return _wrap(await _r.getEmployees()); } catch(e) { return _err(e); }
  }
  @override Future<Either<Failure, void>> createEmployee(Map<String, dynamic> d) async {
    try { await _r.createEmployee(d); return const Right(null); } catch(e) { return _err(e); }
  }
  @override Future<Either<Failure, void>> updateEmployee(int id, Map<String, dynamic> d) async {
    try { await _r.updateEmployee(id, d); return const Right(null); } catch(e) { return _err(e); }
  }
  @override Future<Either<Failure, void>> deleteEmployee(int id) async {
    try { await _r.deleteEmployee(id); return const Right(null); } catch(e) { return _err(e); }
  }
  @override Future<Either<Failure, List<dynamic>>> getRoles() async {
    try { return _wrap(await _r.getRoles()); } catch(e) { return _err(e); }
  }
  @override Future<Either<Failure, void>> createRole(String n, String d) async {
    try { await _r.createRole(n, d); return const Right(null); } catch(e) { return _err(e); }
  }
  @override Future<Either<Failure, void>> deleteRole(int id) async {
    try { await _r.deleteRole(id); return const Right(null); } catch(e) { return _err(e); }
  }
  @override Future<Either<Failure, List<dynamic>>> getPermissions() async {
    try { return _wrap(await _r.getPermissions()); } catch(e) { return _err(e); }
  }
  @override Future<Either<Failure, void>> setRolePermissions(int id, List<int> p) async {
    try { await _r.setRolePermissions(id, p); return const Right(null); } catch(e) { return _err(e); }
  }
  @override Future<Either<Failure, List<dynamic>>> getColleges() async {
    try { return _wrap(await _r.getColleges()); } catch(e) { return _err(e); }
  }
  @override Future<Either<Failure, void>> deleteCollege(int id) async {
    try { await _r.deleteCollege(id); return const Right(null); } catch(e) { return _err(e); }
  }
  @override Future<Either<Failure, List<dynamic>>> getPlans() async {
    try { return _wrap(await _r.getPlans()); } catch(e) { return _err(e); }
  }
  @override Future<Either<Failure, List<dynamic>>> getActivityLog() async {
    try { return _wrap(await _r.getActivityLog()); } catch(e) { return _err(e); }
  }
}
