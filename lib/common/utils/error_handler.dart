import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ErrorHandler {
  /// Handle and display errors in a user-friendly way
  static void handleError(
    dynamic error, {
    String? context,
    VoidCallback? onError,
  }) {
    String errorMessage = 'An unexpected error occurred';

    // Parse different error types
    if (error is FormatException) {
      errorMessage = 'Invalid data format. Please check your input.';
    } else if (error is TypeError) {
      errorMessage = 'Data type error. Please try again.';
    } else if (error.toString().contains('database') ||
        error.toString().contains('Hive')) {
      errorMessage = 'Database error. Please try again or restart the app.';
    } else if (error.toString().contains('network') ||
        error.toString().contains('connection')) {
      errorMessage = 'Connection error. Please check your internet connection.';
    } else if (error.toString().isNotEmpty) {
      // Try to extract meaningful error message
      final errorStr = error.toString();
      if (errorStr.contains('Exception:')) {
        errorMessage = errorStr.split('Exception:').last.trim();
      } else if (errorStr.contains('Error:')) {
        errorMessage = errorStr.split('Error:').last.trim();
      } else {
        errorMessage = errorStr;
      }
      // Limit error message length
      if (errorMessage.length > 100) {
        errorMessage = '${errorMessage.substring(0, 97)}...';
      }
    }

    // Add context if provided
    if (context != null) {
      errorMessage = '$context: $errorMessage';
    }

    // Show error snackbar
    Get.snackbar(
      'Error',
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.errorContainer,
      colorText: Get.theme.colorScheme.onErrorContainer,
      icon: Icon(
        Icons.error_outline,
        color: Get.theme.colorScheme.onErrorContainer,
      ),
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );

    // Call optional error callback
    if (onError != null) {
      onError();
    }

    // Log error for debugging (in production, you might want to send to crash reporting)
    debugPrint('ErrorHandler: $error');
  }

  /// Show a success message
  static void showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primaryContainer,
      colorText: Get.theme.colorScheme.onPrimaryContainer,
      icon: Icon(
        Icons.check_circle,
        color: Get.theme.colorScheme.onPrimaryContainer,
      ),
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  /// Show a warning message
  static void showWarning(String message) {
    Get.snackbar(
      'Warning',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.tertiaryContainer,
      colorText: Get.theme.colorScheme.onTertiaryContainer,
      icon: Icon(
        Icons.warning_amber_rounded,
        color: Get.theme.colorScheme.onTertiaryContainer,
      ),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  /// Wrap async operations with error handling
  static Future<T?> safeAsync<T>({
    required Future<T> Function() operation,
    String? context,
    T? defaultValue,
    VoidCallback? onError,
  }) async {
    try {
      return await operation();
    } catch (error) {
      handleError(error, context: context, onError: onError);
      return defaultValue;
    }
  }
}

