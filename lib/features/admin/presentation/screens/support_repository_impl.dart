import 'package:dartz/dartz.dart';
import 'package:qualif_ai/features/admin/presentation/screens/support_remote_ds.dart';
import 'package:qualif_ai/features/admin/presentation/screens/support_repository.dart';
import '../../../../core/errors/failures.dart';


class SupportRepositoryImpl implements SupportRepository {
  final SupportRemoteDs remoteDs;

  SupportRepositoryImpl(this.remoteDs);

  @override
  Future<Either<Failure, void>> submitSupport(
      String name, String email, String message) async {
    try {
      await remoteDs.submitSupport(name, email, message);
      return const Right(null);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(ServerFailure(e.toString()));
    }
  }
}
