import 'package:dartz/dartz.dart';
import 'package:qualif_ai/features/support/data/remote/support_remote_ds.dart';
import 'package:qualif_ai/features/support/domain/repositories/support_repository.dart';
import '../../../../../../../core/errors/failures.dart';

class SupportRepositoryImpl implements SupportRepository {
  final SupportRemoteDs remoteDs;

  SupportRepositoryImpl(this.remoteDs);

  @override
  Future<Either<Failure, void>> submitSupport(
      String name, String email, String message) async {
    try {
      await remoteDs.submitSupport(name, email, message);
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
