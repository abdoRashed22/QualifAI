// lib/features/accreditation/domain/repositories/accreditation_repository.dart

import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';

abstract class AccreditationRepository {
  Future<Either<Failure, List<dynamic>>> getSections();

Future<Either<Failure, Map<String, dynamic>>> getSectionByTypeAndId(
  int accreditationType,
  int sectionId,
);

  Future<Either<Failure, List<dynamic>>> getStandardsByType(
      int accreditationType);

  Future<Either<Failure, Map<String, dynamic>>> getDocumentAnalysis(
      int reqDocId);

  Future<Either<Failure, Map<String, dynamic>>> uploadDocument(
      int reqDocId, File file);

  Future<Either<Failure, void>> setDeadline(
      int reqDocId, String deadline, bool oneWeek, bool oneDay, bool onDue);
}
