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
  const NetworkFailure() : super('Ù„Ø§ ÙŠÙˆØ¬Ø¯ Ø§ØªØµØ§Ù„ Ø¨Ø§Ù„Ø¥Ù†ØªØ±Ù†Øª');
}

class CacheFailure extends Failure {
  const CacheFailure() : super('Ø®Ø·Ø£ ÙÙŠ Ù‚Ø§Ø¹Ø¯Ø© Ø§Ù„Ø¨ÙŠØ§Ù†Ø§Øª Ø§Ù„Ù…Ø­Ù„ÙŠØ©');
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure()
      : super('Ø¨ÙŠØ§Ù†Ø§Øª Ø§Ù„Ø¯Ø®ÙˆÙ„ ØºÙŠØ± ØµØ­ÙŠØ­Ø©ØŒ ÙŠØ±Ø¬Ù‰ Ø§Ù„Ù…Ø­Ø§ÙˆÙ„Ø© Ù…Ø¬Ø¯Ø¯Ø§Ù‹');
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure() : super('Ø­Ø¯Ø« Ø®Ø·Ø£ ØºÙŠØ± Ù…ØªÙˆÙ‚Ø¹');
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
  if (response == null) return 'Ø­Ø¯Ø« Ø®Ø·Ø£ ÙÙŠ Ø§Ù„Ø®Ø§Ø¯Ù…';
  try {
    dynamic data = response.data;
    if (data is List<int>) {
      data = jsonDecode(utf8.decode(data, allowMalformed: true));
    }
    if (data is String) {
      if (data.trim().startsWith('{') || data.trim().startsWith('[')) {
        data = jsonDecode(data);
      } else {
        return data.isNotEmpty ? data : 'Ø­Ø¯Ø« Ø®Ø·Ø£ ÙÙŠ Ø§Ù„Ø®Ø§Ø¯Ù…';
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
  return 'Ø­Ø¯Ø« Ø®Ø·Ø£ (${response.statusCode})';
}
