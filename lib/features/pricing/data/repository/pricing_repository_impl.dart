import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/pricing_plan_model.dart';
import '../../data/remote/pricing_remote_ds.dart';
import '../../domain/repositories/pricing_repository.dart';

class PricingRepositoryImpl implements PricingRepository {
  final PricingRemoteDs remoteDs;

  PricingRepositoryImpl(this.remoteDs);

  @override
  Future<Either<Failure, List<PricingPlanModel>>> getPlans() async {
    try {
      final result = await remoteDs.getPlans();
      final plans =
          result.map((json) => PricingPlanModel.fromJson(json)).toList();
      return Right(plans);
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
