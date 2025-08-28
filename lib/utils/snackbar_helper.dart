// File: lib/utils/snackbar_helper.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

class SnackbarHelper {
  // Private constructor for singleton
  SnackbarHelper._();

  // Show success message (2 seconds)
  static void showSuccess(String message, {String? title}) {
    _dismissCurrentSnackbar();
    Get.snackbar(
      title ?? 'Success',
      message,
      backgroundColor: AppTheme.success,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.all(16),
      borderRadius: AppTheme.radiusMedium,
      icon: Icon(Icons.check_circle, color: Colors.white),
      shouldIconPulse: false,
      barBlur: 10,
    );
  }

  // Show error message (4 seconds)
  static void showError(String message, {String? title}) {
    _dismissCurrentSnackbar();
    Get.snackbar(
      title ?? 'Error',
      message,
      backgroundColor: AppTheme.error,
      colorText: Colors.white,
      duration: Duration(seconds: 4),
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.all(16),
      borderRadius: AppTheme.radiusMedium,
      icon: Icon(Icons.error, color: Colors.white),
      shouldIconPulse: false,
      barBlur: 10,
    );
  }

  // Show warning message (3 seconds)
  static void showWarning(String message, {String? title}) {
    _dismissCurrentSnackbar();
    Get.snackbar(
      title ?? 'Warning',
      message,
      backgroundColor: AppTheme.warning,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.all(16),
      borderRadius: AppTheme.radiusMedium,
      icon: Icon(Icons.warning_amber, color: Colors.white),
      shouldIconPulse: false,
      barBlur: 10,
    );
  }

  // Show info message (1.5 seconds)
  static void showInfo(String message, {String? title}) {
    _dismissCurrentSnackbar();
    Get.snackbar(
      title ?? 'Info',
      message,
      backgroundColor: AppTheme.info,
      colorText: Colors.white,
      duration: Duration(milliseconds: 1500),
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.all(16),
      borderRadius: AppTheme.radiusMedium,
      icon: Icon(Icons.info, color: Colors.white),
      shouldIconPulse: false,
      barBlur: 10,
    );
  }

  // Context-aware snackbar for dark/light backgrounds
  static void showContextAware(
    String message,
    SnackbarType type, {
    String? title,
    BuildContext? context,
  }) {
    _dismissCurrentSnackbar();

    Color backgroundColor;
    Color textColor;
    IconData iconData;
    Duration duration;
    SnackPosition position;

    // Determine background based on context
    final isDarkScreen = context != null && _isDarkScreen(context);

    // Set position based on screen type
    position = isDarkScreen ? SnackPosition.BOTTOM : SnackPosition.TOP;

    switch (type) {
      case SnackbarType.success:
        backgroundColor = isDarkScreen
            ? AppTheme.success.withValues(alpha: 0.95)
            : AppTheme.success;
        textColor = Colors.white;
        iconData = Icons.check_circle;
        duration = Duration(seconds: 2);
        break;
      case SnackbarType.error:
        backgroundColor = isDarkScreen
            ? AppTheme.error.withValues(alpha: 0.95)
            : AppTheme.error;
        textColor = Colors.white;
        iconData = Icons.error;
        duration = Duration(seconds: 4);
        break;
      case SnackbarType.warning:
        backgroundColor = isDarkScreen
            ? AppTheme.warning.withValues(alpha: 0.95)
            : AppTheme.warning;
        textColor = Colors.white;
        iconData = Icons.warning_amber;
        duration = Duration(seconds: 3);
        break;
      case SnackbarType.info:
        backgroundColor = isDarkScreen
            ? AppTheme.info.withValues(alpha: 0.95)
            : AppTheme.info;
        textColor = Colors.white;
        iconData = Icons.info;
        duration = Duration(milliseconds: 1500);
        break;
    }

    Get.snackbar(
      title ?? _getDefaultTitle(type),
      message,
      backgroundColor: backgroundColor,
      colorText: textColor,
      duration: duration,
      snackPosition: position, // Context-aware positioning
      margin: EdgeInsets.all(16),
      borderRadius: AppTheme.radiusMedium,
      icon: Icon(iconData, color: textColor),
      shouldIconPulse: false,
      barBlur: isDarkScreen ? 15 : 10, // More blur on dark screens
    );
  }

  // Show loading message (dismissible manually)
  static void showLoading(String message) {
    _dismissCurrentSnackbar();
    Get.snackbar(
      'Please Wait',
      message,
      backgroundColor: AppTheme.primaryPurple,
      colorText: Colors.white,
      duration: Duration(seconds: 30), // Long duration, dismiss manually
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16),
      borderRadius: AppTheme.radiusMedium,
      showProgressIndicator: true,
      progressIndicatorBackgroundColor: Colors.white.withValues(alpha: 0.3),
      progressIndicatorValueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      shouldIconPulse: false,
      barBlur: 10,
      isDismissible: false,
    );
  }

  // Dismiss current snackbar
  static void dismiss() {
    _dismissCurrentSnackbar();
  }

  // Private helpers
  static void _dismissCurrentSnackbar() {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
  }

  static bool _isDarkScreen(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name;
    return route == '/recognition';
  }

  static String _getDefaultTitle(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return 'Success';
      case SnackbarType.error:
        return 'Error';
      case SnackbarType.warning:
        return 'Warning';
      case SnackbarType.info:
        return 'Info';
    }
  }

  // Quick methods for common use cases
  static void successShort(String message) => showInfo(message);
  static void errorLong(String message) => showError(message);

  // Face recognition specific messages
  static void faceDetected(int count) {
    if (count == 1) {
      showSuccess('1 face detected successfully');
    } else {
      showSuccess('$count faces detected successfully');
    }
  }

  static void faceRecognized(String name, double confidence) {
    showSuccess(
      '${name} recognized (${confidence.toStringAsFixed(0)}% confidence)',
    );
  }

  static void faceSaved(String name) {
    showSuccess('${name} saved to database');
  }

  static void databaseCleared() {
    showInfo('Database cleared');
  }

  // Reduced noise - only show important messages
  static void showCriticalOnly(String message, SnackbarType type) {
    if (type == SnackbarType.error || type == SnackbarType.success) {
      showContextAware(message, type);
    }
    // Skip info and warning for less noise
  }
}
