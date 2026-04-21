// lib/features/chat/repository/chat_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../data/remote/chat_remote_ds.dart';
import '../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDs _remote;
  const ChatRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<dynamic>>> getColleges() async {
    try { return Right(await _remote.getColleges()); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return Left(const UnknownFailure()); }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getMessages(int collegeId) async {
    try { return Right(await _remote.getMessages(collegeId)); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return Left(const UnknownFailure()); }
  }

  @override
  Future<Either<Failure, void>> sendMessage(String content, int collegeId, int? receiverId) async {
    try { await _remote.sendMessage(content, collegeId, receiverId); return const Right(null); }
    on Failure catch (f) { return Left(f); }
    catch (_) { return Left(const UnknownFailure()); }
  }
}
