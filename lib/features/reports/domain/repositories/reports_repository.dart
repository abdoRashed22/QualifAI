// lib/features/reports/domain/repositories/reports_repository.dart

import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';

abstract class ReportsRepository {
  Future<Either<Failure, List<dynamic>>> getAllReports();

  Future<Either<Failure, List<dynamic>>> getMyReports();

  Future<Either<Failure, Map<String, dynamic>>> getReportDetail(int reportId);

  Future<Either<Failure, void>> uploadReport(File file);
}
