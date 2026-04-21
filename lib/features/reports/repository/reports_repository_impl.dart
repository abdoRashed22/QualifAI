// lib/features/reports/repository/reports_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../data/remote/reports_remote_ds.dart';
import '../domain/repositories/reports_repository.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDs _remote;
  const ReportsRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<dynamic>>> getReports() async {
    try { return Right(await _remote.getReports()); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return Left(const UnknownFailure()); }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getReportDetail(int sectionId) async {
    try { return Right(await _remote.getReportDetail(sectionId)); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return Left(const UnknownFailure()); }
  }
}
