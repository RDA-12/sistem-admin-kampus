import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';

void main() {
  final start = DateTime(2025, 9);
  final end = DateTime(2026, 8, 31);

  group('StringListConverter', () {
    const converter = StringListConverter();

    test('fromSql returns empty list when input is empty string', () {
      expect(converter.fromSql(''), isEmpty);
    });

    test('fromSql returns parsed list of strings from JSON', () {
      expect(
        converter.fromSql('["RRULE:FREQ=DAILY","EXDATE:20250901"]'),
        equals(['RRULE:FREQ=DAILY', 'EXDATE:20250901']),
      );
    });

    test('toSql returns encoded JSON string', () {
      expect(
        converter.toSql(['RRULE:FREQ=DAILY']),
        equals('["RRULE:FREQ=DAILY"]'),
      );
    });
  });

  group('AcademicYearToDomainX', () {
    test('returns correct AcademicYear from AcademicYearDb', () {
      final expected = AcademicYear(
        id: 'id',
        name: '2025/2026',
        startDate: start,
        endDate: end,
      );

      final result = AcademicYearDb(
        id: 'id',
        name: '2025/2026',
        startDate: start,
        endDate: end,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(result.toDomain(), expected);
    });
  });

  group('AcademicYearToCompanionX', () {
    test(
      'returns correct AcademicYearsDriftCompanion from '
      'UpdateAcademicYearParams',
      () {
        final newStart = DateTime(2025, 10);
        final newEnd = DateTime(2026, 7, 31);
        final expected = AcademicYearsDriftCompanion(
          name: const Value('2026/2027'),
          startDate: Value(newStart),
          endDate: Value(newEnd),
        );
        final year = AcademicYear(
          id: 'id',
          name: '2025/2026',
          startDate: start,
          endDate: end,
        );
        final result = UpdateAcademicYearParams(
          year,
          name: '2026/2027',
          startDate: newStart,
          endDate: newEnd,
        ).toCompanion();

        expect(result, expected);

        final result2 = UpdateAcademicYearParams(year).toCompanion();

        expect(result2, const AcademicYearsDriftCompanion());
      },
    );
  });

  group('AcademicTermToDomainX', () {
    test('returns correct AcademicTerm from AcademicTermDb', () {
      final termStart = DateTime(2025, 9);
      final termEnd = DateTime(2026, 1, 31);
      final expected = AcademicTerm(
        id: 'id',
        academicYearId: 'year_1',
        name: 'Ganjil',
        startDate: termStart,
        endDate: termEnd,
      );

      final result = AcademicTermDb(
        id: 'id',
        academicYearId: 'year_1',
        name: 'Ganjil',
        startDate: termStart,
        endDate: termEnd,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(result.toDomain(), expected);
    });
  });

  group('AcademicTermToCompanionX', () {
    test(
      'returns correct AcademicTermsDriftCompanion from '
      'UpdateAcademicTermParams',
      () {
        final newStart = DateTime(2026, 2);
        final newEnd = DateTime(2026, 6, 30);
        final expected = AcademicTermsDriftCompanion(
          academicYearId: const Value('year_2'),
          name: const Value('Genap'),
          startDate: Value(newStart),
          endDate: Value(newEnd),
        );

        final term = AcademicTerm(
          id: 'id',
          academicYearId: 'year_1',
          name: 'Ganjil',
          startDate: DateTime(2025, 9),
          endDate: DateTime(2026, 1, 31),
        );

        final result = UpdateAcademicTermParams(
          term,
          academicYearId: 'year_2',
          name: 'Genap',
          startDate: newStart,
          endDate: newEnd,
        ).toCompanion();

        expect(result, expected);

        final result2 = UpdateAcademicTermParams(term).toCompanion();

        expect(result2, const AcademicTermsDriftCompanion());
      },
    );
  });

  group('AcademicCalendarEventToDomainX', () {
    test(
      'returns correct AcademicCalendarEvent from AcademicCalendarEventDb',
      () {
        final eventStart = DateTime(2025, 9);
        final eventEnd = DateTime(2025, 9, 2);
        final expected = AcademicCalendarEvent(
          id: 'id',
          academicYearId: 'year_1',
          name: 'Kuliah Perdana',
          type: AcademicCalendarEventType.publicLectures,
          start: EventDateTime(
            date: eventStart,
            time: const Time(hour: 8, minute: 30),
          ),
          end: EventDateTime(
            date: eventEnd,
            time: const Time(hour: 10, minute: 0),
          ),
        );

        final result = AcademicCalendarEventDb(
          id: 'id',
          academicYearId: 'year_1',
          name: 'Kuliah Perdana',
          type: AcademicCalendarEventType.publicLectures,
          startDate: eventStart,
          startHour: 8,
          startMinute: 30,
          endDate: eventEnd,
          endHour: 10,
          endMinute: 0,
          recurrence: const ['RRULE:FREQ=WEEKLY'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(result.toDomain(), expected);
      },
    );
  });

  group('AcademicCalendarEventToCompanionX', () {
    test(
      'returns correct AcademicCalendarEventsDriftCompanion from '
      'UpdateAcademicCalendarEventParams',
      () {
        final newStart = DateTime(2025, 9, 5);
        final newEnd = DateTime(2025, 9, 6);
        final expected = AcademicCalendarEventsDriftCompanion(
          academicYearId: const Value('year_2'),
          name: const Value('Kuliah Umum'),
          type: const Value(AcademicCalendarEventType.general),
          startDate: Value(newStart),
          startHour: const Value(9),
          startMinute: const Value(15),
          endDate: Value(newEnd),
          endHour: const Value(11),
          endMinute: const Value(45),
          recurrence: const Value(['RRULE:FREQ=MONTHLY']),
        );

        final event = AcademicCalendarEvent(
          id: 'id',
          academicYearId: 'year_1',
          name: 'Kuliah Perdana',
          type: AcademicCalendarEventType.publicLectures,
          start: EventDateTime(
            date: DateTime(2025, 9),
            time: const Time(hour: 8, minute: 30),
          ),
          end: EventDateTime(
            date: DateTime(2025, 9, 2),
            time: const Time(hour: 10, minute: 0),
          ),
        );

        final result = UpdateAcademicCalendarEventParams(
          event,
          academicYearId: 'year_2',
          name: 'Kuliah Umum',
          type: AcademicCalendarEventType.general,
          start: EventDateTime(
            date: newStart,
            time: const Time(hour: 9, minute: 15),
          ),
          end: EventDateTime(
            date: newEnd,
            time: const Time(hour: 11, minute: 45),
          ),
          recurrence: const ['RRULE:FREQ=MONTHLY'],
        ).toCompanion();

        expect(result, expected);

        final result2 = UpdateAcademicCalendarEventParams(event).toCompanion();

        expect(result2, const AcademicCalendarEventsDriftCompanion());
      },
    );
  });
}
