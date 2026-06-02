import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class SupportRepository {
  Future<Either<Failure, void>> submitSupport(
      String name, String email, String message);
}