import 'package:dio/dio.dart';

import '../../../../core/errors/failures.dart';

class PricingRemoteDs {
  final Dio _dio;

  const PricingRemoteDs(this._dio);

  Future<List<Map<String, dynamic>>> getPlans() async {
    try {
      final res = await _dio.get('/Pricing');
      if (res.data is List) {
        return (res.data as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
      return const [];
    } on DioException catch (e) {
      throw dioToFailure(e);
    }
  }

  Future<void> subscribe(Map<String, dynamic> data) async {
    try {
      await _dio.post('/Pricing/subscribe', data: data);
    } on DioException catch (e) {
      throw dioToFailure(e);
    }
  }
}
