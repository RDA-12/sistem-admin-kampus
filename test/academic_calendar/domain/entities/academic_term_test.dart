import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';

void main() {
  group('AcademicTerm', () {
    test('equal on id, academicYearId, name, startDate, and endDate', () {
      final start = DateTime(2025, 9);
      final end = DateTime(2026, 1, 31);
      final testObj = AcademicTerm(
        id: 'id',
        academicYearId: 'year_1',
        name: 'Ganjil',
        startDate: start,
        endDate: end,
      );
      final a = AcademicTerm(
        id: 'id',
        academicYearId: 'year_1',
        name: 'Ganjil',
        startDate: start,
        endDate: end,
      );
      final b = AcademicTerm(
        id: 'id B',
        academicYearId: 'year_1',
        name: 'Ganjil',
        startDate: start,
        endDate: end,
      );
      final c = AcademicTerm(
        id: 'id',
        academicYearId: 'year_2',
        name: 'Ganjil',
        startDate: start,
        endDate: end,
      );
      final d = AcademicTerm(
        id: 'id',
        academicYearId: 'year_1',
        name: 'Genap',
        startDate: start,
        endDate: end,
      );
      final e = AcademicTerm(
        id: 'id',
        academicYearId: 'year_1',
        name: 'Ganjil',
        startDate: DateTime(2025, 8),
        endDate: end,
      );
      final f = AcademicTerm(
        id: 'id',
        academicYearId: 'year_1',
        name: 'Ganjil',
        startDate: start,
        endDate: DateTime(2026, 2, 28),
      );

      expect(testObj, equals(a));
      expect(testObj, isNot(equals(b)));
      expect(testObj, isNot(equals(c)));
      expect(testObj, isNot(equals(d)));
      expect(testObj, isNot(equals(e)));
      expect(testObj, isNot(equals(f)));
    });
  });
}
