// lib/core/api/dio_client.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../cache/hive_cache.dart';
import 'api_endpoints.dart';
import 'auth_interceptor.dart';

class DioClient {
  final Dio _dio;
  final HiveCache _cache;
  final AuthInterceptor _authInterceptor;

  DioClient(this._cache, this._authInterceptor)
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: const Duration(seconds: 120),
            receiveTimeout: const Duration(seconds: 120),
            sendTimeout: const Duration(seconds: 120),
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

    // ✅ Auth & Logging & Error Handling Interceptor
    _dio.interceptors.add(_authInterceptor);

    // ✅ UTF-8 Decoder (IMPORTANT for Arabic)
    _dio.interceptors.add(_Utf8DecoderInterceptor());

    // ✅ Pretty Logger (debug only)
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: false,
        requestBody: true,
        responseBody: false, // تم الإيقاف هنا لمنع تجميد الكونسول
        responseHeader: false,
        compact: true,
        logPrint: (obj) {
          debugPrint(obj.toString());
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
      final contentType =
          response.headers.value('content-type')?.toLowerCase() ?? '';
      final path = response.requestOptions.path.toLowerCase();

      // تجاوز فك التشفير للملفات (مثل PDF) حتى لا تتلف أو تتحول لنصوص مشفرة
      if (contentType.contains('application/pdf') ||
          contentType.contains('octet-stream') ||
          path.endsWith('.pdf')) {
        return handler.next(response);
      }

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
