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

    group('includes', () {
      final year = AcademicYear(
        id: 'year_1',
        name: '2025/2026',
        startDate: DateTime(2025, 9),
        endDate: DateTime(2026, 8, 31),
      );

      test('returns true when date is between startDate and endDate', () {
        expect(year.includes(DateTime(2026, 1, 15)), isTrue);
      });

      test('returns true when date equals startDate', () {
        expect(year.includes(DateTime(2025, 9)), isTrue);
      });

      test('returns true when date equals endDate', () {
        expect(year.includes(DateTime(2026, 8, 31)), isTrue);
      });

      test('returns false when date is before startDate', () {
        expect(year.includes(DateTime(2025, 8, 31)), isFalse);
      });

      test('returns false when date is after endDate', () {
        expect(year.includes(DateTime(2026, 9)), isFalse);
      });
    });
  });
}
