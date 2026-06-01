import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

abstract class PricingRepository {
  Future<Either<Failure, List<dynamic>>> getPlans();

  Future<Either<Failure, void>> subscribe(
      Map<String, dynamic> subscribeRequest);
}
