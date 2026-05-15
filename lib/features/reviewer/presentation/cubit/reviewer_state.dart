part of 'reviewer_cubit.dart';

abstract class ReviewerState extends Equatable {
  const ReviewerState();

  @override
  List<Object?> get props => [];
}

class ReviewerInitial extends ReviewerState {}

class ReviewerLoading extends ReviewerState {}

class ReviewerDashboardLoaded extends ReviewerState {
  final List<dynamic> assignedColleges;
  final int totalAssigned;
  final int pendingReviews;
  final int completedReviews;
  final List<dynamic> recentActivity;

  const ReviewerDashboardLoaded({
    required this.assignedColleges,
    required this.totalAssigned,
    required this.pendingReviews,
    required this.completedReviews,
    required this.recentActivity,
  });

  @override
  List<Object?> get props => [
        assignedColleges,
        totalAssigned,
        pendingReviews,
        completedReviews,
        recentActivity
      ];
}

class ReviewerCollegeLoaded extends ReviewerState {
  final Map<String, dynamic> college;
  final List<dynamic> sections;

  const ReviewerCollegeLoaded({
    required this.college,
    required this.sections,
  });

  @override
  List<Object?> get props => [college, sections];
}

class ReviewerSectionLoaded extends ReviewerState {
  final int collegeId;
  final int sectionId;
  final Map<String, dynamic> section;
  final List<dynamic> files;

  const ReviewerSectionLoaded({
    required this.collegeId,
    required this.sectionId,
    required this.section,
    required this.files,
  });

  @override
  List<Object?> get props => [collegeId, sectionId, section, files];
}

class ReviewerActionSuccess extends ReviewerState {
  final String message;

  const ReviewerActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ReviewerError extends ReviewerState {
  final String message;

  const ReviewerError(this.message);

  @override
  List<Object?> get props => [message];
}
