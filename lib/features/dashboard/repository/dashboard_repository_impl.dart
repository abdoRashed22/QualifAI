// lib/features/dashboard/repository/dashboard_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../data/remote/dashboard_remote_ds.dart';
import '../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDs _remote;
  const DashboardRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSections() async {
    try {
      final data = await _remote.getSections();
      return Right(data);
    } on Failure catch (f) { return Left(f); }
    catch (_) { return const Left(UnknownFailure()); }
  }
}
