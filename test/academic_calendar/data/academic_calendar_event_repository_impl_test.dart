import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../../common/di_mocks.dart';
import '../../common/helper.dart';

void main() {
  final year = AcademicYear(
    id: 'year_1',
    name: '2025/2026',
    startDate: DateTime(2025, 9),
    endDate: DateTime(2026, 8, 31),
  );

  final eventStart = EventDateTime(
    date: DateTime(2025, 9),
    time: const Time(hour: 8, minute: 0),
  );
  final eventEnd = EventDateTime(
    date: DateTime(2025, 9),
    time: const Time(hour: 10, minute: 0),
  );

  final createdEvent = AcademicCalendarEvent(
    id: 'uid_event',
    academicYearId: year.id,
    name: 'Kuliah Perdana',
    type: AcademicCalendarEventType.lectures,
    start: eventStart,
    end: eventEnd,
  );

  final seededEvents = List.generate(
    2,
    (index) => AcademicCalendarEvent(
      id: 'event_$index',
      academicYearId: year.id,
      name: index == 0 ? 'Event 1' : 'Event 2',
      type: index == 0
          ? AcademicCalendarEventType.lectures
          : AcademicCalendarEventType.holiday,
      start: EventDateTime(
        date: DateTime(2025, 9, 10 + index),
        time: const Time(hour: 8, minute: 0),
      ),
      end: EventDateTime(
        date: DateTime(2025, 9, 10 + index),
        time: const Time(hour: 12, minute: 0),
      ),
    ),
  );

  late AcademicCalendarEventRepository repository;
  late UidGenerator uidGeneratorMock;
  late AppDriftDatabase database;

  setUpAll(initializeMockDependencies);

  setUp(() async {
    database = getIt<AppDriftDatabase>();
    await database
        .into(database.academicYearsDrift)
        .insert(
          AcademicYearsDriftCompanion.insert(
            id: year.id,
            name: year.name,
            startDate: year.startDate,
            endDate: year.endDate,
          ),
        );
    for (final e in seededEvents) {
      await database
          .into(database.academicCalendarEventsDrift)
          .insert(
            AcademicCalendarEventsDriftCompanion.insert(
              id: e.id,
              academicYearId: e.academicYearId,
              name: e.name,
              type: e.type,
              startDate: e.start.date,
              startHour: e.start.time.hour,
              startMinute: e.start.time.minute,
              endDate: e.end.date,
              endHour: e.end.time.hour,
              endMinute: e.end.time.minute,
            ),
          );
    }

    uidGeneratorMock = getIt<UidGenerator>();
    when(uidGeneratorMock.generate).thenReturn(createdEvent.id);

    repository = AcademicCalendarEventRepository(
      db: database,
      uidGenerator: uidGeneratorMock,
    );
  });

  tearDown(() async {
    await database.delete(database.academicCalendarEventsDrift).go();
    await database.delete(database.academicYearsDrift).go();
  });

  group('AcademicCalendarEventRepository', () {
    group('save', () {
      final createArgs = CreateAcademicCalendarEventParams(
        academicYearId: year.id,
        name: 'Kuliah Perdana',
        type: AcademicCalendarEventType.lectures,
        start: eventStart,
        end: eventEnd,
        recurrence: const ['RRULE:FREQ=WEEKLY'],
      );

      test('returns correct new event and saves it in db', () async {
        when(uidGeneratorMock.generate).thenReturn(createdEvent.id);
        final now = DateTime.now();
        await withClock(Clock.fixed(now), () async {
          final result = await repository.save(createArgs);

          expect(result, AppResult.success(createdEvent));

          final query = database.select(database.academicCalendarEventsDrift)
            ..where((tbl) => tbl.id.equals(createdEvent.id));
          final exists = await query.getSingleOrNull();
          expect(exists, isNotNull);
          expect(exists!.name, createArgs.name);
          expect(exists.academicYearId, createArgs.academicYearId);
          expect(exists.type, createArgs.type);
          expect(exists.startDate, createArgs.start.date);
          expect(exists.startHour, createArgs.start.time.hour);
          expect(exists.startMinute, createArgs.start.time.minute);
          expect(exists.endDate, createArgs.end.date);
          expect(exists.endHour, createArgs.end.time.hour);
          expect(exists.endMinute, createArgs.end.time.minute);
          expect(exists.recurrence, createArgs.recurrence);
          expect(exists.createdAt, now);
          expect(exists.updatedAt, now);
        });
      });

      test(
        'allows saving duplicate event name in same academic year',
        () async {
          when(uidGeneratorMock.generate).thenReturn('some_id_1');
          final first = await repository.save(createArgs);
          expect(first, isA<AppSuccess<AcademicCalendarEvent>>());

          when(uidGeneratorMock.generate).thenReturn('some_id_2');
          final second = await repository.save(createArgs);
          expect(second, isA<AppSuccess<AcademicCalendarEvent>>());
        },
      );

      test(
        'returns failure with internal code when exception occurs',
        () async {
          whenCalling(Invocation.method(#save, null))
              .on(repository)
              .thenThrow(Exception());

          final result = await repository.save(createArgs);

          result.expectFailureWithCode(AppExceptionCode.internal);
        },
      );
    });

    group('delete', () {
      test('returns success and deletes requested event', () async {
        final query = database.select(database.academicCalendarEventsDrift);
        final before = await query.get();
        expect(before.map((it) => it.toDomain()), seededEvents);

        final result = await repository.delete(seededEvents.first.id);

        expect(result, AppResult.success(null));

        final after = await query.get();
        expect(after.map((it) => it.toDomain()), seededEvents.sublist(1));
      });

      test(
        'returns success when deleting non-existent event',
        () async {
          final result = await repository.delete('non-existent');

          expect(result, AppResult.success(null));
        },
      );

      test(
        'returns failure with internal code when exception occurs',
        () async {
          whenCalling(Invocation.method(#delete, null))
              .on(repository)
              .thenThrow(Exception());

          final result = await repository.delete('any_id');

          result.expectFailureWithCode(AppExceptionCode.internal);
        },
      );
    });

    group('watch', () {
      test('emits correct academic calendar events', () async {
        final stream = repository.watch();

        expect(stream, emits(AppResult.success(seededEvents)));
      });

      test('emits failure when exception occurs', () async {
        whenCalling(Invocation.method(#watch, null))
            .on(repository)
            .thenThrow(Exception());

        final stream = repository.watch();

        expect(
          stream,
          emits(
            isA<AppFailure<List<AcademicCalendarEvent>>>().having(
              (e) => e.exception.code,
              'exception.code',
              AppExceptionCode.internal,
            ),
          ),
        );
      });
    });

    group('watch with filter', () {
      test(
        'emits correct academic calendar events for academic year',
        () async {
          final stream = repository.watch(
            AcademicCalendarEventFilter(academicYearId: year.id),
          );

          expect(stream, emits(AppResult.success(seededEvents)));
        },
      );

      test('emits failure when exception occurs', () async {
        whenCalling(Invocation.method(#watch, null))
            .on(repository)
            .thenThrow(Exception());

        final stream = repository.watch(
          AcademicCalendarEventFilter(academicYearId: year.id),
        );

        expect(
          stream,
          emits(
            isA<AppFailure<List<AcademicCalendarEvent>>>().having(
              (e) => e.exception.code,
              'exception.code',
              AppExceptionCode.internal,
            ),
          ),
        );
      });
    });

    group('watchSingle', () {
      test('emits correct academic calendar event when exists', () {
        final result = repository.watchSingle(seededEvents.first.id);

        expect(result, emits(AppResult.success(seededEvents.first)));
      });

      test(
        'emits failure with academicCalendarEventNotFound when not exists',
        () {
          final result = repository.watchSingle('not-exists');

          expect(
            result,
            emits(
              isA<AppFailure<AcademicCalendarEvent>>().having(
                (e) => e.exception.code,
                'exception.code',
                AppExceptionCode.academicCalendarEventNotFound,
              ),
            ),
          );
        },
      );
    });

    group('update', () {
      test('returns updated event and saves changes in db', () async {
        final expectedUpdated = AcademicCalendarEvent(
          id: seededEvents.first.id,
          academicYearId: seededEvents.first.academicYearId,
          name: 'Updated Event 1',
          type: seededEvents.first.type,
          start: seededEvents.first.start,
          end: seededEvents.first.end,
        );

        final updated = await repository.update(
          seededEvents.first.id,
          args: UpdateAcademicCalendarEventParams(
            seededEvents.first,
            name: 'Updated Event 1',
          ),
        );

        expect(updated, AppResult.success(expectedUpdated));

        final query = database.select(database.academicCalendarEventsDrift)
          ..where((tbl) => tbl.id.equals(seededEvents.first.id));
        final inDb = await query.getSingle();
        expect(inDb.name, 'Updated Event 1');
      });

      test(
        'returns failure with academicCalendarEventNotFound when '
        'updating non-existent',
        () async {
          final result = await repository.update(
            'not-exists',
            args: UpdateAcademicCalendarEventParams(
              createdEvent,
              name: 'New Name',
            ),
          );

          result.expectFailureWithCode(
            AppExceptionCode.academicCalendarEventNotFound,
          );
        },
      );

      test(
        'returns failure with internal code when exception occurs',
        () async {
          whenCalling(Invocation.method(#update, null))
              .on(repository)
              .thenThrow(Exception());

          final result = await repository.update(
            seededEvents.first.id,
            args: UpdateAcademicCalendarEventParams(
              seededEvents.first,
              name: 'New Name',
            ),
          );

          result.expectFailureWithCode(AppExceptionCode.internal);
        },
      );
    });
  });
}
