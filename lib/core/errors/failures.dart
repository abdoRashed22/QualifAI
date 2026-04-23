// lib/core/errors/failures.dart

import 'dart:convert';
import 'package:dio/dio.dart';

abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('لا يوجد اتصال بالإنترنت');
}

class CacheFailure extends Failure {
  const CacheFailure() : super('خطأ في قاعدة البيانات المحلية');
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure()
      : super('بيانات الدخول غير صحيحة، يرجى المحاولة مجدداً');
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure() : super('حدث خطأ غير متوقع');
}

Failure dioToFailure(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const NetworkFailure();
    case DioExceptionType.badResponse:
      final code = e.response?.statusCode;
      if (code == 401) return const UnauthorizedFailure();
      final msg = _extractMessage(e.response);
      return ServerFailure(msg, statusCode: code);
    default:
      return const UnknownFailure();
  }
}

String _extractMessage(Response? response) {
  if (response == null) return 'حدث خطأ في الخادم';
  try {
    dynamic data = response.data;
    if (data is List<int>) {
      data = jsonDecode(utf8.decode(data, allowMalformed: true));
    }
    if (data is String) {
      if (data.trim().startsWith('{') || data.trim().startsWith('[')) {
        data = jsonDecode(data);
      } else {
        return data.isNotEmpty ? data : 'حدث خطأ في الخادم';
      }
    }
    if (data is Map) {
      for (final key in ['message', 'Message', 'error', 'Error', 'title', 'Title', 'detail']) {
        final val = data[key];
        if (val is String && val.isNotEmpty) return val;
      }
      if (data['errors'] is Map) {
        final errors = data['errors'] as Map;
        for (final v in errors.values) {
          if (v is List && v.isNotEmpty) return v.first.toString();
        }
      }
    }
  } catch (_) {}
  return 'حدث خطأ (${response.statusCode})';
}