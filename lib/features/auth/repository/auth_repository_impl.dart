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

  // ✅ NEW: role mapping
  String _mapRole(String role) {
    switch (role) {
      case 'مدير النظام':
        return 'admin';
      case 'مدير الجوده':
        return 'manager';
      case 'موظف الجوده':
        return 'employee';
      default:
        return 'user';
    }
  }

  @override
  Future<Either<Failure, LoginResponseModel>> login(
      LoginRequestModel req) async {
    try {
      final result = await _remote.login(req);

      print(
          "LOGIN RESPONSE = token=${result.token}, role=${result.role}, email=${result.email}");

      await _cache.saveToken(result.token);

      // ✅ FIX هنا
      final role = _mapRole(result.role);
      await _cache.saveRole(role);

      await _cache.saveUserData({
        'firstName': result.firstName,
        'lastName': result.lastName,
        'email': result.email,
        'role': role,
      });

      return Right(result);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      print("LOGIN ERROR = $e");
      return const Left(UnknownFailure());
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
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<void> logout() async {
    await _cache.clearAll();
  }
}