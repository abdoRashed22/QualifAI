// lib/features/reports/domain/repositories/reports_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class ReportsRepository {
  Future<Either<Failure, List<dynamic>>> getReports();
  Future<Either<Failure, Map<String, dynamic>>> getReportDetail(int sectionId);
}
