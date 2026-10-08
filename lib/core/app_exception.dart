import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Possible exception codes
enum AppExceptionCode {
  /// Code caused by unintended error
  internal,

  /// Code caused by server error
  server,

  /// Code caused by access control check fail
  ///
  /// It means current user doesn't have enough permission
  /// to do some action on some resource.
  accessControlCheckFail,
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
