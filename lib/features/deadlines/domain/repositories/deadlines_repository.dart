// lib/features/deadlines/domain/repositories/deadlines_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
abstract class DeadlinesRepository {
  Future<Either<Failure, List<dynamic>>> getDeadlines();
}

// lib/features/deadlines/repository/deadlines_repository_impl.dart
