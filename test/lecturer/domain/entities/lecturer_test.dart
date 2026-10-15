import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';

void main() {
  group('Lecturer', () {
    test('equal on id, programId, name, and pangkatGolongan', () {
      const testObj = Lecturer(
        id: 'id',
        programId: 'program_1',
        name: 'name',
        pangkatGolongan: 'III/a',
      );
      const a = Lecturer(
        id: 'id',
        programId: 'program_1',
        name: 'name',
        pangkatGolongan: 'III/a',
      );
      const b = Lecturer(
        id: 'id',
        programId: 'program_1',
        name: 'name B',
        pangkatGolongan: 'III/a',
      );
      const c = Lecturer(
        id: 'id C',
        programId: 'program_1',
        name: 'name',
        pangkatGolongan: 'III/a',
      );
      const d = Lecturer(
        id: 'id',
        programId: 'program_2',
        name: 'name',
        pangkatGolongan: 'III/a',
      );
      const e = Lecturer(
        id: 'id',
        programId: 'program_1',
        name: 'name',
        pangkatGolongan: 'III/b',
      );

      expect(testObj, equals(a));
      expect(testObj, isNot(equals(b)));
      expect(testObj, isNot(equals(c)));
      expect(testObj, isNot(equals(d)));
      expect(testObj, isNot(equals(e)));
    });
  });
}
