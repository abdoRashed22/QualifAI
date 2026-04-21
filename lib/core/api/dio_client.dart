// lib/core/api/dio_client.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../cache/hive_cache.dart';
import 'api_endpoints.dart';

class DioClient {
  late final Dio _dio;

  DioClient(HiveCache cache) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        responseType: ResponseType.bytes, // âœ… Get raw bytes, decode ourselves
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
          'Accept-Charset': 'utf-8',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(cache),
      _Utf8DecoderInterceptor(), // âœ… Force UTF-8 decode on every response
      PrettyDioLogger(
        requestHeader: false,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        compact: true,
        logPrint: (obj) {
          // Only log in debug mode
          assert(() {
            // ignore: avoid_print
            print(obj);
            return true;
          }());
        },
      ),
    ]);
  }

  Dio get dio => _dio;
}

/// Forces UTF-8 decoding of all API responses.
/// Without this, Dio reads Arabic/Unicode text as Latin-1 â†’ garbled characters.
class _Utf8DecoderInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data is List<int>) {
      final bytes = response.data as List<int>;
      final decoded = utf8.decode(bytes, allowMalformed: true);
      // Try to parse as JSON
      try {
        response.data = jsonDecode(decoded);
      } catch (_) {
        response.data = decoded;
      }
    }
    handler.next(response);
  }
}

class _AuthInterceptor extends Interceptor {
  final HiveCache _cache;
  _AuthInterceptor(this._cache);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _cache.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _cache.clearAll();
    }
    handler.next(err);
  }
}
