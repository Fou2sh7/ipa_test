import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mediconsult/core/error/app_failure.dart';

AppFailure mapDioException(DioException exception) {
  final statusCode = exception.response?.statusCode;

  // Network-level errors
  if (exception.type == DioExceptionType.connectionTimeout ||
      exception.type == DioExceptionType.sendTimeout ||
      exception.type == DioExceptionType.receiveTimeout) {
    return const AppFailure.timeout();
  }

  if (exception.type == DioExceptionType.connectionError ||
      (exception.type == DioExceptionType.unknown &&
          exception.error is SocketException)) {
    return const AppFailure.network();
  }

  // HTTP status based errors
  if (statusCode != null) {
    if (statusCode == 401) return const AppFailure.unauthorized();
    if (statusCode == 403) return const AppFailure.forbidden();
    if (statusCode == 404) return const AppFailure.notFound();
    if (statusCode >= 500) return AppFailure.server(statusCode: statusCode);
  }

  // Fallback
  return AppFailure.unexpected(exception.message);
}

