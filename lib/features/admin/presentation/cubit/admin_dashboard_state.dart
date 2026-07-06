import 'package:equatable/equatable.dart';

// ─── STATES ────────────────────────────────────────────────────────
abstract class AdminDashboardState extends Equatable {
  const AdminDashboardState();
  @override
  List<Object?> get props => [];
}

class AdminDashboardLoading extends AdminDashboardState {}

class AdminDashboardLoaded extends AdminDashboardState {
  final int collegesCount;
  final int unreadNotifications;
  final int pendingReviewsCount;
  final List<dynamic> subscriptions;
  final List<dynamic> activityLog;

  const AdminDashboardLoaded({
    required this.collegesCount,
    required this.unreadNotifications,
    required this.pendingReviewsCount,
    required this.subscriptions,
    required this.activityLog,
  });

  @override
  List<Object?> get props => [
        collegesCount,
        unreadNotifications,
        pendingReviewsCount,
        subscriptions,
        activityLog,
      ];
}

class AdminDashboardError extends AdminDashboardState {
  final String message;
  const AdminDashboardError(this.message);
  @override
  List<Object?> get props => [message];
}
