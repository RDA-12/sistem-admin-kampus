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

    group('overlapWith', () {
      final term = AcademicTerm(
        id: 'term_1',
        academicYearId: 'year_1',
        name: 'Ganjil',
        startDate: DateTime(2025, 9),
        endDate: DateTime(2026, 1, 31),
      );

      test('returns false when both dates are before term', () {
        final result = term.overlapWith(
          startDate: DateTime(2025, 7),
          endDate: DateTime(2025, 8, 31),
        );
        expect(result, isFalse);
      });

      test('returns false when both dates are after term', () {
        final result = term.overlapWith(
          startDate: DateTime(2026, 2),
          endDate: DateTime(2026, 6, 30),
        );
        expect(result, isFalse);
      });

      test('returns true when dates fall entirely within term', () {
        final result = term.overlapWith(
          startDate: DateTime(2025, 10),
          endDate: DateTime(2025, 12, 31),
        );
        expect(result, isTrue);
      });

      test('returns true when dates enclose term', () {
        final result = term.overlapWith(
          startDate: DateTime(2025, 8),
          endDate: DateTime(2026, 2, 28),
        );
        expect(result, isTrue);
      });

      test(
        'returns true when startDate is before and endDate is within term',
        () {
          final result = term.overlapWith(
            startDate: DateTime(2025, 8),
            endDate: DateTime(2025, 10),
          );
          expect(result, isTrue);
        },
      );

      test(
        'returns true when startDate is within and endDate is after term',
        () {
          final result = term.overlapWith(
            startDate: DateTime(2025, 12),
            endDate: DateTime(2026, 3),
          );
          expect(result, isTrue);
        },
      );

      test('returns true when dates match term exactly', () {
        final result = term.overlapWith(
          startDate: DateTime(2025, 9),
          endDate: DateTime(2026, 1, 31),
        );
        expect(result, isTrue);
      });

      test('returns true when startDate touches term endDate', () {
        final result = term.overlapWith(
          startDate: DateTime(2026, 1, 31),
          endDate: DateTime(2026, 5),
        );
        expect(result, isTrue);
      });

      test('returns true when endDate touches term startDate', () {
        final result = term.overlapWith(
          startDate: DateTime(2025, 5),
          endDate: DateTime(2025, 9),
        );
        expect(result, isTrue);
      });

      test(
        'returns true when only startDate is provided and is within term',
        () {
          expect(
            term.overlapWith(startDate: DateTime(2025, 10)),
            isTrue,
          );
        },
      );

      test(
        'returns false when only startDate is provided and is outside term',
        () {
          expect(
            term.overlapWith(startDate: DateTime(2026, 2)),
            isFalse,
          );
        },
      );

      test(
        'returns true when only endDate is provided and is within term',
        () {
          expect(
            term.overlapWith(endDate: DateTime(2025, 10)),
            isTrue,
          );
        },
      );

      test(
        'returns false when only endDate is provided and is outside term',
        () {
          expect(
            term.overlapWith(endDate: DateTime(2025, 8)),
            isFalse,
          );
        },
      );

      test('returns false when neither date is provided', () {
        expect(term.overlapWith(), isFalse);
      });
    });
  });
}
