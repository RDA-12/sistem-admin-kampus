import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/faculty.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';
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
  const createdLecturer = Lecturer(
    id: 'uid',
    programId: 'program_1',
    name: 'name',
    pangkatGolongan: 'III/a',
  );
  final seededLecturers = List.generate(
    5,
    (index) => Lecturer(
      id: 'lecturer_$index',
      programId: program.id,
      name: 'Lecturer $index',
      pangkatGolongan: 'III/a',
    ),
  );
  late LecturerRepository repository;
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
    for (final l in seededLecturers) {
      await database
          .into(database.lecturersDrift)
          .insert(
            LecturersDriftCompanion.insert(
              id: l.id,
              programId: l.programId,
              name: l.name,
              pangkatGolongan: l.pangkatGolongan,
            ),
          );
    }

    uidGeneratorMock = getIt<UidGenerator>();
    when(uidGeneratorMock.generate).thenReturn(createdLecturer.id);

    repository = LecturerRepository(
      db: database,
      uidGenerator: uidGeneratorMock,
    );
  });

  tearDown(() async {
    await database.delete(database.lecturersDrift).go();
    await database.delete(database.programsDrift).go();
    await database.delete(database.facultiesDrift).go();
  });

  group('LecturerRepository', () {
    group('save', () {
      const createArgs = CreateLecturerParams(
        programId: 'program_1',
        name: 'name',
        pangkatGolongan: 'III/a',
      );

      test('returns correct new lecturer and save it', () async {
        final now = DateTime.now();
        await withClock(Clock.fixed(now), () async {
          final result = await repository.save(createArgs);

          expect(result, AppResult.success(createdLecturer));

          final query = database.select(database.lecturersDrift)
            ..where((tbl) => tbl.id.equals(createdLecturer.id));
          final exists = await query.getSingleOrNull();
          expect(exists, isNotNull);
          expect(exists!.programId, createArgs.programId);
          expect(exists.name, createArgs.name);
          expect(exists.pangkatGolongan, createArgs.pangkatGolongan);
          expect(exists.createdAt, now);
          expect(exists.updatedAt, now);
        });
      });

      test(
        'returns failure with lecturerAlreadyExists code '
        'when save lecturer with existing name in same program',
        () async {
          await repository.save(createArgs);

          final result = await repository.save(createArgs);

          result.expectFailureWithCode(AppExceptionCode.lecturerAlreadyExists);
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
      test('returns success and delete requested lecturer', () async {
        final query = database.select(database.lecturersDrift);
        final beforeDelete = await query.get();
        expect(beforeDelete.map((it) => it.toDomain()), seededLecturers);

        final result = await repository.delete(seededLecturers.first.id);

        expect(result, AppResult.success(null));

        final afterDelete = await query.get();
        expect(
          afterDelete.map((it) => it.toDomain()),
          seededLecturers.sublist(1),
        );
      });

      test('returns success when deleting non existing lecturer', () async {
        final result = await repository.delete(createdLecturer.id);

        expect(result, AppResult.success(null));
      });

      test(
        'returns failure with internal code '
        'when unintended exception occurred',
        () async {
          whenCalling(Invocation.method(#delete, null))
              .on(repository)
              .thenThrow(Exception());

          final result = await repository.delete(createdLecturer.id);

          result.expectFailureWithCode(AppExceptionCode.internal);
        },
      );
    });

    group('watch', () {
      test('emits correct lecturers', () async {
        final stream = repository.watch();

        expect(stream, emits(AppResult.success(seededLecturers)));
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
              isA<AppFailure<List<Lecturer>>>().having(
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
      test('emits correct lecturers for the program', () async {
        final stream = repository.watchByProgram(program.id);

        expect(stream, emits(AppResult.success(seededLecturers)));
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
              isA<AppFailure<List<Lecturer>>>().having(
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
      test('returns updated lecturer and save changes in database', () async {
        final query = database.select(database.lecturersDrift);
        final before = await query.get();
        expect(before.map((it) => it.toDomain()), seededLecturers);

        const expectedUpdated = Lecturer(
          id: 'lecturer_0',
          programId: 'program_1',
          name: 'updated name',
          pangkatGolongan: 'IV/a',
        );

        final updated = await repository.update(
          seededLecturers.first.id,
          args: const UpdateLecturerParams(
            expectedUpdated,
            name: 'updated name',
            pangkatGolongan: 'IV/a',
          ),
        );

        expect(updated, AppResult.success(expectedUpdated));

        final after = await query.get();
        expect(after.map((it) => it.toDomain()), [
          expectedUpdated,
          ...seededLecturers.sublist(1),
        ]);
      });

      test('returns failure with lecturerNotFound code '
          'when update non existing lecturer', () async {
        final result = await repository.update(
          createdLecturer.id,
          args: const UpdateLecturerParams(createdLecturer, name: 'new name'),
        );

        result.expectFailureWithCode(AppExceptionCode.lecturerNotFound);
      });

      test('returns failure with lecturerAlreadyExists code '
          'when update with existing name', () async {
        final result = await repository.update(
          seededLecturers.first.id,
          args: UpdateLecturerParams(
            createdLecturer,
            name: seededLecturers[1].name,
          ),
        );

        result.expectFailureWithCode(AppExceptionCode.lecturerAlreadyExists);
      });

      test('returns failure with internal code '
          'when unintended exception occurred', () async {
        whenCalling(Invocation.method(#update, null))
            .on(repository)
            .thenThrow(Exception());

        final result = await repository.update(
          seededLecturers.first.id,
          args: UpdateLecturerParams(seededLecturers.first, name: 'new name'),
        );

        result.expectFailureWithCode(AppExceptionCode.internal);
      });
    });

    group('watchSingle', () {
      test('emits correct lecturer when lecturer exists', () {
        final result = repository.watchSingle(seededLecturers.first.id);

        expect(result, emits(AppResult.success(seededLecturers.first)));
      });

      test(
        'emits failure with lecturerNotFound code when lecturer does not exist',
        () {
          final result = repository.watchSingle('not-exists');

          expect(
            result,
            emits(
              isA<AppFailure<Lecturer>>().having(
                (e) => e.exception.code,
                'exception.code',
                AppExceptionCode.lecturerNotFound,
              ),
            ),
          );
        },
      );
    });
  });
}
