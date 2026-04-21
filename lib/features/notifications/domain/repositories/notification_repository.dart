// lib/features/notifications/domain/repositories/notification_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<dynamic>>> getNotifications();
  Future<Either<Failure, int>> getUnreadCount();
  Future<Either<Failure, void>> markAllRead();
}

// â”€â”€ impl â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// lib/features/notifications/repository/notification_repository_impl.dart
// (defined inline for brevity, split into separate file in real project)
