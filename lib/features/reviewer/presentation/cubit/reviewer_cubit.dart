import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/repositories/reviewer_repository.dart';

part 'reviewer_state.dart';

class ReviewerCubit extends Cubit<ReviewerState> {
  final ReviewerRepository _repository;

  ReviewerCubit(this._repository) : super(ReviewerInitial());

  Future<void> loadDashboard() async {
    emit(ReviewerLoading());
    final result = await _repository.getAssignedColleges();
    result.fold(
      (failure) => emit(ReviewerError(failure.message)),
      (colleges) {
        final normalized = List<dynamic>.from(colleges);
        final totalAssigned = normalized.length;
        final pendingReviews = normalized.where(
          (college) {
            final status = _statusValue(college);
            return status == 'pending' || status == 'needs revision';
          },
        ).length;
        final completedReviews = normalized.where(
          (college) {
            final status = _statusValue(college);
            return status == 'approved' || status == 'rejected';
          },
        ).length;
        final recentActivity = normalized.take(3).toList();
        emit(ReviewerDashboardLoaded(
          assignedColleges: normalized,
          totalAssigned: totalAssigned,
          pendingReviews: pendingReviews,
          completedReviews: completedReviews,
          recentActivity: recentActivity,
        ));
      },
    );
  }

  Future<void> loadCollege(int collegeId) async {
    emit(ReviewerLoading());
    final result = await _repository.getCollegeDetails(collegeId);
    result.fold(
      (failure) => emit(ReviewerError(failure.message)),
      (college) {
        final sections =
            (college['sections'] ?? college['standards'] ?? []) as List;
        emit(ReviewerCollegeLoaded(college: college, sections: sections));
      },
    );
  }

  Future<void> loadSectionFiles(int collegeId, int sectionId) async {
    emit(ReviewerLoading());
    final result = await _repository.getSectionFiles(collegeId, sectionId);
    result.fold(
      (failure) => emit(ReviewerError(failure.message)),
      (sectionData) {
        // Extract documents array from response
        final documents = (sectionData['documents'] as List?) ?? [];
        final section = {
          'name': sectionData['sectionName'] ?? sectionData['name'],
          'sectionName': sectionData['sectionName'] ?? sectionData['name'],
          'sectionId': sectionData['sectionId'],
          'uploadedDocuments': sectionData['uploadedDocuments'] ?? 0,
          'totalDocuments': sectionData['totalDocuments'] ?? documents.length,
          ...sectionData,
        };
        emit(ReviewerSectionLoaded(
          collegeId: collegeId,
          sectionId: sectionId,
          section: section,
          files: documents,
        ));
      },
    );
  }

  Future<void> submitDecision(
    int collegeId,
    String status,
    String notes,
  ) async {
    emit(ReviewerLoading());
    final result = await _repository.submitDecision(collegeId, status, notes);
    result.fold(
      (failure) => emit(ReviewerError(failure.message)),
      (_) => emit(const ReviewerActionSuccess('تم حفظ قرار الاعتماد بنجاح')),
    );
  }

  String _statusValue(dynamic college) {
    final raw = college is Map
        ? college['status'] ?? college['reviewStatus'] ?? college['statusName']
        : null;
    final value = raw?.toString().toLowerCase() ?? '';
    if (value.contains('approve') || value.contains('موافق')) return 'approved';
    if (value.contains('reject') || value.contains('رفض')) return 'rejected';
    if (value.contains('revision') || value.contains('تعديل'))
      return 'needs revision';
    return 'pending';
  }
}
