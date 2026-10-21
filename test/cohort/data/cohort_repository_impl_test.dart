import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/cohort/cohort.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../../common/di_mocks.dart';
import '../../common/helper.dart';

void main() {
  const createdCohort = Cohort(
    id: 'uid_cohort',
    name: 'Cohort 2025',
    entryYear: 2025,
  );
  final seededCohorts = List.generate(
    3,
    (index) => Cohort(
      id: 'cohort_$index',
      name: 'Cohort 202$index',
      entryYear: 2020 + index,
    ),
  );

  late CohortRepository repository;
  late UidGenerator uidGeneratorMock;
  late AppDriftDatabase database;

  setUpAll(initializeMockDependencies);

  setUp(() async {
    database = getIt<AppDriftDatabase>();
    for (final c in seededCohorts) {
      await database
          .into(database.cohortsDrift)
          .insert(
            CohortsDriftCompanion.insert(
              id: c.id,
              name: c.name,
              entryYear: c.entryYear,
            ),
          );
    }

    uidGeneratorMock = getIt<UidGenerator>();
    when(uidGeneratorMock.generate).thenReturn(createdCohort.id);

    repository = CohortRepository(
      db: database,
      uidGenerator: uidGeneratorMock,
    );
  });

  tearDown(() async {
    await database.delete(database.cohortsDrift).go();
  });

  group('CohortRepository', () {
    group('save', () {
      const createArgs = CreateCohortParams(
        name: 'Cohort 2025',
        entryYear: 2025,
      );

      test('returns correct new cohort and saves it', () async {
        final now = DateTime.now();
        await withClock(Clock.fixed(now), () async {
          final result = await repository.save(createArgs);

          expect(result, AppResult.success(createdCohort));

          final query = database.select(database.cohortsDrift)
            ..where((tbl) => tbl.id.equals(createdCohort.id));
          final exists = await query.getSingleOrNull();
          expect(exists, isNotNull);
          expect(exists!.name, createArgs.name);
          expect(exists.entryYear, createArgs.entryYear);
          expect(exists.createdAt, now);
          expect(exists.updatedAt, now);
        });
      });

      test(
        'returns failure with cohortAlreadyExists code '
        'when save with existing name',
        () async {
          await repository.save(createArgs);

          final result = await repository.save(createArgs);

          result.expectFailureWithCode(
            AppExceptionCode.cohortAlreadyExists,
          );
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
      test('returns success and deletes requested cohort', () async {
        final query = database.select(database.cohortsDrift);
        final before = await query.get();
        expect(before.map((it) => it.toDomain()), seededCohorts);

        final result = await repository.delete(seededCohorts.first.id);

        expect(result, AppResult.success(null));

        final after = await query.get();
        expect(after.map((it) => it.toDomain()), seededCohorts.sublist(1));
      });

      test(
        'returns success when deleting non-existent cohort',
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
      test('emits correct cohorts', () async {
        final stream = repository.watch();

        expect(stream, emits(AppResult.success(seededCohorts)));
      });

      test('emits failure when exception occurs', () async {
        whenCalling(Invocation.method(#watch, null))
            .on(repository)
            .thenThrow(Exception());

        final stream = repository.watch();

        expect(
          stream,
          emits(
            isA<AppFailure<List<Cohort>>>().having(
              (e) => e.exception.code,
              'exception.code',
              AppExceptionCode.internal,
            ),
          ),
        );
      });
    });

    group('watchSingle', () {
      test('emits correct cohort when exists', () {
        final result = repository.watchSingle(seededCohorts.first.id);

        expect(result, emits(AppResult.success(seededCohorts.first)));
      });

      test('emits failure with cohortNotFound when not exists', () {
        final result = repository.watchSingle('not-exists');

        expect(
          result,
          emits(
            isA<AppFailure<Cohort>>().having(
              (e) => e.exception.code,
              'exception.code',
              AppExceptionCode.cohortNotFound,
            ),
          ),
        );
      });
    });

    group('update', () {
      test('returns updated cohort and saves changes in db', () async {
        final expectedUpdated = Cohort(
          id: seededCohorts.first.id,
          name: 'Updated Cohort 2020',
          entryYear: 2021,
        );

        final updated = await repository.update(
          seededCohorts.first.id,
          args: UpdateCohortParams(
            seededCohorts.first,
            name: 'Updated Cohort 2020',
            entryYear: 2021,
          ),
        );

        expect(updated, AppResult.success(expectedUpdated));

        final query = database.select(database.cohortsDrift)
          ..where((tbl) => tbl.id.equals(seededCohorts.first.id));
        final inDb = await query.getSingle();
        expect(inDb.name, 'Updated Cohort 2020');
        expect(inDb.entryYear, 2021);
      });

      test(
        'returns failure with cohortNotFound when updating non-existent',
        () async {
          final result = await repository.update(
            'not-exists',
            args: const UpdateCohortParams(
              createdCohort,
              name: 'New Name',
            ),
          );

          result.expectFailureWithCode(AppExceptionCode.cohortNotFound);
        },
      );

      test(
        'returns failure with cohortAlreadyExists '
        'when updating duplicate',
        () async {
          final result = await repository.update(
            seededCohorts.first.id,
            args: UpdateCohortParams(
              seededCohorts.first,
              name: seededCohorts[1].name,
            ),
          );

          result.expectFailureWithCode(
            AppExceptionCode.cohortAlreadyExists,
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
            seededCohorts.first.id,
            args: UpdateCohortParams(
              seededCohorts.first,
              name: 'New Name',
            ),
          );

          result.expectFailureWithCode(AppExceptionCode.internal);
        },
      );
    });
  });
}
