import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/faculty.dart';

import '../../common/di_mocks.dart';
import '../../common/helper.dart';

void main() {
  final seededFaculty = List.generate(
    5,
    (index) => Faculty(id: '$index', name: '$index'),
  );
  const createdFaculty = Faculty(id: 'uid', name: 'name');
  late FacultyRepository repository;
  late UidGenerator uidGeneratorMock;
  late AppDriftDatabase database;

  setUpAll(initializeMockDependencies);

  setUp(() async {
    database = getIt<AppDriftDatabase>();
    for (final f in seededFaculty) {
      await database
          .into(database.facultiesDrift)
          .insert(FacultiesDriftCompanion.insert(id: f.id, name: f.name));
    }

    uidGeneratorMock = getIt<UidGenerator>();
    when(uidGeneratorMock.generate).thenReturn(createdFaculty.id);

    repository = FacultyRepository(
      db: database,
      uidGenerator: uidGeneratorMock,
    );
  });

  tearDown(() async {
    await database.delete(database.facultiesDrift).go();
  });

  group('FacultyRepository', () {
    group('save', () {
      final createArgs = CreateFacultyParams(name: createdFaculty.name);

      test('returns correct new faculty and save it', () async {
        final now = DateTime.now();
        await withClock(Clock.fixed(now), () async {
          final result = await repository.save(createArgs);

          expect(result, AppResult.success(createdFaculty));

          final query = database.select(database.facultiesDrift)
            ..where((tbl) => tbl.id.equals(createdFaculty.id));
          final exists = await query.getSingleOrNull();
          expect(exists, isNotNull);
          expect(exists!.name, createArgs.name);
          expect(exists.createdAt, now);
          expect(exists.updatedAt, now);
        });
      });

      test('returns failure with facultyAlreadyExists code '
          'when save faculty with existing name', () async {
        await repository.save(createArgs);

        final result = await repository.save(createArgs);

        result.expectFailureWithCode(.facultyAlreadyExists);
      });

      test('returns failure with internal code '
          'when unintended unintended exception occurred', () async {
        whenCalling(Invocation.method(#save, null))
            .on(repository)
            .thenThrow(Exception());

        final result = await repository.save(createArgs);

        result.expectFailureWithCode(.internal);
      });
    });

    group('delete', () {
      test('returns success and delete requested faculty', () async {
        final query = database.select(database.facultiesDrift);
        final beforeDelete = await query.get();
        expect(beforeDelete.map((it) => it.toDomain()), seededFaculty);

        final result = await repository.delete(seededFaculty.first.id);

        expect(result, AppResult.success(null));

        final afterDelete = await query.get();
        expect(
          afterDelete.map((it) => it.toDomain()),
          seededFaculty.sublist(1),
        );
      });

      test('returns success when deleting non existing faculty', () async {
        final result = await repository.delete(createdFaculty.id);

        expect(result, AppResult.success(null));
      });

      test(
        'returns failure with internal code '
        'when unintended unintended exception occurred',
        () async {
          whenCalling(Invocation.method(#delete, null))
              .on(repository)
              .thenThrow(Exception());

          final result = await repository.delete(createdFaculty.id);

          result.expectFailureWithCode(.internal);
        },
      );
    });

    group('watch', () {
      test('emits corrects faculties', () async {
        final stream = repository.watch();

        expect(stream, emits(AppResult.success(seededFaculty)));
      });

      test('emits failure with internal code '
          'when unintended exception occurred', () async {
        whenCalling(Invocation.method(#watch, null))
            .on(repository)
            .thenThrow(Exception());

        final stream = repository.watch();

        expect(
          stream,
          emits(
            isA<AppFailure<List<Faculty>>>().having(
              (e) => e.exception.code,
              'exception.code',
              AppExceptionCode.internal,
            ),
          ),
        );
      });
    });

    group('update', () {
      test('returns updated faculty and saved id', () async {
        final toBeUpdated = seededFaculty.first;
        final expectedUpdated = Faculty(
          id: toBeUpdated.id,
          name: 'updated name',
        );
        final query = database.select(database.facultiesDrift);
        final before = await query.get();
        expect(before.map((it) => it.toDomain()), seededFaculty);

        final updated = await repository.update(
          toBeUpdated.id,
          args: UpdateFacultyParams(
            toBeUpdated,
            name: expectedUpdated.name,
          ),
        );

        expect(updated, AppResult.success(expectedUpdated));

        final after = await query.get();
        expect(after.map((it) => it.toDomain()), [
          expectedUpdated,
          ...seededFaculty.sublist(1),
        ]);
      });

      test('returns failure with facultyNotFound code '
          'when update non existing faculty', () async {
        final result = await repository.update(
          createdFaculty.id,
          args: const UpdateFacultyParams(createdFaculty, name: 'new name'),
        );

        result.expectFailureWithCode(.facultyNotFound);
      });

      test('returns failure with facultyAlreadyExists code '
          'when update with existing name', () async {
        final result = await repository.update(
          seededFaculty.first.id,
          args: UpdateFacultyParams(
            createdFaculty,
            name: seededFaculty[1].name,
          ),
        );

        result.expectFailureWithCode(.facultyAlreadyExists);
      });

      test('returns failure with internal code '
          'when unintended exception occurred', () async {
        whenCalling(Invocation.method(#update, null))
            .on(repository)
            .thenThrow(Exception());

        final result = await repository.update(
          seededFaculty.first.id,
          args: UpdateFacultyParams(seededFaculty.first, name: 'new name'),
        );

        result.expectFailureWithCode(.internal);
      });
    });

    group('watchSingle', () {
      test('emits correct faculty when faculty exists', () {
        final result = repository.watchSingle(seededFaculty.first.id);

        expect(result, emits(AppResult.success(seededFaculty.first)));
      });

      test('emits failure with facultyNotFound code '
          'when faculty not exists', () {
        final result = repository.watchSingle('not-exists');

        expect(
          result,
          emits(
            isA<AppFailure<Faculty>>().having(
              (e) => e.exception.code,
              'exception.code',
              AppExceptionCode.facultyNotFound,
            ),
          ),
        );
      });
    });
  });
}
