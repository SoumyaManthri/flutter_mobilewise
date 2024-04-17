import 'dart:developer' as developer;

class MobiLog {
  static void v({required String tag, required String message, StackTrace? stacktrace}) {
    developer.log(message, name: tag, level: 300, stackTrace: stacktrace);
  }

  static void d({required String tag, required String message, StackTrace? stacktrace}) {
    developer.log(message, name: tag, level: 700, stackTrace: stacktrace);
  }

  static void i({required String tag, required String message, StackTrace? stacktrace}) {
    developer.log(message, name: tag, level: 800, stackTrace: stacktrace);
  }

  static void w({required String tag, required String message, StackTrace? stacktrace}) {
    developer.log(message, name: tag, level: 900, stackTrace: stacktrace);
  }

  static void e({required String tag, required String message, required Object? error, StackTrace? stackTrace}) {
    developer.log(message, name: tag, level: 1000, error: error, stackTrace: stackTrace);
  }
}
