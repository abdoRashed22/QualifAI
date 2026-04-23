// lib/features/chat/domain/repositories/chat_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<dynamic>>> getColleges();
  Future<Either<Failure, List<dynamic>>> getMessages(int collegeId);
  Future<Either<Failure, void>> sendMessage(String content, int collegeId, int? receiverId);
}
