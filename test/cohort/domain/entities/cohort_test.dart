import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/cohort/cohort.dart';

void main() {
  group('Cohort', () {
    test('equal on id, name, and entryYear', () {
      const testObj = Cohort(id: 'id', name: 'name', entryYear: 2020);
      const a = Cohort(id: 'id', name: 'name', entryYear: 2020);
      const b = Cohort(id: 'id', name: 'name B', entryYear: 2020);
      const c = Cohort(id: 'id C', name: 'name', entryYear: 2020);
      const d = Cohort(id: 'id', name: 'name', entryYear: 2021);

      expect(testObj, equals(a));
      expect(testObj, isNot(equals(b)));
      expect(testObj, isNot(equals(c)));
      expect(testObj, isNot(equals(d)));
    });
  });
}
