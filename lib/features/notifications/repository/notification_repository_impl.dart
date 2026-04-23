// lib/features/notifications/repository/notification_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../data/remote/notification_remote_ds.dart';
import '../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDs _remote;
  const NotificationRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<dynamic>>> getNotifications() async {
    try { return Right(await _remote.getNotifications()); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return const Left(UnknownFailure()); }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try { return Right(await _remote.getUnreadCount()); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return const Left(UnknownFailure()); }
  }

  @override
  Future<Either<Failure, void>> markAllRead() async {
    try { await _remote.markAllRead(); return const Right(null); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return const Left(UnknownFailure()); }
  }
}
