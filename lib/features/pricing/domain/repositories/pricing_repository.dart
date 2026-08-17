import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/pricing_plan_model.dart';

abstract class PricingRepository {
  Future<Either<Failure, List<PricingPlanModel>>> getPlans();

  Future<Either<Failure, void>> subscribe(
      Map<String, dynamic> subscribeRequest);
}
