import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

void main() {
  final expectedMessage = <AppExceptionCode, String>{
    .internal: 'Terjadi kesalahan internal. Harap coba lagi nanti',
    .server: 'Terjadi kesalahan di server. Harap coba lagi nanti',
    .facultyAlreadyExists: 'Fakultas dengan nama tersebut sudah ada',
    .facultyNotFound: 'Fakultas tidak dapat ditemukan',
    .programNotFound: 'Program studi tidak dapat ditemukan',
    .programAlreadyExists:
        'Program studi dengan nama tersebut sudah ada pada fakultas ini',
    .lecturerNotFound: 'Dosen tidak dapat ditemukan',
    .lecturerAlreadyExists:
        'Dosen dengan nama tersebut sudah ada pada program studi ini',
    .courseNotFound: 'Mata kuliah tidak dapat ditemukan',
    .courseAlreadyExists:
        'Mata kuliah dengan kode tersebut sudah ada pada program studi ini',
    .roomNotFound: 'Ruangan tidak dapat ditemukan',
    .roomAlreadyExists:
        'Ruangan dengan nama tersebut sudah ada pada fakultas ini',
    .academicYearNotFound: 'Tahun akademik tidak dapat ditemukan',
    .academicYearAlreadyExists: 'Tahun akademik dengan nama tersebut sudah ada',
    .academicTermNotFound: 'Semester tidak dapat ditemukan',
    .academicTermAlreadyExists:
        'Semester dengan nama tersebut sudah ada pada tahun akademik ini',
    .academicTermOverlapped: 'Semester tumpang tindih dengan yang lain',
    .academicTermOutsideYear: 'Semester berada di luar rentang tahun akademik',
    .academicCalendarEventNotFound:
        'Kegiatan kalender akademik tidak dapat ditemukan',
    .academicCalendarEventOutsideYear:
        'Kegiatan kalender akademik berada di luar rentang tahun akademik',
    .cohortNotFound: 'Angkatan tidak dapat ditemukan',
    .cohortAlreadyExists: 'Angkatan dengan nama tersebut sudah ada',
    .courseScheduleNotFound: 'Jadwal kuliah tidak dapat ditemukan',
    .courseScheduleCollided: 'Jadwal kuliah bentrok dengan yang lain',
  };

  group('AppExceptionCode.message', () {
    for (final code in AppExceptionCode.values) {
      test('$code.message return corrects message', () {
        final expected = expectedMessage[code];

        final actual = code.message;

        expect(actual, expected);
      });
    }
  });
}
