import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/room/room.dart';

void main() {
  group('Room', () {
    test('equal on id, facultyId, and name', () {
      const testObj = Room(id: 'id', facultyId: 'faculty_1', name: 'name');
      const a = Room(id: 'id', facultyId: 'faculty_1', name: 'name');
      const b = Room(id: 'id', facultyId: 'faculty_1', name: 'name B');
      const c = Room(id: 'id C', facultyId: 'faculty_1', name: 'name');
      const d = Room(id: 'id', facultyId: 'faculty_2', name: 'name');

      expect(testObj, equals(a));
      expect(testObj, isNot(equals(b)));
      expect(testObj, isNot(equals(c)));
      expect(testObj, isNot(equals(d)));
    });
  });
}
