import 'package:clock/clock.dart';
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

  final term = AcademicTerm(
    id: 'term_1',
    academicYearId: year.id,
    name: 'Ganjil',
    startDate: DateTime(2025, 9),
    endDate: DateTime(2026, 1, 31),
  );

  final term2 = AcademicTerm(
    id: 'term_2',
    academicYearId: year.id,
    name: 'Genap',
    startDate: DateTime(2026, 2),
    endDate: DateTime(2026, 6, 30),
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

  final createdSchedule = CourseSchedule(
    id: 'uid_course_schedule',
    academicYearId: year.id,
    termId: term.id,
    programId: program.id,
    name: 'Kuliah Pemrograman Web',
    start: DateTime(2025, 9, 8, 8),
    duration: const Duration(minutes: 100),
    cohortId: cohort.id,
    courseId: course.id,
    lecturerId: lecturer.id,
    roomId: room.id,
  );

  final seededSchedules = List.generate(
    2,
    (index) => CourseSchedule(
      id: 'schedule_$index',
      academicYearId: year.id,
      termId: term.id,
      programId: program.id,
      name: 'Schedule $index',
      start: DateTime(2025, 9, 8 + index, 8 + index),
      duration: const Duration(minutes: 100),
      cohortId: index == 0 ? cohort.id : cohort2.id,
      courseId: course.id,
      lecturerId: lecturer.id,
      roomId: index == 0 ? room.id : room2.id,
    ),
  );

  late CourseScheduleRepository repository;
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

    // Seed academic terms
    await database
        .into(database.academicTermsDrift)
        .insert(
          AcademicTermsDriftCompanion.insert(
            id: term.id,
            academicYearId: term.academicYearId,
            name: term.name,
            startDate: term.startDate,
            endDate: term.endDate,
          ),
        );
    await database
        .into(database.academicTermsDrift)
        .insert(
          AcademicTermsDriftCompanion.insert(
            id: term2.id,
            academicYearId: term2.academicYearId,
            name: term2.name,
            startDate: term2.startDate,
            endDate: term2.endDate,
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

    // Seed seededSchedules
    for (final e in seededSchedules) {
      await database
          .into(database.courseSchedulesDrift)
          .insert(
            CourseSchedulesDriftCompanion.insert(
              id: e.id,
              academicYearId: e.academicYearId,
              termId: e.termId,
              programId: e.programId,
              name: e.name,
              start: e.start,
              durationInMinutes: e.duration.inMinutes,
              cohortId: e.cohortId,
              courseId: e.courseId,
              lecturerId: e.lecturerId,
              roomId: e.roomId,
            ),
          );
    }

    uidGeneratorMock = getIt<UidGenerator>();
    when(uidGeneratorMock.generate).thenReturn(createdSchedule.id);

    repository = CourseScheduleRepository(
      db: database,
      uidGenerator: uidGeneratorMock,
    );
  });

  tearDown(() async {
    await database.delete(database.courseSchedulesDrift).go();
    await database.delete(database.cohortsDrift).go();
    await database.delete(database.roomsDrift).go();
    await database.delete(database.lecturersDrift).go();
    await database.delete(database.coursesDrift).go();
    await database.delete(database.programsDrift).go();
    await database.delete(database.facultiesDrift).go();
    await database.delete(database.academicTermsDrift).go();
    await database.delete(database.academicYearsDrift).go();
  });

  group('CourseScheduleRepository', () {
    group('save', () {
      final createArgs = CreateCourseScheduleParams(
        academicYearId: year.id,
        termId: term.id,
        programId: program.id,
        name: 'Kuliah Pemrograman Web',
        start: DateTime(2025, 9, 8, 8),
        duration: const Duration(minutes: 100),
        cohortId: cohort.id,
        courseId: course.id,
        lecturerId: lecturer.id,
        roomId: room.id,
      );

      test(
        'returns correct new course schedule and saves it in database',
        () async {
          when(uidGeneratorMock.generate).thenReturn(createdSchedule.id);
          final now = DateTime.now();
          await withClock(Clock.fixed(now), () async {
            final result = await repository.save(createArgs);

            expect(result, AppResult.success(createdSchedule));

            final query = database.select(
              database.courseSchedulesDrift,
            )..where((tbl) => tbl.id.equals(createdSchedule.id));
            final inDb = await query.getSingleOrNull();
            expect(inDb, isNotNull);
            expect(inDb!.name, createArgs.name);
            expect(inDb.academicYearId, createArgs.academicYearId);
            expect(inDb.termId, createArgs.termId);
            expect(inDb.programId, createArgs.programId);
            expect(inDb.start, createArgs.start);
            expect(inDb.durationInMinutes, createArgs.duration.inMinutes);
            expect(inDb.cohortId, createArgs.cohortId);
            expect(inDb.courseId, createArgs.courseId);
            expect(inDb.lecturerId, createArgs.lecturerId);
            expect(inDb.roomId, createArgs.roomId);
            expect(inDb.createdAt, now);
            expect(inDb.updatedAt, now);
          });
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
      test('returns success and deletes requested course schedule', () async {
        final query = database.select(database.courseSchedulesDrift);

        expect((await query.get()).length, 2);

        final result = await repository.delete(seededSchedules.first.id);

        expect(result, AppResult.success(null));

        final remaining = await query.get();
        expect(remaining.length, 1);
        expect(remaining.first.id, seededSchedules[1].id);
      });

      test(
        'returns success when deleting non-existent course schedule',
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
      test('emits correct course schedules', () async {
        final stream = repository.watch();

        expect(stream, emits(AppResult.success(seededSchedules)));
      });

      test('emits failure when exception occurs', () async {
        whenCalling(Invocation.method(#watch, null))
            .on(repository)
            .thenThrow(Exception());

        final stream = repository.watch();

        expect(
          stream,
          emits(
            isA<AppFailure<List<CourseSchedule>>>().having(
              (e) => e.exception.code,
              'exception.code',
              AppExceptionCode.internal,
            ),
          ),
        );
      });

      test('emits correct course schedules for academic year', () async {
        final stream = repository.watch(
          CourseScheduleFilter(academicYearId: year.id),
        );

        expect(stream, emits(AppResult.success(seededSchedules)));
      });

      test('emits failure when exception occurs with filter', () async {
        whenCalling(Invocation.method(#watch, null))
            .on(repository)
            .thenThrow(Exception());

        final stream = repository.watch(
          CourseScheduleFilter(academicYearId: year.id),
        );

        expect(
          stream,
          emits(
            isA<AppFailure<List<CourseSchedule>>>().having(
              (e) => e.exception.code,
              'exception.code',
              AppExceptionCode.internal,
            ),
          ),
        );
      });

      test('emits correct course schedules for cohort', () async {
        final stream = repository.watch(
          CourseScheduleFilter(cohortId: cohort.id),
        );

        expect(stream, emits(AppResult.success([seededSchedules.first])));
      });

      test('emits correct course schedules for term', () async {
        final stream = repository.watch(
          CourseScheduleFilter(termId: term.id),
        );

        expect(stream, emits(AppResult.success(seededSchedules)));
      });

      test('emits correct course schedules for program', () async {
        final stream = repository.watch(
          CourseScheduleFilter(programId: program.id),
        );

        expect(stream, emits(AppResult.success(seededSchedules)));
      });
    });

    group('watchSingle', () {
      test('emits correct course schedule when exists', () {
        final result = repository.watchSingle(seededSchedules.first.id);

        expect(result, emits(AppResult.success(seededSchedules.first)));
      });

      test(
        'emits failure with courseScheduleNotFound when not exists',
        () {
          final result = repository.watchSingle('not-exists');

          expect(
            result,
            emits(
              isA<AppFailure<CourseSchedule>>().having(
                (e) => e.exception.code,
                'exception.code',
                AppExceptionCode.courseScheduleNotFound,
              ),
            ),
          );
        },
      );
    });

    group('update', () {
      test('returns updated course schedule and saves changes in db', () async {
        final expectedUpdated = CourseSchedule(
          id: seededSchedules.first.id,
          academicYearId: seededSchedules.first.academicYearId,
          termId: seededSchedules.first.termId,
          programId: seededSchedules.first.programId,
          name: 'Updated Schedule Name',
          start: seededSchedules.first.start,
          duration: seededSchedules.first.duration,
          cohortId: 'cohort_2',
          courseId: seededSchedules.first.courseId,
          lecturerId: seededSchedules.first.lecturerId,
          roomId: 'room_2',
        );

        final updated = await repository.update(
          seededSchedules.first.id,
          args: UpdateCourseScheduleParams(
            seededSchedules.first,
            name: 'Updated Schedule Name',
            cohortId: 'cohort_2',
            roomId: 'room_2',
          ),
        );

        expect(updated, AppResult.success(expectedUpdated));

        final inDb = await (database.select(
          database.courseSchedulesDrift,
        )..where((tbl) => tbl.id.equals(seededSchedules.first.id))).getSingle();
        expect(inDb.name, 'Updated Schedule Name');
        expect(inDb.cohortId, 'cohort_2');
        expect(inDb.roomId, 'room_2');
      });

      test(
        'returns failure with courseScheduleNotFound when '
        'updating non-existent',
        () async {
          final result = await repository.update(
            'not-exists',
            args: UpdateCourseScheduleParams(
              createdSchedule,
              name: 'New Name',
            ),
          );

          result.expectFailureWithCode(
            AppExceptionCode.courseScheduleNotFound,
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
            seededSchedules.first.id,
            args: UpdateCourseScheduleParams(
              seededSchedules.first,
              name: 'New Name',
            ),
          );

          result.expectFailureWithCode(AppExceptionCode.internal);
        },
      );
    });
  });
}
