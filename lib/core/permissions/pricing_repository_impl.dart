import 'package:dartz/dartz.dart';
import 'package:qualif_ai/core/permissions/pricing_remote_ds.dart';
import 'package:qualif_ai/core/permissions/pricing_repository.dart';
import '../errors/failures.dart';

class PricingRepositoryImpl implements PricingRepository {
  final PricingRemoteDs remoteDs;

  PricingRepositoryImpl(this.remoteDs);

  @override
  Future<Either<Failure, List<dynamic>>> getPlans() async {
    try {
      final result = await remoteDs.getPlans();
      return Right(result);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> subscribe(
      Map<String, dynamic> subscribeRequest) async {
    try {
      await remoteDs.subscribe(subscribeRequest);
      return const Right(null);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(ServerFailure(e.toString()));
    }
  }
}
