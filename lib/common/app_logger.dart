import 'dart:async';
import 'dart:developer';

import 'package:logging/logging.dart';
import 'package:sistem_admin/common/common.dart';

/// Key for trace id which provided within a `runZoned`
const traceIdKey = #traceIdKey;

/// Represent single logger message
///
/// This model will be passed to logger
final class _LoggerMessage {
  /// Creates new [_LoggerMessage]
  new({
    required this.message,
    required this.traceId,
    this.extra,
    this.error,
    this.stackTrace,
  });

  /// Message that will be showed to output medium
  final String message;

  /// ID to trace all related log messages
  final String traceId;

  /// Extra data that will be included
  final Map<String, Object?>? extra;

  /// Error object
  final Object? error;

  /// Stack trace object
  final StackTrace? stackTrace;
}

/// Logger for this app
class AppLogger {
  /// Creates new [AppLogger]
  new({required String name}) : _logger = Logger(name);

  final Logger _logger;

  /// Initialize [AppLogger]
  ///
  /// Should only be called once, typically before `runApp`
  static void initialize() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      final msg = record.object;
      final level = record.level;
      final name = record.loggerName;
      final timestamp = record.time;
      if (msg is _LoggerMessage) {
        log(
          '[${msg.traceId}] [$level] [${timestamp.toIso8601String()}] [$name] '
          '${msg.message}',
        );
        log('[${msg.traceId}] --- EXTRA ---');
        for (final it in (msg.extra ?? {}).entries) {
          log('[${msg.traceId}] ${it.key}: ${it.value}');
        }
        log('[${msg.traceId}] --- END of EXTRA ---');
        if (msg.error != null) {
          log('[${msg.traceId}] --- ERROR ---');
          log('[${msg.traceId}] ${msg.error}');
          log('[${msg.traceId}] --- END of ERROR ---');
        }
        if (msg.stackTrace != null) {
          log('[${msg.traceId}] --- STACK TRACE ---');
          log('[${msg.traceId}] ${msg.stackTrace}');
          log('[${msg.traceId}] --- END of STACK TRACE ---');
        }
      } else {
        log('[$level] [${timestamp.toIso8601String()}] [$name] $msg');
      }
    });
  }

  /// Run [callback] with access to traceId from `Zone.current[traceIdKey]`
  ///
  /// Typically used in a BLoC and all its descendant/later function can use
  /// [AppLoggerMixin] to automatically get the traceId.
  ///
  /// Example:
  /// ```dart
  /// // bloc.dart
  /// class FooBloc extends Bloc<FooBloc, FooState> with AppLoggerMixin {
  /// // Other code
  ///   Future<void> _onFooRequested(
  ///     FooRequested event,
  ///     Emitter<FooState> emit,
  ///   ) async {
  ///     await AppLogger.runWithLogger(() async {
  ///       logDebug('Start doing something on bar');
  ///       await bar.something();
  ///       emit(FooState());
  ///     });
  ///   }
  /// // Other code
  /// }
  ///
  /// // bar.dart
  /// class Bar with AppLoggerMixin {
  /// // Other code
  ///   Future<void> something() {
  ///     logDebug('Bar is doing something'. extra: {'bar': 'something'});
  ///   }
  /// // Other code
  /// }
  /// ```
  static R runWithLogger<R>(R Function() callback) {
    final traceId = getIt<UidGenerator>().generate();
    return runZoned<R>(
      callback,
      zoneValues: {traceIdKey: traceId},
    );
  }

  /// Log [message] in debug level
  void debug(
    String message, {
    required String traceId,
    Map<String, Object?>? extra,
  }) {
    final obj = _LoggerMessage(
      message: message,
      traceId: traceId,
      extra: extra,
    );
    _logger.fine(obj);
  }

  /// Log [message] in info level
  void info(
    String message, {
    required String traceId,
    Map<String, Object?>? extra,
  }) {
    final obj = _LoggerMessage(
      message: message,
      traceId: traceId,
      extra: extra,
    );
    _logger.info(obj);
  }

  /// Log [message] in error level
  void error(
    String message, {
    required String traceId,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? extra,
  }) {
    final obj = _LoggerMessage(
      message: message,
      traceId: traceId,
      error: error,
      stackTrace: stackTrace,
      extra: extra,
    );
    _logger.severe(obj, error, stackTrace);
  }
}

/// Helper to provide log functionality
mixin AppLoggerMixin {
  AppLogger get _logger => AppLogger(name: runtimeType.toString());

  /// Returns current traceId
  String get traceId => Zone.current[traceIdKey] as String? ?? 'no-trace-id';

  /// Log [message] in debug level
  void logDebug(
    String message, {
    Map<String, Object?>? extra,
  }) {
    _logger.debug(message, traceId: traceId, extra: extra);
  }

  /// Log [message] in info level
  void logInfo(
    String message, {
    Map<String, Object?>? extra,
  }) {
    _logger.info(message, traceId: traceId, extra: extra);
  }

  /// Log [message] in error level
  void logError(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? extra,
  }) {
    _logger.error(
      message,
      traceId: traceId,
      error: error,
      stackTrace: stackTrace,
      extra: extra,
    );
  }
}
