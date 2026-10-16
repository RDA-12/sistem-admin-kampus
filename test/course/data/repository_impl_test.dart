import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course/course.dart';
import 'package:sistem_admin/faculty/faculty.dart';
import 'package:sistem_admin/program/program.dart';

import '../../common/di_mocks.dart';
import '../../common/helper.dart';

void main() {
  const faculty = Faculty(id: 'faculty_1', name: 'Faculty 1');
  const program = Program(
    id: 'program_1',
    facultyId: 'faculty_1',
    name: 'Program 1',
  );
  const createdCourse = Course(
    id: 'uid',
    programId: 'program_1',
    code: 'CS_NEW',
    name: 'Pemrograman Dasar',
    semester: 1,
  );
  final seededCourses = List.generate(
    5,
    (index) => Course(
      id: 'course_$index',
      programId: program.id,
      code: 'CS10$index',
      name: 'Course $index',
      semester: index + 1,
    ),
  );
  late CourseRepository repository;
  late UidGenerator uidGeneratorMock;
  late AppDriftDatabase database;

  setUpAll(initializeMockDependencies);

  setUp(() async {
    database = getIt<AppDriftDatabase>();
    await database
        .into(database.facultiesDrift)
        .insert(
          FacultiesDriftCompanion.insert(id: faculty.id, name: faculty.name),
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
    for (final c in seededCourses) {
      await database
          .into(database.coursesDrift)
          .insert(
            CoursesDriftCompanion.insert(
              id: c.id,
              programId: c.programId,
              code: c.code,
              name: c.name,
              semester: c.semester,
            ),
          );
    }

    uidGeneratorMock = getIt<UidGenerator>();
    when(uidGeneratorMock.generate).thenReturn(createdCourse.id);

    repository = CourseRepository(
      db: database,
      uidGenerator: uidGeneratorMock,
    );
  });

  tearDown(() async {
    await database.delete(database.coursesDrift).go();
    await database.delete(database.programsDrift).go();
    await database.delete(database.facultiesDrift).go();
  });

  group('CourseRepository', () {
    group('save', () {
      const createArgs = CreateCourseParams(
        programId: 'program_1',
        code: 'CS_NEW',
        name: 'Pemrograman Dasar',
        semester: 1,
      );

      test('returns correct new course and save it', () async {
        final now = DateTime.now();
        await withClock(Clock.fixed(now), () async {
          final result = await repository.save(createArgs);

          expect(result, AppResult.success(createdCourse));

          final query = database.select(database.coursesDrift)
            ..where((tbl) => tbl.id.equals(createdCourse.id));
          final exists = await query.getSingleOrNull();
          expect(exists, isNotNull);
          expect(exists!.programId, createArgs.programId);
          expect(exists.code, createArgs.code);
          expect(exists.name, createArgs.name);
          expect(exists.semester, createArgs.semester);
          expect(exists.createdAt, now);
          expect(exists.updatedAt, now);
        });
      });

      test(
        'returns failure with courseAlreadyExists code '
        'when save course with existing code in same program',
        () async {
          await repository.save(createArgs);

          final result = await repository.save(createArgs);

          result.expectFailureWithCode(AppExceptionCode.courseAlreadyExists);
        },
      );

      test(
        'returns failure with internal code '
        'when unintended exception occurred',
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
      test('returns success and delete requested course', () async {
        final query = database.select(database.coursesDrift);
        final beforeDelete = await query.get();
        expect(beforeDelete.map((it) => it.toDomain()), seededCourses);

        final result = await repository.delete(seededCourses.first.id);

        expect(result, AppResult.success(null));

        final afterDelete = await query.get();
        expect(
          afterDelete.map((it) => it.toDomain()),
          seededCourses.sublist(1),
        );
      });

      test('returns success when deleting non existing course', () async {
        final result = await repository.delete(createdCourse.id);

        expect(result, AppResult.success(null));
      });

      test(
        'returns failure with internal code '
        'when unintended exception occurred',
        () async {
          whenCalling(Invocation.method(#delete, null))
              .on(repository)
              .thenThrow(Exception());

          final result = await repository.delete(createdCourse.id);

          result.expectFailureWithCode(AppExceptionCode.internal);
        },
      );
    });

    group('watch', () {
      test('emits correct courses', () async {
        final stream = repository.watch();

        expect(stream, emits(AppResult.success(seededCourses)));
      });

      test(
        'emits failure with internal code when unintended exception occurred',
        () async {
          whenCalling(Invocation.method(#watch, null))
              .on(repository)
              .thenThrow(Exception());

          final stream = repository.watch();

          expect(
            stream,
            emits(
              isA<AppFailure<List<Course>>>().having(
                (e) => e.exception.code,
                'exception.code',
                AppExceptionCode.internal,
              ),
            ),
          );
        },
      );
    });

    group('watchByProgram', () {
      test('emits correct courses for the program', () async {
        final stream = repository.watchByProgram(program.id);

        expect(stream, emits(AppResult.success(seededCourses)));
      });

      test(
        'emits failure with internal code when unintended exception occurred',
        () async {
          whenCalling(Invocation.method(#watchByProgram, null))
              .on(repository)
              .thenThrow(Exception());

          final stream = repository.watchByProgram(program.id);

          expect(
            stream,
            emits(
              isA<AppFailure<List<Course>>>().having(
                (e) => e.exception.code,
                'exception.code',
                AppExceptionCode.internal,
              ),
            ),
          );
        },
      );
    });

    group('update', () {
      test('returns updated course and save changes in database', () async {
        final query = database.select(database.coursesDrift);
        final before = await query.get();
        expect(before.map((it) => it.toDomain()), seededCourses);

        const expectedUpdated = Course(
          id: 'course_0',
          programId: 'program_1',
          code: 'CS999',
          name: 'updated name',
          semester: 4,
        );

        final now = DateTime.now();
        await withClock(Clock.fixed(now), () async {
          final result = await repository.update(
            seededCourses.first.id,
            args: UpdateCourseParams(
              seededCourses.first,
              code: expectedUpdated.code,
              name: expectedUpdated.name,
              semester: expectedUpdated.semester,
            ),
          );

          expect(result, AppResult.success(expectedUpdated));

          final after = await query.get();
          expect(after.map((it) => it.toDomain()), [
            expectedUpdated,
            ...seededCourses.sublist(1),
          ]);
        });
      });

      test(
        'returns failure with courseNotFound code '
        'when update non existing course',
        () async {
          final result = await repository.update(
            createdCourse.id,
            args: const UpdateCourseParams(createdCourse),
          );

          result.expectFailureWithCode(AppExceptionCode.courseNotFound);
        },
      );

      test(
        'returns failure with courseAlreadyExists code '
        'when update code with existing code in same program',
        () async {
          final target = seededCourses[1];
          final existingCode = seededCourses.first.code;

          final result = await repository.update(
            target.id,
            args: UpdateCourseParams(target, code: existingCode),
          );

          result.expectFailureWithCode(AppExceptionCode.courseAlreadyExists);
        },
      );

      test(
        'returns updated course and save changes '
        'when update code with existing code in same program but same id',
        () async {
          final target = seededCourses.first;

          final result = await repository.update(
            target.id,
            args: UpdateCourseParams(target, code: target.code),
          );

          expect(result, AppResult.success(target));
        },
      );

      test(
        'returns updated course when update code with existing code in '
        'different program',
        () async {
          const program2 = Program(
            id: 'program_2',
            facultyId: 'faculty_1',
            name: 'Program 2',
          );
          await database
              .into(database.programsDrift)
              .insert(
                ProgramsDriftCompanion.insert(
                  id: program2.id,
                  facultyId: program2.facultyId,
                  name: program2.name,
                ),
              );

          const courseInProg2 = Course(
            id: 'course_prog2',
            programId: 'program_2',
            code: 'CS999',
            name: 'Course Prog 2',
            semester: 1,
          );
          await database
              .into(database.coursesDrift)
              .insert(
                CoursesDriftCompanion.insert(
                  id: courseInProg2.id,
                  programId: courseInProg2.programId,
                  code: courseInProg2.code,
                  name: courseInProg2.name,
                  semester: courseInProg2.semester,
                ),
              );

          final target = seededCourses.first;
          final result = await repository.update(
            target.id,
            args: UpdateCourseParams(target, code: 'CS999'),
          );

          expect(
            result,
            AppResult.success(
              Course(
                id: target.id,
                programId: target.programId,
                code: 'CS999',
                name: target.name,
                semester: target.semester,
              ),
            ),
          );
        },
      );

      test(
        'returns failure with internal code '
        'when unintended exception occurred',
        () async {
          whenCalling(Invocation.method(#update, null))
              .on(repository)
              .thenThrow(Exception());

          final result = await repository.update(
            seededCourses.first.id,
            args: UpdateCourseParams(seededCourses.first),
          );

          result.expectFailureWithCode(AppExceptionCode.internal);
        },
      );
    });

    group('watchSingle', () {
      test('emits requested course', () async {
        final stream = repository.watchSingle(seededCourses.first.id);

        expect(stream, emits(AppResult.success(seededCourses.first)));
      });

      test(
        'emits failure with courseNotFound code '
        'when requested course not found',
        () async {
          final stream = repository.watchSingle(createdCourse.id);

          expect(
            stream,
            emits(
              isA<AppFailure<Course>>().having(
                (e) => e.exception.code,
                'exception.code',
                AppExceptionCode.courseNotFound,
              ),
            ),
          );
        },
      );
    });
  });
}
