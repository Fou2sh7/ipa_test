import 'package:dio/dio.dart';
import 'package:mediconsult/core/error/app_failure.dart';
import 'package:mediconsult/core/error/error_mapper.dart';

/// Interceptor that converts [DioException] to a domain-level [AppFailure].
class ErrorMappingInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.error is AppFailure) {
      return super.onError(err, handler);
    }

    final failure = mapDioException(err);
    return handler.reject(err.copyWith(error: failure));
  }
}

