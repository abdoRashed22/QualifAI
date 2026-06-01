// lib/features/reports/repository/reports_repository_impl.dart

import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';

import '../data/remote/reports_remote_ds.dart';

import '../domain/repositories/reports_repository.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDs _remote;

  const ReportsRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<dynamic>>> getAllReports() async {
    try {
      return Right(await _remote.getAllReports());
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getMyReports() async {
    try {
      return Right(await _remote.getMyReports());
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getReportDetail(
      int reportId) async {
    try {
      return Right(await _remote.getReportDetail(reportId));
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> uploadReport(File file) async {
    try {
      await _remote.uploadReport(file);
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
