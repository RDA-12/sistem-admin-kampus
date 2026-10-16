import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';

void main() {
  group('AcademicYear', () {
    test('equal on id, name, startDate, and endDate', () {
      final start = DateTime(2025, 9);
      final end = DateTime(2026, 8, 31);
      final testObj = AcademicYear(
        id: 'id',
        name: '2025/2026',
        startDate: start,
        endDate: end,
      );
      final a = AcademicYear(
        id: 'id',
        name: '2025/2026',
        startDate: start,
        endDate: end,
      );
      final b = AcademicYear(
        id: 'id B',
        name: '2025/2026',
        startDate: start,
        endDate: end,
      );
      final c = AcademicYear(
        id: 'id',
        name: '2026/2027',
        startDate: start,
        endDate: end,
      );
      final d = AcademicYear(
        id: 'id',
        name: '2025/2026',
        startDate: DateTime(2025, 8),
        endDate: end,
      );
      final e = AcademicYear(
        id: 'id',
        name: '2025/2026',
        startDate: start,
        endDate: DateTime(2026, 7, 31),
      );

      expect(testObj, equals(a));
      expect(testObj, isNot(equals(b)));
      expect(testObj, isNot(equals(c)));
      expect(testObj, isNot(equals(d)));
      expect(testObj, isNot(equals(e)));
    });
  });
}
