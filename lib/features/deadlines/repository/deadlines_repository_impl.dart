// lib/features/deadlines/repository/deadlines_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../data/remote/deadlines_remote_ds.dart';
import '../domain/repositories/deadlines_repository.dart';

class DeadlinesRepositoryImpl implements DeadlinesRepository {
  final DeadlinesRemoteDs _remote;
  const DeadlinesRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<dynamic>>> getDeadlines() async {
    try { return Right(await _remote.getDeadlines()); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return Left(const UnknownFailure()); }
  }
}
