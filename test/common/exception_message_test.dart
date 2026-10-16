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
