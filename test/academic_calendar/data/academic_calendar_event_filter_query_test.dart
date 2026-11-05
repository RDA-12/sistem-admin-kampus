import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';

void main() {
  late AppDriftDatabase database;

  setUp(() {
    database = AppDriftDatabase.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
  });

  tearDown(() async {
    await database.close();
  });

  group('AcademicCalendarEventFilterX', () {
    const year1Id = 'year_1';
    const year2Id = 'year_2';
    final date = DateTime(2025, 9);

    setUp(() async {
      await database.into(database.academicYearsDrift).insert(
        AcademicYearsDriftCompanion.insert(
          id: year1Id,
          name: '2025/2026',
          startDate: date,
          endDate: DateTime(2026, 8, 31),
        ),
      );
      await database.into(database.academicYearsDrift).insert(
        AcademicYearsDriftCompanion.insert(
          id: year2Id,
          name: '2026/2027',
          startDate: DateTime(2026, 9),
          endDate: DateTime(2027, 8, 31),
        ),
      );
      await database.into(database.academicCalendarEventsDrift).insert(
        AcademicCalendarEventsDriftCompanion.insert(
          id: 'event_1',
          academicYearId: year1Id,
          name: 'Event 1',
          type: AcademicCalendarEventType.holiday,
          startDate: date,
          startHour: 8,
          startMinute: 0,
          endDate: date,
          endHour: 17,
          endMinute: 0,
        ),
      );
      await database.into(database.academicCalendarEventsDrift).insert(
        AcademicCalendarEventsDriftCompanion.insert(
          id: 'event_2',
          academicYearId: year2Id,
          name: 'Event 2',
          type: AcademicCalendarEventType.general,
          startDate: DateTime(2026, 10),
          startHour: 9,
          startMinute: 0,
          endDate: DateTime(2026, 10),
          endHour: 12,
          endMinute: 0,
        ),
      );
    });

    test('applies where clause when academicYearId is provided', () async {
      final initialQuery = database.select(
        database.academicCalendarEventsDrift,
      );
      final query = const AcademicCalendarEventFilter(
        academicYearId: year1Id,
      ).apply(initialQuery);
      final result = await query.get();

      expect(result.length, 1);
      expect(result.first.id, 'event_1');
      expect(result.first.academicYearId, year1Id);
    });

    test('returns unmodified query when academicYearId is null', () async {
      final initialQuery = database.select(
        database.academicCalendarEventsDrift,
      );
      final query = const AcademicCalendarEventFilter().apply(initialQuery);
      final result = await query.get();

      expect(result.length, 2);
      expect(result.map((e) => e.id), containsAll(['event_1', 'event_2']));
    });
  });
}
