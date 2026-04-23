// lib/features/accreditation/repository/accreditation_repository_impl.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../data/remote/accreditation_remote_ds.dart';
import '../domain/repositories/accreditation_repository.dart';

class AccreditationRepositoryImpl implements AccreditationRepository {
  final AccreditationRemoteDs _remote;
  const AccreditationRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<dynamic>>> getSections() async {
    try { return Right(await _remote.getSections()); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return const Left(UnknownFailure()); }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSectionById(int id) async {
    try { return Right(await _remote.getSectionById(id)); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return const Left(UnknownFailure()); }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> uploadDocument(int reqDocId, File file) async {
    try { return Right(await _remote.uploadDocument(reqDocId, file)); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return const Left(UnknownFailure()); }
  }

  @override
  Future<Either<Failure, void>> setDeadline(int reqDocId, String deadline, bool oneWeek, bool oneDay, bool onDue) async {
    try {
      await _remote.setDeadline(reqDocId, deadline, oneWeek, oneDay, onDue);
      return const Right(null);
    }
    on Failure catch (f) { return Left(f); }
    catch (_) { return const Left(UnknownFailure()); }
  }
}
