import 'package:flutter/material.dart';
import 'package:mediconsult/core/error/app_failure.dart';
import 'package:mediconsult/core/theming/app_colors.dart';

class AppErrorHandler {
  static String messageFromFailure(AppFailure failure) {
    switch (failure.type) {
      case AppFailureType.network:
        return 'No internet connection. Please check your network.';
      case AppFailureType.timeout:
        return 'Request timed out. Please try again.';
      case AppFailureType.unauthorized:
        return 'Session expired. Please login again.';
      case AppFailureType.forbidden:
        return 'Access denied. You don\'t have permission.';
      case AppFailureType.notFound:
        return 'Resource not found.';
      case AppFailureType.server:
        return 'Server error. Please try again later.';
      case AppFailureType.unexpected:
        return failure.message ?? 'Something went wrong. Please try again.';
    }
  }

  static String getUserFriendlyMessage(String error) {
    if (error.toLowerCase().contains('socketexception') ||
        error.toLowerCase().contains('network')) {
      return 'No internet connection. Please check your network.';
    }
    
    if (error.toLowerCase().contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    
    if (error.contains('401')) {
      return 'Session expired. Please login again.';
    }
    
    if (error.contains('403')) {
      return 'Access denied. You don\'t have permission.';
    }
    
    if (error.contains('404')) {
      return 'Resource not found.';
    }
    
    if (error.contains('500') || error.contains('502') || error.contains('503')) {
      return 'Server error. Please try again later.';
    }
    
    return 'Something went wrong. Please try again.';
  }

  static String _resolveMessage(Object error) {
    if (error is AppFailure) {
      return messageFromFailure(error);
    }
    return getUserFriendlyMessage(error.toString());
  }

  static void showErrorSnackBar(
    BuildContext context,
    Object error, {
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    final message = _resolveMessage(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorClr,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  static void showErrorDialog(
    BuildContext context,
    Object error, {
    VoidCallback? onRetry,
  }) {
    final message = _resolveMessage(error);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.errorClr),
            const SizedBox(width: 8),
            const Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryClr,
              ),
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  static void logError(Object error, {StackTrace? stackTrace}) {
    debugPrint('Error: $error');
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
  }
}
