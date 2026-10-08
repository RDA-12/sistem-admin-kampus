import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/faculty/faculty.dart';

void main() {
  group('Faculty', () {
    test('equal on id and name', () {
      const testObj = Faculty(id: 'id', name: 'name');
      const a = Faculty(id: 'id', name: 'name');
      const b = Faculty(id: 'id', name: 'name B');
      const c = Faculty(id: 'id C', name: 'name');

      expect(testObj, equals(a));
      expect(testObj, isNot(equals(b)));
      expect(testObj, isNot(equals(c)));
    });
  });
}
