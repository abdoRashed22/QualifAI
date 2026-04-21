// lib/features/notifications/presentation/cubit/notification_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/notification_repository.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repo;
  Timer? _pollingTimer;

  NotificationCubit(this._repo) : super(NotificationInitial());

  void startPolling() {
    loadNotifications();
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _pollUnreadCount(),
    );
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> loadNotifications() async {
    emit(NotificationLoading());
    final result = await _repo.getNotifications();
    result.fold(
      (f) => emit(NotificationError(f.message)),
      (list) => emit(NotificationLoaded(list)),
    );
  }

  Future<void> markAllRead() async {
    await _repo.markAllRead();
    await loadNotifications();
  }

  Future<void> _pollUnreadCount() async {
    final result = await _repo.getUnreadCount();
    result.fold(
      (_) {},
      (count) {
        if (state is NotificationLoaded) {
          emit((state as NotificationLoaded).copyWith(unreadCount: count));
        }
      },
    );
  }

  @override
  Future<void> close() {
    stopPolling();
    return super.close();
  }
}
