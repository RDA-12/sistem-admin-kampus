import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/faculty.dart';
import 'package:sistem_admin/program/program.dart';

import '../../common/di_mocks.dart';
import '../../common/helper.dart';

void main() {
  const faculty = Faculty(id: 'faculty_1', name: 'Faculty 1');
  const createdProgram = Program(
    id: 'uid',
    facultyId: 'faculty_1',
    name: 'name',
  );
  final seededPrograms = List.generate(
    5,
    (index) => Program(
      id: 'program_$index',
      facultyId: faculty.id,
      name: 'Program $index',
    ),
  );
  late ProgramRepository repository;
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
    for (final p in seededPrograms) {
      await database
          .into(database.programsDrift)
          .insert(
            ProgramsDriftCompanion.insert(
              id: p.id,
              facultyId: p.facultyId,
              name: p.name,
            ),
          );
    }

    uidGeneratorMock = getIt<UidGenerator>();
    when(uidGeneratorMock.generate).thenReturn(createdProgram.id);

    repository = ProgramRepository(
      db: database,
      uidGenerator: uidGeneratorMock,
    );
  });

  tearDown(() async {
    await database.delete(database.programsDrift).go();
    await database.delete(database.facultiesDrift).go();
  });

  group('ProgramRepository', () {
    group('save', () {
      const createArgs = CreateProgramParams(
        facultyId: 'faculty_1',
        name: 'name',
      );

      test('returns correct new program and save it', () async {
        final now = DateTime.now();
        await withClock(Clock.fixed(now), () async {
          final result = await repository.save(createArgs);

          expect(result, AppResult.success(createdProgram));

          final query = database.select(database.programsDrift)
            ..where((tbl) => tbl.id.equals(createdProgram.id));
          final exists = await query.getSingleOrNull();
          expect(exists, isNotNull);
          expect(exists!.facultyId, createArgs.facultyId);
          expect(exists.name, createArgs.name);
          expect(exists.createdAt, now);
          expect(exists.updatedAt, now);
        });
      });

      test(
        'returns failure with programAlreadyExists code '
        'when save program with existing name in same faculty',
        () async {
          await repository.save(createArgs);

          final result = await repository.save(createArgs);

          result.expectFailureWithCode(AppExceptionCode.programAlreadyExists);
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
      test('returns success and delete requested program', () async {
        final query = database.select(database.programsDrift);
        final beforeDelete = await query.get();
        expect(beforeDelete.map((it) => it.toDomain()), seededPrograms);

        final result = await repository.delete(seededPrograms.first.id);

        expect(result, AppResult.success(null));

        final afterDelete = await query.get();
        expect(
          afterDelete.map((it) => it.toDomain()),
          seededPrograms.sublist(1),
        );
      });

      test('returns success when deleting non existing program', () async {
        final result = await repository.delete(createdProgram.id);

        expect(result, AppResult.success(null));
      });

      test(
        'returns failure with internal code '
        'when unintended exception occurred',
        () async {
          whenCalling(Invocation.method(#delete, null))
              .on(repository)
              .thenThrow(Exception());

          final result = await repository.delete(createdProgram.id);

          result.expectFailureWithCode(AppExceptionCode.internal);
        },
      );
    });

    group('watch', () {
      test('emits correct programs', () async {
        final stream = repository.watch();

        expect(stream, emits(AppResult.success(seededPrograms)));
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
              isA<AppFailure<List<Program>>>().having(
                (e) => e.exception.code,
                'exception.code',
                AppExceptionCode.internal,
              ),
            ),
          );
        },
      );
    });

    group('watchByFaculty', () {
      test('emits correct programs for the faculty', () async {
        final stream = repository.watchByFaculty(faculty.id);

        expect(stream, emits(AppResult.success(seededPrograms)));
      });

      test(
        'emits failure with internal code when unintended exception occurred',
        () async {
          whenCalling(Invocation.method(#watchByFaculty, null))
              .on(repository)
              .thenThrow(Exception());

          final stream = repository.watchByFaculty(faculty.id);

          expect(
            stream,
            emits(
              isA<AppFailure<List<Program>>>().having(
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
      test('returns updated program and save changes in database', () async {
        final query = database.select(database.programsDrift);
        final before = await query.get();
        expect(before.map((it) => it.toDomain()), seededPrograms);

        const expectedUpdated = Program(
          id: 'program_0',
          facultyId: 'faculty_1',
          name: 'updated name',
        );

        final updated = await repository.update(
          seededPrograms.first.id,
          args: const UpdateProgramParams(
            expectedUpdated,
            name: 'updated name',
          ),
        );

        expect(updated, AppResult.success(expectedUpdated));

        final after = await query.get();
        expect(after.map((it) => it.toDomain()), [
          expectedUpdated,
          ...seededPrograms.sublist(1),
        ]);
      });

      test('returns failure with programNotFound code '
          'when update non existing program', () async {
        final result = await repository.update(
          createdProgram.id,
          args: const UpdateProgramParams(createdProgram, name: 'new name'),
        );

        result.expectFailureWithCode(AppExceptionCode.programNotFound);
      });

      test('returns failure with programAlreadyExists code '
          'when update with existing name', () async {
        final result = await repository.update(
          seededPrograms.first.id,
          args: UpdateProgramParams(
            createdProgram,
            name: seededPrograms[1].name,
          ),
        );

        result.expectFailureWithCode(AppExceptionCode.programAlreadyExists);
      });

      test('returns failure with internal code '
          'when unintended exception occurred', () async {
        whenCalling(Invocation.method(#update, null))
            .on(repository)
            .thenThrow(Exception());

        final result = await repository.update(
          seededPrograms.first.id,
          args: UpdateProgramParams(seededPrograms.first, name: 'new name'),
        );

        result.expectFailureWithCode(AppExceptionCode.internal);
      });
    });

    group('watchSingle', () {
      test('emits correct program when program exists', () {
        final result = repository.watchSingle(seededPrograms.first.id);

        expect(result, emits(AppResult.success(seededPrograms.first)));
      });

      test(
        'emits failure with programNotFound code when program does not exist',
        () {
          final result = repository.watchSingle('not-exists');

          expect(
            result,
            emits(
              isA<AppFailure<Program>>().having(
                (e) => e.exception.code,
                'exception.code',
                AppExceptionCode.programNotFound,
              ),
            ),
          );
        },
      );
    });
  });
}
