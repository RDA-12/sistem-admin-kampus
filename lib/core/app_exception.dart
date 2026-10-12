import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Possible exception codes
enum AppExceptionCode {
  /// Code caused by unintended error
  internal,

  /// Code caused by server error
  server,

  /// Code caused by requested faculty not found in db
  facultyNotFound,

  /// Code caused by new faculty have existing name
  facultyAlreadyExists,

  /// Code caused by requested program not found in db
  programNotFound,

  /// Code caused by new program have existing name in the faculty
  programAlreadyExists,
}

/// Exception class for this app
class AppException extends Equatable implements Exception {
  /// Creates new [AppException]
  const new(this.message, {required this.code});

  /// Creates new [AppException] for testing purposes
  @visibleForTesting
  factory test() => const AppException('message', code: .internal);

  /// Code of this exception
  final AppExceptionCode code;

  /// Message to be shown to developer
  ///
  /// Typically it shows the error message.
  final String message;

  @override
  List<Object?> get props => [code];
}
