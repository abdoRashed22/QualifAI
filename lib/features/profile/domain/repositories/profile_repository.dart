// lib/features/profile/domain/repositories/profile_repository.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class ProfileRepository {
  Future<Either<Failure, Map<String, dynamic>>> getProfile();
  Future<Either<Failure, void>> updateProfile(String email, String firstName, String lastName);
  Future<Either<Failure, void>> updatePassword(String oldPass, String newPass);
  Future<Either<Failure, void>> uploadPhoto(File file);
  Future<Either<Failure, void>> deletePhoto();
}
