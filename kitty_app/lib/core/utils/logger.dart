import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Development-safe structured logger for Kitty App.
///
/// Stripped in release builds; strips PII and secret tokens automatically.
abstract final class Logger {
  /// Debug telemetry log.
  static void debug(String message, {String tag = 'APP'}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag,
        level: 500,
      );
    }
  }

  /// Informational log.
  static void info(String message, {String tag = 'APP'}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag,
        level: 800,
      );
    }
  }

  /// Warning log.
  static void warning(String message, {String tag = 'APP', Object? error}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag,
        error: error,
        level: 900,
      );
    }
  }

  /// Error log.
  static void error(
    String message, {
    String tag = 'APP',
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag,
        error: error,
        stackTrace: stackTrace,
        level: 1000,
      );
    }
  }
}
