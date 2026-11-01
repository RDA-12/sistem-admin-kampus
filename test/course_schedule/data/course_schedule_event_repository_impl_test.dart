import 'package:clock/clock.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/cohort/cohort.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course/course.dart';
import 'package:sistem_admin/course_schedule/course_schedule.dart';
import 'package:sistem_admin/faculty/faculty.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';
import 'package:sistem_admin/program/program.dart';
import 'package:sistem_admin/room/room.dart';

import '../../common/di_mocks.dart';
import '../../common/helper.dart';

void main() {
  final year = AcademicYear(
    id: 'year_1',
    name: '2025/2026',
    startDate: DateTime(2025, 9),
    endDate: DateTime(2026, 8, 31),
  );

  const faculty = Faculty(id: 'faculty_1', name: 'Teknik');
  const program = Program(
    id: 'program_1',
    facultyId: 'faculty_1',
    name: 'Informatika',
  );
  const room = Room(
    id: 'room_1',
    facultyId: 'faculty_1',
    name: 'Lab 1',
  );
  const room2 = Room(
    id: 'room_2',
    facultyId: 'faculty_1',
    name: 'Lab 2',
  );
  const cohort = Cohort(
    id: 'cohort_1',
    name: 'Cohort 2025',
    entryYear: 2025,
  );
  const cohort2 = Cohort(
    id: 'cohort_2',
    name: 'Cohort 2026',
    entryYear: 2026,
  );
  const course = Course(
    id: 'course_1',
    programId: 'program_1',
    code: 'IF101',
    name: 'Pemrograman Web',
    semester: 1,
    credit: 3,
  );
  const lecturer = Lecturer(
    id: 'lecturer_1',
    programId: 'program_1',
    name: 'Dr. John Doe',
    pangkatGolongan: 'III/a',
  );

  final eventStart = EventDateTime(
    date: DateTime(2025, 9, 8),
    time: const Time(hour: 8, minute: 0),
  );
  final eventEnd = EventDateTime(
    date: DateTime(2025, 9, 8),
    time: const Time(hour: 10, minute: 0),
  );

  const detail = CourseScheduleEventDetail(
    cohortId: 'cohort_1',
    courseId: 'course_1',
    programId: 'program_1',
    lecturerId: 'lecturer_1',
    roomId: 'room_1',
  );

  final createdEvent = CourseScheduleEvent(
    id: 'uid_course_event',
    academicYearId: year.id,
    name: 'Kuliah Pemrograman Web',
    start: eventStart,
    end: eventEnd,
    courseDetail: detail,
    recurrence: const ['RRULE:FREQ=WEEKLY'],
  );

  final seededEvents = List.generate(
    2,
    (index) => CourseScheduleEvent(
      id: 'schedule_event_$index',
      academicYearId: year.id,
      name: 'Schedule Event $index',
      start: EventDateTime(
        date: DateTime(2025, 9, 10 + index),
        time: const Time(hour: 8, minute: 0),
      ),
      end: EventDateTime(
        date: DateTime(2025, 9, 10 + index),
        time: const Time(hour: 10, minute: 0),
      ),
      courseDetail: CourseScheduleEventDetail(
        cohortId: index == 0 ? cohort.id : cohort2.id,
        courseId: course.id,
        programId: program.id,
        lecturerId: lecturer.id,
        roomId: index == 0 ? room.id : room2.id,
      ),
      recurrence: const ['RRULE:FREQ=WEEKLY'],
    ),
  );

  late CourseScheduleEventRepository repository;
  late UidGenerator uidGeneratorMock;
  late AppDriftDatabase database;

  setUpAll(initializeMockDependencies);

  setUp(() async {
    database = getIt<AppDriftDatabase>();

    // Seed academic year
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

    // Seed faculty, program, rooms
    await database
        .into(database.facultiesDrift)
        .insert(
          FacultiesDriftCompanion.insert(
            id: faculty.id,
            name: faculty.name,
          ),
        );
    await database
        .into(database.programsDrift)
        .insert(
          ProgramsDriftCompanion.insert(
            id: program.id,
            facultyId: program.facultyId,
            name: program.name,
          ),
        );
    await database
        .into(database.roomsDrift)
        .insert(
          RoomsDriftCompanion.insert(
            id: room.id,
            facultyId: room.facultyId,
            name: room.name,
          ),
        );
    await database
        .into(database.roomsDrift)
        .insert(
          RoomsDriftCompanion.insert(
            id: room2.id,
            facultyId: room2.facultyId,
            name: room2.name,
          ),
        );

    // Seed cohorts
    await database
        .into(database.cohortsDrift)
        .insert(
          CohortsDriftCompanion.insert(
            id: cohort.id,
            name: cohort.name,
            entryYear: cohort.entryYear,
          ),
        );
    await database
        .into(database.cohortsDrift)
        .insert(
          CohortsDriftCompanion.insert(
            id: cohort2.id,
            name: cohort2.name,
            entryYear: cohort2.entryYear,
          ),
        );

    // Seed course and lecturer
    await database
        .into(database.coursesDrift)
        .insert(
          CoursesDriftCompanion.insert(
            id: course.id,
            programId: course.programId,
            code: course.code,
            name: course.name,
            semester: course.semester,
            credit: course.credit,
          ),
        );
    await database
        .into(database.lecturersDrift)
        .insert(
          LecturersDriftCompanion.insert(
            id: lecturer.id,
            programId: lecturer.programId,
            name: lecturer.name,
            pangkatGolongan: lecturer.pangkatGolongan,
          ),
        );

    // Seed seededEvents
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
              recurrence: Value(e.recurrence),
            ),
          );
      await database
          .into(database.courseScheduleEventDetailsDrift)
          .insert(
            CourseScheduleEventDetailsDriftCompanion.insert(
              eventId: e.id,
              cohortId: e.courseDetail.cohortId,
              courseId: e.courseDetail.courseId,
              programId: e.courseDetail.programId,
              lecturerId: e.courseDetail.lecturerId,
              roomId: e.courseDetail.roomId,
            ),
          );
    }

    uidGeneratorMock = getIt<UidGenerator>();
    when(uidGeneratorMock.generate).thenReturn(createdEvent.id);

    repository = CourseScheduleEventRepository(
      db: database,
      uidGenerator: uidGeneratorMock,
    );
  });

  tearDown(() async {
    await database.delete(database.courseScheduleEventDetailsDrift).go();
    await database.delete(database.academicCalendarEventsDrift).go();
    await database.delete(database.cohortsDrift).go();
    await database.delete(database.roomsDrift).go();
    await database.delete(database.lecturersDrift).go();
    await database.delete(database.coursesDrift).go();
    await database.delete(database.programsDrift).go();
    await database.delete(database.facultiesDrift).go();
    await database.delete(database.academicYearsDrift).go();
  });

  group('CourseScheduleEventRepository', () {
    group('save', () {
      final createArgs = CreateCourseScheduleEventParams(
        academicYearId: year.id,
        name: 'Kuliah Pemrograman Web',
        start: eventStart,
        end: eventEnd,
        courseDetail: detail,
        recurrence: const ['RRULE:FREQ=WEEKLY'],
      );

      test('returns correct new event and saves it in both tables', () async {
        when(uidGeneratorMock.generate).thenReturn(createdEvent.id);
        final now = DateTime.now();
        await withClock(Clock.fixed(now), () async {
          final result = await repository.save(createArgs);

          expect(result, AppResult.success(createdEvent));

          final baseQuery = database.select(
            database.academicCalendarEventsDrift,
          )..where((tbl) => tbl.id.equals(createdEvent.id));
          final baseInDb = await baseQuery.getSingleOrNull();
          expect(baseInDb, isNotNull);
          expect(baseInDb!.name, createArgs.name);
          expect(baseInDb.academicYearId, createArgs.academicYearId);
          expect(baseInDb.type, AcademicCalendarEventType.lectures);
          expect(baseInDb.startDate, createArgs.start.date);
          expect(baseInDb.startHour, createArgs.start.time.hour);
          expect(baseInDb.startMinute, createArgs.start.time.minute);
          expect(baseInDb.endDate, createArgs.end.date);
          expect(baseInDb.endHour, createArgs.end.time.hour);
          expect(baseInDb.endMinute, createArgs.end.time.minute);
          expect(baseInDb.recurrence, createArgs.recurrence);
          expect(baseInDb.createdAt, now);
          expect(baseInDb.updatedAt, now);

          final detailQuery = database.select(
            database.courseScheduleEventDetailsDrift,
          )..where((tbl) => tbl.eventId.equals(createdEvent.id));
          final detailInDb = await detailQuery.getSingleOrNull();
          expect(detailInDb, isNotNull);
          expect(detailInDb!.cohortId, detail.cohortId);
          expect(detailInDb.courseId, detail.courseId);
          expect(detailInDb.programId, detail.programId);
          expect(detailInDb.lecturerId, detail.lecturerId);
          expect(detailInDb.roomId, detail.roomId);
          expect(detailInDb.createdAt, now);
          expect(detailInDb.updatedAt, now);
        });
      });

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
      test('returns success and deletes requested event and detail', () async {
        final baseQuery = database.select(database.academicCalendarEventsDrift);
        final detailQuery = database.select(
          database.courseScheduleEventDetailsDrift,
        );

        expect((await baseQuery.get()).length, 2);
        expect((await detailQuery.get()).length, 2);

        final result = await repository.delete(seededEvents.first.id);

        expect(result, AppResult.success(null));

        final remainingBases = await baseQuery.get();
        final remainingDetails = await detailQuery.get();
        expect(remainingBases.length, 1);
        expect(remainingBases.first.id, seededEvents[1].id);
        expect(remainingDetails.length, 1);
        expect(remainingDetails.first.eventId, seededEvents[1].id);
      });

      test('returns success when deleting non-existent event', () async {
        final result = await repository.delete('non-existent');

        expect(result, AppResult.success(null));
      });

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
      test('emits correct course schedule events', () async {
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
            isA<AppFailure<List<CourseScheduleEvent>>>().having(
              (e) => e.exception.code,
              'exception.code',
              AppExceptionCode.internal,
            ),
          ),
        );
      });
    });

    group('watchByAcademicYear', () {
      test('emits correct course schedule events for academic year', () async {
        final stream = repository.watchByAcademicYear(year.id);

        expect(stream, emits(AppResult.success(seededEvents)));
      });

      test('emits failure when exception occurs', () async {
        whenCalling(Invocation.method(#watchByAcademicYear, null))
            .on(repository)
            .thenThrow(Exception());

        final stream = repository.watchByAcademicYear(year.id);

        expect(
          stream,
          emits(
            isA<AppFailure<List<CourseScheduleEvent>>>().having(
              (e) => e.exception.code,
              'exception.code',
              AppExceptionCode.internal,
            ),
          ),
        );
      });
    });

    group('watchByCohort', () {
      test('emits correct course schedule events for cohort', () async {
        final stream = repository.watchByCohort(cohort.id);

        expect(stream, emits(AppResult.success([seededEvents.first])));
      });

      test('emits failure when exception occurs', () async {
        whenCalling(Invocation.method(#watchByCohort, null))
            .on(repository)
            .thenThrow(Exception());

        final stream = repository.watchByCohort(cohort.id);

        expect(
          stream,
          emits(
            isA<AppFailure<List<CourseScheduleEvent>>>().having(
              (e) => e.exception.code,
              'exception.code',
              AppExceptionCode.internal,
            ),
          ),
        );
      });
    });

    group('watchSingle', () {
      test('emits correct course schedule event when exists', () {
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
              isA<AppFailure<CourseScheduleEvent>>().having(
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
        const updatedDetail = CourseScheduleEventDetail(
          cohortId: 'cohort_2',
          courseId: 'course_1',
          programId: 'program_1',
          lecturerId: 'lecturer_1',
          roomId: 'room_2',
        );

        final expectedUpdated = CourseScheduleEvent(
          id: seededEvents.first.id,
          academicYearId: seededEvents.first.academicYearId,
          name: 'Updated Schedule Name',
          start: seededEvents.first.start,
          end: seededEvents.first.end,
          courseDetail: updatedDetail,
          recurrence: seededEvents.first.recurrence,
        );

        final updated = await repository.update(
          seededEvents.first.id,
          args: UpdateCourseScheduleEventParams(
            seededEvents.first,
            name: 'Updated Schedule Name',
            courseDetail: updatedDetail,
          ),
        );

        expect(updated, AppResult.success(expectedUpdated));

        final baseInDb = await (database.select(
          database.academicCalendarEventsDrift,
        )..where((tbl) => tbl.id.equals(seededEvents.first.id))).getSingle();
        expect(baseInDb.name, 'Updated Schedule Name');

        final detailInDb =
            await (database.select(database.courseScheduleEventDetailsDrift)
                  ..where((tbl) => tbl.eventId.equals(seededEvents.first.id)))
                .getSingle();
        expect(detailInDb.cohortId, 'cohort_2');
        expect(detailInDb.roomId, 'room_2');
      });

      test(
        'returns failure with academicCalendarEventNotFound when '
        'updating non-existent',
        () async {
          final result = await repository.update(
            'not-exists',
            args: UpdateCourseScheduleEventParams(
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
            args: UpdateCourseScheduleEventParams(
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
