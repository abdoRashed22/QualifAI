// lib/core/api/dio_client.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../cache/hive_cache.dart';
import 'api_endpoints.dart';

class DioClient {
  final Dio _dio;
  final HiveCache _cache;

  DioClient(this._cache)
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            responseType: ResponseType.bytes, // ✅ مهم لدعم UTF-8
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json',
              'Accept-Charset': 'utf-8',
            },
          ),
        ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.clear();

    // ✅ Combined Interceptor (Auth + Logging + Error Handling)
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _cache.getToken();

          // ✅ Bearer Token
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // ✅ Ensure Content-Type with charset (except FormData)
          if (options.contentType == null && options.data is! FormData) {
            options.contentType = 'application/json; charset=utf-8';
          }

          print('📤 [REQUEST] ${options.method} ${options.path}');
          print('📤 [HEADERS] ${options.headers}');
          print('📤 [BODY] ${options.data}');

          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
              '📥 [RESPONSE] ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('❌ [ERROR] ${error.response?.statusCode} ${error.message}');

          // ✅ Handle 401
          if (error.response?.statusCode == 401) {
            _cache.clearAll();
            // navigation handled in UI
          }

          return handler.next(error);
        },
      ),
    );

    // ✅ UTF-8 Decoder (IMPORTANT for Arabic)
    _dio.interceptors.add(_Utf8DecoderInterceptor());

    // ✅ Pretty Logger (debug only)
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: false,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        compact: true,
        logPrint: (obj) {
          assert(() {
            print(obj);
            return true;
          }());
        },
      ),
    );
  }

  Dio get dio => _dio;
}

/// ✅ Fix Arabic encoding issue
class _Utf8DecoderInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data is List<int>) {
      final bytes = response.data as List<int>;
      final decoded = utf8.decode(bytes, allowMalformed: true);

      try {
        response.data = jsonDecode(decoded);
      } catch (_) {
        response.data = decoded;
      }
    }
    handler.next(response);
  }
}
