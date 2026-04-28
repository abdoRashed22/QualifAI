// lib/features/accreditation/presentation/cubit/accreditation_cubit.dart

import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:equatable/equatable.dart';

import '../../domain/repositories/accreditation_repository.dart';
import '../../../../core/di/injection.dart';
import '../../../dashboard/presentation/cubit/dashboard_cubit.dart';

part 'accreditation_state.dart';

class AccreditationCubit extends Cubit<AccreditationState> {
  final AccreditationRepository _repo;
  int? _lastAccreditationType;

  AccreditationCubit(this._repo) : super(AccreditationInitial());

  Future<void> loadSections() async {
    emit(AccreditationLoading());

    final r = await _repo.getSections();

    r.fold((f) => emit(AccreditationError(f.message)),
        (list) => emit(SectionsLoaded(_normalizeSections(list))));
  }

  Future<void> loadSectionsByType(int accreditationType) async {
    _lastAccreditationType = accreditationType;
    emit(AccreditationLoading());

    final r = await _repo.getStandardsByType(accreditationType);

    r.fold(
      (f) => emit(AccreditationError(f.message)),
      (list) => emit(SectionsLoaded(_normalizeSections(list))),
    );
  }

  Future<void> loadSectionDetail(int sectionId, int accreditationType) async {
    _lastAccreditationType = accreditationType;
    emit(AccreditationLoading());

    final result = await _repo.getSectionByTypeAndId(
      accreditationType,
      sectionId,
    );

    result.fold(
      (failure) => emit(AccreditationError(failure.message)),
      (section) {
        final normalized = _normalizeDetail(section);
        final enrichedSection = {
          ...normalized,
          'accreditationType': accreditationType,
          'sectionId': sectionId,
        };
        emit(SectionDetailLoaded(enrichedSection));
      },
    );
  }

  Future<void> uploadDocument(int reqDocId, File file) async {
    emit(UploadingDocument());

    final r = await _repo.uploadDocument(reqDocId, file);

    r.fold((f) => emit(AccreditationError(f.message)), (data) {
      emit(DocumentUploaded(data));
      if (sl.isRegistered<DashboardCubit>()) {
        sl<DashboardCubit>().reloadCurrent();
      }
    });
  }

  Future<void> getAnalysis(int reqDocId) async {
    emit(AccreditationLoading());

    final r = await _repo.getDocumentAnalysis(reqDocId);

    r.fold((f) => emit(AccreditationError(f.message)),
        (data) => emit(AnalysisLoaded(data)));
  }

  Future<void> setDeadline(int reqDocId, String deadline, bool oneWeek,
      bool oneDay, bool onDue) async {
    final r =
        await _repo.setDeadline(reqDocId, deadline, oneWeek, oneDay, onDue);

    r.fold((f) => emit(AccreditationError(f.message)), (_) {
      emit(const DeadlineSet());
      if (sl.isRegistered<DashboardCubit>()) {
        sl<DashboardCubit>().reloadCurrent();
      }
    });
  }

  // Normalize API response to use consistent field names

  List<dynamic> _normalizeSections(List<dynamic> raw) {
    return raw.map((s) {
      if (s is! Map) return s;

      return {
        'id': s['sectionId'] ?? s['id'] ?? 0,
        'name': s['sectionName'] ?? s['name'] ?? '',
        'uploadedDocuments': s['completedDocs'] ?? s['uploadedDocuments'] ?? 0,
        'requiredDocumentsCount':
            s['totalDocs'] ?? s['requiredDocumentsCount'] ?? 1,
        'completionPercentage': s['completionPercentage'] ?? 0,
        'accreditationType': s['accreditationType'] ?? _lastAccreditationType ?? 0,
      };
    }).toList();
  }

  Map<String, dynamic> _normalizeDetail(Map<String, dynamic> s) {
    final rawDocs =
        (s['requiredDocuments'] as List?) ?? s['documents'] as List? ?? [];

    return {
      'id': s['sectionId'] ?? s['id'] ?? 0,
      'name': s['sectionName'] ?? s['name'] ?? '',
      'uploadedDocuments': s['completedDocs'] ?? s['uploadedDocuments'] ?? 0,
      'requiredDocumentsCount':
          s['totalDocs'] ?? s['requiredDocumentsCount'] ?? 1,
      'completionPercentage': s['completionPercentage'] ?? 0,
      'accreditationType': s['accreditationType'] ?? _lastAccreditationType ?? 0,
      'requiredDocuments': rawDocs.map((doc) {
        if (doc is! Map) return doc;
        return {
        'id': doc['requiredDocumentId'] ?? doc['id'] ?? 0,
        'requiredDocumentId': doc['requiredDocumentId'] ?? doc['id'] ?? 0,
        'name': doc['documentName'] ?? doc['name'] ?? '',
        'documentName': doc['documentName'] ?? doc['name'] ?? '',
          'hasFile': doc['hasFile'] ?? false,
          'deadline': doc['deadline'],
          'statusLabel': doc['statusLabel'] ?? '',
          'statusColor': doc['statusColor'] ?? 'gray',
        };
      }).toList(),
    };
  }
}
