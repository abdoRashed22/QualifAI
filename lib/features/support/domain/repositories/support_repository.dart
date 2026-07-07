import 'package:dartz/dartz.dart';
import 'package:qualif_ai/core/errors/failures.dart';

abstract class SupportRepository {
  Future<Either<Failure, void>> submitSupport(
      String name, String email, String message);
}
