import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/course/course.dart';

void main() {
  group('Course', () {
    test('equal on id, programId, code, name, semester, and credit', () {
      const testObj = Course(
        id: 'id',
        programId: 'program_1',
        code: 'CS101',
        name: 'Pemrograman Dasar',
        semester: 1,
        credit: 3,
      );
      const a = Course(
        id: 'id',
        programId: 'program_1',
        code: 'CS101',
        name: 'Pemrograman Dasar',
        semester: 1,
        credit: 3,
      );
      const b = Course(
        id: 'id B',
        programId: 'program_1',
        code: 'CS101',
        name: 'Pemrograman Dasar',
        semester: 1,
        credit: 3,
      );
      const c = Course(
        id: 'id',
        programId: 'program_2',
        code: 'CS101',
        name: 'Pemrograman Dasar',
        semester: 1,
        credit: 3,
      );
      const d = Course(
        id: 'id',
        programId: 'program_1',
        code: 'CS102',
        name: 'Pemrograman Dasar',
        semester: 1,
        credit: 3,
      );
      const e = Course(
        id: 'id',
        programId: 'program_1',
        code: 'CS101',
        name: 'Pemrograman Lanjut',
        semester: 1,
        credit: 3,
      );
      const f = Course(
        id: 'id',
        programId: 'program_1',
        code: 'CS101',
        name: 'Pemrograman Dasar',
        semester: 2,
        credit: 3,
      );
      const g = Course(
        id: 'id',
        programId: 'program_1',
        code: 'CS101',
        name: 'Pemrograman Dasar',
        semester: 1,
        credit: 2,
      );

      expect(testObj, equals(a));
      expect(testObj, isNot(equals(b)));
      expect(testObj, isNot(equals(c)));
      expect(testObj, isNot(equals(d)));
      expect(testObj, isNot(equals(e)));
      expect(testObj, isNot(equals(f)));
      expect(testObj, isNot(equals(g)));
    });
  });
}
