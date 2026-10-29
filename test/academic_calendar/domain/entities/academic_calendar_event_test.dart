import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';

void main() {
  group('AcademicCalendarEvent', () {
    test(
      'equal on id, academicYearId, name, type, start, end, and recurrence',
      () {
        final start = EventDateTime(
          date: DateTime(2025, 9),
          time: const Time(hour: 8, minute: 0),
        );
        final end = EventDateTime(
          date: DateTime(2025, 9),
          time: const Time(hour: 10, minute: 0),
        );
        final testObj = AcademicCalendarEvent(
          id: 'id',
          academicYearId: 'year_1',
          name: 'Kuliah Perdana',
          type: AcademicCalendarEventType.lectures,
          start: start,
          end: end,
          recurrence: const ['RRULE:FREQ=WEEKLY'],
        );
        final a = AcademicCalendarEvent(
          id: 'id',
          academicYearId: 'year_1',
          name: 'Kuliah Perdana',
          type: AcademicCalendarEventType.lectures,
          start: start,
          end: end,
          recurrence: const ['RRULE:FREQ=WEEKLY'],
        );
        final b = AcademicCalendarEvent(
          id: 'id B',
          academicYearId: 'year_1',
          name: 'Kuliah Perdana',
          type: AcademicCalendarEventType.lectures,
          start: start,
          end: end,
          recurrence: const ['RRULE:FREQ=WEEKLY'],
        );
        final c = AcademicCalendarEvent(
          id: 'id',
          academicYearId: 'year_2',
          name: 'Kuliah Perdana',
          type: AcademicCalendarEventType.lectures,
          start: start,
          end: end,
          recurrence: const ['RRULE:FREQ=WEEKLY'],
        );
        final d = AcademicCalendarEvent(
          id: 'id',
          academicYearId: 'year_1',
          name: 'Kuliah Pengantar',
          type: AcademicCalendarEventType.lectures,
          start: start,
          end: end,
          recurrence: const ['RRULE:FREQ=WEEKLY'],
        );
        final e = AcademicCalendarEvent(
          id: 'id',
          academicYearId: 'year_1',
          name: 'Kuliah Perdana',
          type: AcademicCalendarEventType.holiday,
          start: start,
          end: end,
          recurrence: const ['RRULE:FREQ=WEEKLY'],
        );
        final f = AcademicCalendarEvent(
          id: 'id',
          academicYearId: 'year_1',
          name: 'Kuliah Perdana',
          type: AcademicCalendarEventType.lectures,
          start: EventDateTime(
            date: DateTime(2025, 9, 2),
            time: const Time(hour: 8, minute: 0),
          ),
          end: end,
          recurrence: const ['RRULE:FREQ=WEEKLY'],
        );
        final g = AcademicCalendarEvent(
          id: 'id',
          academicYearId: 'year_1',
          name: 'Kuliah Perdana',
          type: AcademicCalendarEventType.lectures,
          start: start,
          end: EventDateTime(
            date: DateTime(2025, 9),
            time: const Time(hour: 12, minute: 0),
          ),
          recurrence: const ['RRULE:FREQ=WEEKLY'],
        );
        final h = AcademicCalendarEvent(
          id: 'id',
          academicYearId: 'year_1',
          name: 'Kuliah Perdana',
          type: AcademicCalendarEventType.lectures,
          start: start,
          end: end,
          recurrence: const ['RRULE:FREQ=MONTHLY'],
        );

        expect(testObj, equals(a));
        expect(testObj, isNot(equals(b)));
        expect(testObj, isNot(equals(c)));
        expect(testObj, isNot(equals(d)));
        expect(testObj, isNot(equals(e)));
        expect(testObj, isNot(equals(f)));
        expect(testObj, isNot(equals(g)));
        expect(testObj, isNot(equals(h)));
      },
    );

    test('default recurrence is empty list', () {
      final start = EventDateTime(
        date: DateTime(2025, 9),
        time: const Time(hour: 8, minute: 0),
      );
      final end = EventDateTime(
        date: DateTime(2025, 9),
        time: const Time(hour: 10, minute: 0),
      );
      final event = AcademicCalendarEvent(
        id: 'id',
        academicYearId: 'year_1',
        name: 'Kuliah Perdana',
        type: AcademicCalendarEventType.lectures,
        start: start,
        end: end,
      );

      expect(event.recurrence, isEmpty);
    });
  });
}
