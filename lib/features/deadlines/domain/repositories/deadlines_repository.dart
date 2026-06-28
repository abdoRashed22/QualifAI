// lib/features/deadlines/domain/repositories/deadlines_repository.dart

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';

abstract class DeadlinesRepository {
  Future<Either<Failure, List<dynamic>>> getDeadlines();

  Future<Either<Failure, void>> setDeadline(
    int docId,
    String deadline,
    bool remindOneWeek,
    bool remindOneDay,
    bool remindOnDue,
  );
}
