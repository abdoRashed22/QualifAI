import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../data/remote/reviewer_remote_ds.dart';
import '../domain/repositories/reviewer_repository.dart';

class ReviewerRepositoryImpl implements ReviewerRepository {
  final ReviewerRemoteDs _remote;

  const ReviewerRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<dynamic>>> getAssignedColleges() async {
    try {
      return Right(await _remote.getAssignedColleges());
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCollegeDetails(
    int collegeId,
  ) async {
    try {
      return Right(await _remote.getCollegeDetails(collegeId));
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getSectionFiles(
    int collegeId,
    int sectionId,
  ) async {
    try {
      return Right(await _remote.getSectionFiles(collegeId, sectionId));
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> submitDecision(
    int collegeId,
    String status,
    String notes,
  ) async {
    try {
      await _remote.submitDecision(collegeId, status, notes);
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
