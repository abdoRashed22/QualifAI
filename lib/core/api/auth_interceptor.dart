import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../cache/hive_cache.dart';

class AuthInterceptor extends Interceptor {
  final HiveCache cache;
  final void Function() onUnauthorized;

  AuthInterceptor({required this.cache, required this.onUnauthorized});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = cache.getToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    if (options.contentType == null && options.data is! FormData) {
      options.contentType = 'application/json; charset=utf-8';
    }

    debugPrint('📤 [REQUEST] ${options.method} ${options.path}');
    debugPrint('📤 [HEADERS] ${options.headers}');
    debugPrint('📤 [BODY] ${options.data}');

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
        '📥 [RESPONSE] ${response.statusCode} ${response.requestOptions.path}');

    final respStr = response.data.toString();
    if (respStr.length > 300) {
      debugPrint('📥 [BODY] ${respStr.substring(0, 300)}... [TRUNCATED]');
    } else {
      debugPrint('📥 [BODY] $respStr');
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    debugPrint('❌ [ERROR] ${err.response?.statusCode} ${err.message}');

    final path = err.requestOptions.path;
    if (err.response?.statusCode == 401 && !path.contains('/Auth/login')) {
      debugPrint(
          '⚠️ Token expired or unauthorized. Clearing cache and logging out...');
      await cache.clearAll();
      onUnauthorized();
    }

    super.onError(err, handler);
  }
}
