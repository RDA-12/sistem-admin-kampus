import 'package:sistem_admin/core/core.dart';

/// Helper to get message based on [AppExceptionCode]
extension ExceptionMessageX on AppExceptionCode {
  /// Returns message to be shown to user for this code
  String get message => switch (this) {
    AppExceptionCode.internal =>
      'Terjadi kesalahan internal. Harap coba lagi nanti',
    AppExceptionCode.server =>
      'Terjadi kesalahan di server. Harap coba lagi nanti',
    AppExceptionCode.facultyNotFound => 'Fakultas tidak dapat ditemukan',
    AppExceptionCode.facultyAlreadyExists =>
      'Fakultas dengan nama tersebut sudah ada',
    AppExceptionCode.programNotFound => 'Program studi tidak dapat ditemukan',
    AppExceptionCode.programAlreadyExists =>
      'Program studi dengan nama tersebut sudah ada pada fakultas ini',
  };
}
