import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

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

    final event1 = AcademicCalendarEvent(
      id: 'event_1',
      academicYearId: 'year_1',
      name: 'Kuliah Perdana',
      type: AcademicCalendarEventType.lectures,
      start: EventDateTime(
        date: DateTime(2025, 9),
        time: const Time(hour: 8, minute: 0),
      ),
      end: EventDateTime(
        date: DateTime(2025, 9),
        time: const Time(hour: 10, minute: 0),
      ),
    );

    test('equal on year, terms, and events', () {
      final calendar1 = AcademicCalendar(
        year: year,
        terms: [term1],
        events: [event1],
      );
      final calendar2 = AcademicCalendar(
        year: year,
        terms: [term1],
        events: [event1],
      );
      final differentYear = AcademicCalendar(
        year: AcademicYear(
          id: 'year_2',
          name: '2026/2027',
          startDate: DateTime(2026, 9),
          endDate: DateTime(2027, 8, 31),
        ),
        terms: [term1],
        events: [event1],
      );
      final differentTerms = AcademicCalendar(
        year: year,
        terms: [term1, term2],
        events: [event1],
      );
      final differentEvents = AcademicCalendar(
        year: year,
        terms: [term1],
      );

      expect(calendar1, equals(calendar2));
      expect(calendar1, isNot(equals(differentYear)));
      expect(calendar1, isNot(equals(differentTerms)));
      expect(calendar1, isNot(equals(differentEvents)));
    });

    group('canAddTerm', () {
      test('returns success when terms list is empty', () {
        final calendar = AcademicCalendar(year: year);
        final result = calendar.canAddTerm(
          startDate: DateTime(2025, 9),
          endDate: DateTime(2026, 1, 31),
        );

        expect(result, AppResult.success(null));
      });

      test(
        'returns success when new term does not overlap with existing terms',
        () {
          final calendar = AcademicCalendar(year: year, terms: [term1]);
          final result = calendar.canAddTerm(
            startDate: DateTime(2026, 2),
            endDate: DateTime(2026, 6, 30),
          );

          expect(result, AppResult.success(null));
        },
      );

      test(
        'returns failure with academicTermOutsideYear when startDate is before '
        'academic year startDate',
        () {
          final calendar = AcademicCalendar(year: year);
          final result = calendar.canAddTerm(
            startDate: DateTime(2025, 8, 31),
            endDate: DateTime(2026, 1, 31),
          );

          expect(
            result,
            isA<AppFailure<Null>>().having(
              (e) => e.exception.code,
              'code',
              AppExceptionCode.academicTermOutsideYear,
            ),
          );
        },
      );

      test(
        'returns failure with academicTermOutsideYear when endDate is after '
        'academic year endDate',
        () {
          final calendar = AcademicCalendar(year: year);
          final result = calendar.canAddTerm(
            startDate: DateTime(2026, 2),
            endDate: DateTime(2026, 9),
          );

          expect(
            result,
            isA<AppFailure<Null>>().having(
              (e) => e.exception.code,
              'code',
              AppExceptionCode.academicTermOutsideYear,
            ),
          );
        },
      );

      test(
        'returns failure with academicTermOverlapped when new term overlaps '
        'with an existing term',
        () {
          final calendar = AcademicCalendar(year: year, terms: [term1, term2]);
          final result = calendar.canAddTerm(
            startDate: DateTime(2025, 10),
            endDate: DateTime(2025, 12, 31),
          );

          expect(
            result,
            isA<AppFailure<Null>>().having(
              (e) => e.exception.code,
              'code',
              AppExceptionCode.academicTermOverlapped,
            ),
          );
        },
      );

      test(
        'returns failure with academicTermOverlapped when new term partially '
        'overlaps with second term',
        () {
          final calendar = AcademicCalendar(year: year, terms: [term1, term2]);
          final result = calendar.canAddTerm(
            startDate: DateTime(2026, 6),
            endDate: DateTime(2026, 7, 31),
          );

          expect(
            result,
            isA<AppFailure<Null>>().having(
              (e) => e.exception.code,
              'code',
              AppExceptionCode.academicTermOverlapped,
            ),
          );
        },
      );
    });

    group('canUpdateTerm', () {
      test(
        'returns success when terms list only contains the term being updated',
        () {
          final calendar = AcademicCalendar(year: year, terms: [term1]);
          final result = calendar.canUpdateTerm(
            term: term1,
            startDate: DateTime(2025, 9),
            endDate: DateTime(2026, 1, 31),
          );

          expect(result, AppResult.success(null));
        },
      );

      test(
        'returns success when updated term does not overlap with other terms',
        () {
          final calendar = AcademicCalendar(year: year, terms: [term1, term2]);
          final result = calendar.canUpdateTerm(
            term: term1,
            startDate: DateTime(2025, 9, 15),
            endDate: DateTime(2026, 1, 15),
          );

          expect(result, AppResult.success(null));
        },
      );

      test(
        'returns failure with academicTermOutsideYear when startDate is before '
        'academic year startDate',
        () {
          final calendar = AcademicCalendar(year: year, terms: [term1]);
          final result = calendar.canUpdateTerm(
            term: term1,
            startDate: DateTime(2025, 8, 31),
            endDate: DateTime(2026, 1, 31),
          );

          expect(
            result,
            isA<AppFailure<Null>>().having(
              (e) => e.exception.code,
              'code',
              AppExceptionCode.academicTermOutsideYear,
            ),
          );
        },
      );

      test(
        'returns failure with academicTermOutsideYear when endDate is after '
        'academic year endDate',
        () {
          final calendar = AcademicCalendar(year: year, terms: [term1]);
          final result = calendar.canUpdateTerm(
            term: term1,
            startDate: DateTime(2025, 9),
            endDate: DateTime(2026, 9),
          );

          expect(
            result,
            isA<AppFailure<Null>>().having(
              (e) => e.exception.code,
              'code',
              AppExceptionCode.academicTermOutsideYear,
            ),
          );
        },
      );

      test(
        'returns failure with academicTermOverlapped when updated term '
        'overlaps with another term',
        () {
          final calendar = AcademicCalendar(year: year, terms: [term1, term2]);
          final result = calendar.canUpdateTerm(
            term: term1,
            startDate: DateTime(2025, 9),
            endDate: DateTime(2026, 3),
          );

          expect(
            result,
            isA<AppFailure<Null>>().having(
              (e) => e.exception.code,
              'code',
              AppExceptionCode.academicTermOverlapped,
            ),
          );
        },
      );
    });

    group('canAddEvent', () {
      test('returns success when event dates are within academic year', () {
        final calendar = AcademicCalendar(year: year);
        final result = calendar.canAddEvent(
          startDate: DateTime(2025, 10),
          endDate: DateTime(2025, 10, 2),
        );

        expect(result, AppResult.success(null));
      });

      test(
        'returns success when event dates match academic year boundaries',
        () {
          final calendar = AcademicCalendar(year: year);
          final result = calendar.canAddEvent(
            startDate: DateTime(2025, 9),
            endDate: DateTime(2026, 8, 31),
          );

          expect(result, AppResult.success(null));
        },
      );

      test(
        'returns failure with academicCalendarEventOutsideYear when startDate '
        'is before academic year startDate',
        () {
          final calendar = AcademicCalendar(year: year);
          final result = calendar.canAddEvent(
            startDate: DateTime(2025, 8, 31),
            endDate: DateTime(2025, 10),
          );

          expect(
            result,
            isA<AppFailure<Null>>().having(
              (e) => e.exception.code,
              'code',
              AppExceptionCode.academicCalendarEventOutsideYear,
            ),
          );
        },
      );

      test(
        'returns failure with academicCalendarEventOutsideYear when endDate '
        'is after academic year endDate',
        () {
          final calendar = AcademicCalendar(year: year);
          final result = calendar.canAddEvent(
            startDate: DateTime(2025, 10),
            endDate: DateTime(2026, 9),
          );

          expect(
            result,
            isA<AppFailure<Null>>().having(
              (e) => e.exception.code,
              'code',
              AppExceptionCode.academicCalendarEventOutsideYear,
            ),
          );
        },
      );
    });

    group('canUpdateEvent', () {
      test(
        'returns success when updated event dates are within academic year',
        () {
          final calendar = AcademicCalendar(year: year);
          final result = calendar.canUpdateEvent(
            startDate: DateTime(2025, 11),
            endDate: DateTime(2025, 11, 2),
          );

          expect(result, AppResult.success(null));
        },
      );

      test(
        'returns failure with academicCalendarEventOutsideYear when startDate '
        'is before academic year startDate',
        () {
          final calendar = AcademicCalendar(year: year);
          final result = calendar.canUpdateEvent(
            startDate: DateTime(2025, 8),
            endDate: DateTime(2025, 10),
          );

          expect(
            result,
            isA<AppFailure<Null>>().having(
              (e) => e.exception.code,
              'code',
              AppExceptionCode.academicCalendarEventOutsideYear,
            ),
          );
        },
      );

      test(
        'returns failure with academicCalendarEventOutsideYear when endDate '
        'is after academic year endDate',
        () {
          final calendar = AcademicCalendar(year: year);
          final result = calendar.canUpdateEvent(
            startDate: DateTime(2025, 10),
            endDate: DateTime(2026, 9),
          );

          expect(
            result,
            isA<AppFailure<Null>>().having(
              (e) => e.exception.code,
              'code',
              AppExceptionCode.academicCalendarEventOutsideYear,
            ),
          );
        },
      );
    });
  });
}
