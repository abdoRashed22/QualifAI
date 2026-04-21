// lib/features/accreditation/presentation/cubit/accreditation_cubit.dart
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/accreditation_repository.dart';

part 'accreditation_state.dart';

class AccreditationCubit extends Cubit<AccreditationState> {
  final AccreditationRepository _repo;
  AccreditationCubit(this._repo) : super(AccreditationInitial());

  Future<void> loadSections() async {
    emit(AccreditationLoading());
    final r = await _repo.getSections();
    r.fold((f) => emit(AccreditationError(f.message)), (list) => emit(SectionsLoaded(_normalizeSections(list))));
  }

  Future<void> loadSectionDetail(int id) async {
    emit(AccreditationLoading());
    final r = await _repo.getSectionById(id);
    r.fold((f) => emit(AccreditationError(f.message)), (data) => emit(SectionDetailLoaded(_normalizeDetail(data))));
  }

  Future<void> uploadDocument(int reqDocId, File file) async {
    emit(UploadingDocument());
    final r = await _repo.uploadDocument(reqDocId, file);
    r.fold((f) => emit(AccreditationError(f.message)), (data) => emit(DocumentUploaded(data)));
  }

  Future<void> setDeadline(int reqDocId, String deadline, bool oneWeek, bool oneDay, bool onDue) async {
    final r = await _repo.setDeadline(reqDocId, deadline, oneWeek, oneDay, onDue);
    r.fold((f) => emit(AccreditationError(f.message)), (_) => emit(const DeadlineSet()));
  }

  // Normalize API response to use consistent field names
  List<dynamic> _normalizeSections(List<dynamic> raw) {
    return raw.map((s) {
      if (s is! Map) return s;
      return {
        'id': s['sectionId'] ?? s['id'] ?? 0,
        'name': s['sectionName'] ?? s['name'] ?? '',
        'uploadedDocuments': s['completedDocs'] ?? s['uploadedDocuments'] ?? 0,
        'requiredDocumentsCount': s['totalDocs'] ?? s['requiredDocumentsCount'] ?? 1,
        'completionPercentage': s['completionPercentage'] ?? 0,
      };
    }).toList();
  }

  Map<String, dynamic> _normalizeDetail(Map<String, dynamic> s) {
    return {
      'id': s['sectionId'] ?? s['id'] ?? 0,
      'name': s['sectionName'] ?? s['name'] ?? '',
      'uploadedDocuments': s['completedDocs'] ?? s['uploadedDocuments'] ?? 0,
      'requiredDocumentsCount': s['totalDocs'] ?? s['requiredDocumentsCount'] ?? 1,
      'completionPercentage': s['completionPercentage'] ?? 0,
      'requiredDocuments': s['requiredDocuments'] ?? s['documents'] ?? [],
    };
  }
}
