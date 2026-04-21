// lib/features/profile/repository/profile_repository_impl.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../data/remote/profile_remote_ds.dart';
import '../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDs _remote;
  const ProfileRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProfile() async {
    try { return Right(await _remote.getProfile()); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return Left(const UnknownFailure()); }
  }

  @override
  Future<Either<Failure, void>> updateProfile(String email, String firstName, String lastName) async {
    try { await _remote.updateProfile(email, firstName, lastName); return const Right(null); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return Left(const UnknownFailure()); }
  }

  @override
  Future<Either<Failure, void>> updatePassword(String oldPass, String newPass) async {
    try { await _remote.updatePassword(oldPass, newPass); return const Right(null); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return Left(const UnknownFailure()); }
  }

  @override
  Future<Either<Failure, void>> uploadPhoto(File file) async {
    try { await _remote.uploadPhoto(file); return const Right(null); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return Left(const UnknownFailure()); }
  }

  @override
  Future<Either<Failure, void>> deletePhoto() async {
    try { await _remote.deletePhoto(); return const Right(null); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return Left(const UnknownFailure()); }
  }
}
