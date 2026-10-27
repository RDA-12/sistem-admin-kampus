import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';

void main() {
  group('AcademicCalendar', () {
    final year = AcademicYear(
      id: 'year_1',
      name: '2025/2026',
      startDate: DateTime(2025, 9),
      endDate: DateTime(2026, 8, 31),
    );

    final term1 = AcademicTerm(
      id: 'term_1',
      academicYearId: 'year_1',
      name: 'Ganjil',
      startDate: DateTime(2025, 9),
      endDate: DateTime(2026, 1, 31),
    );

    final term2 = AcademicTerm(
      id: 'term_2',
      academicYearId: 'year_1',
      name: 'Genap',
      startDate: DateTime(2026, 2),
      endDate: DateTime(2026, 6, 30),
    );

    test('equal on year and terms', () {
      final calendar1 = AcademicCalendar(year: year, terms: [term1]);
      final calendar2 = AcademicCalendar(year: year, terms: [term1]);
      final differentYear = AcademicCalendar(
        year: AcademicYear(
          id: 'year_2',
          name: '2026/2027',
          startDate: DateTime(2026, 9),
          endDate: DateTime(2027, 8, 31),
        ),
        terms: [term1],
      );
      final differentTerms = AcademicCalendar(
        year: year,
        terms: [term1, term2],
      );

      expect(calendar1, equals(calendar2));
      expect(calendar1, isNot(equals(differentYear)));
      expect(calendar1, isNot(equals(differentTerms)));
    });

    group('canAddNewTerm', () {
      test('returns true when terms list is empty', () {
        final calendar = AcademicCalendar(year: year, terms: const []);
        final canAdd = calendar.canAddNewTerm(
          startDate: DateTime(2025, 9),
          endDate: DateTime(2026, 1, 31),
        );

        expect(canAdd, isTrue);
      });

      test(
        'returns true when new term does not overlap with existing terms',
        () {
          final calendar = AcademicCalendar(year: year, terms: [term1]);
          final canAdd = calendar.canAddNewTerm(
            startDate: DateTime(2026, 2),
            endDate: DateTime(2026, 6, 30),
          );

          expect(canAdd, isTrue);
        },
      );

      test('returns false when new term overlaps with an existing term', () {
        final calendar = AcademicCalendar(year: year, terms: [term1, term2]);
        final canAdd = calendar.canAddNewTerm(
          startDate: DateTime(2025, 10),
          endDate: DateTime(2025, 12, 31),
        );

        expect(canAdd, isFalse);
      });

      test(
        'returns false when new term partially overlaps with second term',
        () {
          final calendar = AcademicCalendar(year: year, terms: [term1, term2]);
          final canAdd = calendar.canAddNewTerm(
            startDate: DateTime(2026, 6),
            endDate: DateTime(2026, 7, 31),
          );

          expect(canAdd, isFalse);
        },
      );
    });

    group('canUpdateTerm', () {
      test(
        'returns true when terms list only contains the term being updated',
        () {
          final calendar = AcademicCalendar(year: year, terms: [term1]);
          final canUpdate = calendar.canUpdateTerm(
            term: term1,
            startDate: DateTime(2025, 9),
            endDate: DateTime(2026, 1, 31),
          );

          expect(canUpdate, isTrue);
        },
      );

      test(
        'returns true when updated term does not overlap with other terms',
        () {
          final calendar = AcademicCalendar(year: year, terms: [term1, term2]);
          final canUpdate = calendar.canUpdateTerm(
            term: term1,
            startDate: DateTime(2025, 8),
            endDate: DateTime(2026, 1, 15),
          );

          expect(canUpdate, isTrue);
        },
      );

      test('returns false when updated term overlaps with another term', () {
        final calendar = AcademicCalendar(year: year, terms: [term1, term2]);
        final canUpdate = calendar.canUpdateTerm(
          term: term1,
          startDate: DateTime(2025, 9),
          endDate: DateTime(2026, 3),
        );

        expect(canUpdate, isFalse);
      });
    });
  });
}
