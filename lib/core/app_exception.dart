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

  /// Code caused by requested lecturer not found in db
  lecturerNotFound,

  /// Code caused by new lecturer have existing name in the program
  lecturerAlreadyExists,

  /// Code caused by requested course not found in db
  courseNotFound,

  /// Code caused by new course have existing code in the program
  courseAlreadyExists,

  /// Code caused by requested room not found in db
  roomNotFound,

  /// Code caused by new room have existing name in the faculty
  roomAlreadyExists,

  /// Code caused by requested academic year not found in db
  academicYearNotFound,

  /// Code caused by new academic year have existing name
  academicYearAlreadyExists,

  /// Code caused by requested academic term not found in db
  academicTermNotFound,

  /// Code caused by new academic term have existing name in the academic year
  academicTermAlreadyExists,

  /// Code caused by new academic term overlapped with existing terms
  academicTermOverlapped,

  /// Code caused by academic term date outside the academic year
  academicTermOutsideYear,

  /// Code caused by requested cohort not found in db
  cohortNotFound,

  /// Code caused by new cohort have existing name
  cohortAlreadyExists,
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
