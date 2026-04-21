// lib/features/auth/domain/repositories/auth_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/auth_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, LoginResponseModel>> login(LoginRequestModel req);
  Future<Either<Failure, void>> forgotPassword(String email);
  Future<void> logout();
}
