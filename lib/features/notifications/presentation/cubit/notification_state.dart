// lib/features/notifications/presentation/cubit/notification_state.dart
part of 'notification_cubit.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();
  @override List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}
class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<dynamic> notifications;
  final int unreadCount;

  const NotificationLoaded(this.notifications, {this.unreadCount = 0});

  NotificationLoaded copyWith({List<dynamic>? notifications, int? unreadCount}) {
    return NotificationLoaded(
      notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override List<Object?> get props => [notifications, unreadCount];
}

class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);
  @override List<Object?> get props => [message];
}
