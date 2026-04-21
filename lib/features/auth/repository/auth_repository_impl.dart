// lib/features/auth/repository/auth_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/cache/hive_cache.dart';
import '../data/models/auth_model.dart';
import '../data/remote/auth_remote_ds.dart';
import '../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDs _remote;
  final HiveCache _cache;

  const AuthRepositoryImpl(this._remote, this._cache);

  @override
  Future<Either<Failure, LoginResponseModel>> login(
      LoginRequestModel req) async {
    try {
      final result = await _remote.login(req);
      await _cache.saveToken(result.token);
      await _cache.saveRole(result.role);
      await _cache.saveUserData({
        'firstName': result.firstName,
        'lastName': result.lastName,
        'email': result.email,
        'role': result.role,
      });
      return Right(result);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await _remote.forgotPassword(ForgotPasswordModel(email: email));
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<void> logout() async {
    await _cache.clearAll();
  }
}
