import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';

abstract class ReviewerRepository {
  Future<Either<Failure, List<dynamic>>> getAssignedColleges();

  Future<Either<Failure, Map<String, dynamic>>> getCollegeDetails(
    int collegeId,
  );

  Future<Either<Failure, List<dynamic>>> getSectionFiles(
    int collegeId,
    int sectionId,
  );

  Future<Either<Failure, void>> submitDecision(
    int collegeId,
    String status,
    String notes,
  );
}
