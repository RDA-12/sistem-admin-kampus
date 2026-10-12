import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/program/program.dart';

void main() {
  group('Program', () {
    test('equal on id, facultyId, and name', () {
      const testObj = Program(id: 'id', facultyId: 'faculty_1', name: 'name');
      const a = Program(id: 'id', facultyId: 'faculty_1', name: 'name');
      const b = Program(id: 'id', facultyId: 'faculty_1', name: 'name B');
      const c = Program(id: 'id C', facultyId: 'faculty_1', name: 'name');
      const d = Program(id: 'id', facultyId: 'faculty_2', name: 'name');

      expect(testObj, equals(a));
      expect(testObj, isNot(equals(b)));
      expect(testObj, isNot(equals(c)));
      expect(testObj, isNot(equals(d)));
    });
  });
}
