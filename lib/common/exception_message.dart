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
    AppExceptionCode.lecturerNotFound => 'Dosen tidak dapat ditemukan',
    AppExceptionCode.lecturerAlreadyExists =>
      'Dosen dengan nama tersebut sudah ada pada program studi ini',
    AppExceptionCode.courseNotFound => 'Mata kuliah tidak dapat ditemukan',
    AppExceptionCode.courseAlreadyExists =>
      'Mata kuliah dengan kode tersebut sudah ada pada program studi ini',
    AppExceptionCode.roomNotFound => 'Ruangan tidak dapat ditemukan',
    AppExceptionCode.roomAlreadyExists =>
      'Ruangan dengan nama tersebut sudah ada pada fakultas ini',
    AppExceptionCode.academicYearNotFound =>
      'Tahun akademik tidak dapat ditemukan',
    AppExceptionCode.academicYearAlreadyExists =>
      'Tahun akademik dengan nama tersebut sudah ada',
    AppExceptionCode.academicTermNotFound => 'Semester tidak dapat ditemukan',
    AppExceptionCode.academicTermAlreadyExists =>
      'Semester dengan nama tersebut sudah ada pada tahun akademik ini',
    AppExceptionCode.cohortNotFound => 'Angkatan tidak dapat ditemukan',
    AppExceptionCode.academicTermOverlapped =>
      'Semester tumpang tindih dengan yang lain',
    AppExceptionCode.cohortAlreadyExists =>
      'Angkatan dengan nama tersebut sudah ada',
  };
}
