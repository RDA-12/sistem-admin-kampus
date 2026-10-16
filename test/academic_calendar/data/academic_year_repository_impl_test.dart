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
  final yearStart = DateTime(2025, 9);
  final yearEnd = DateTime(2026, 8, 31);
  final createdYear = AcademicYear(
    id: 'uid_year',
    name: '2025/2026',
    startDate: yearStart,
    endDate: yearEnd,
  );
  final seededYears = List.generate(
    3,
    (index) => AcademicYear(
      id: 'year_$index',
      name: '202$index/202${index + 1}',
      startDate: DateTime(2020 + index, 9),
      endDate: DateTime(2021 + index, 8, 31),
    ),
  );

  late AcademicYearRepository repository;
  late UidGenerator uidGeneratorMock;
  late AppDriftDatabase database;

  setUpAll(initializeMockDependencies);

  setUp(() async {
    database = getIt<AppDriftDatabase>();
    for (final y in seededYears) {
      await database
          .into(database.academicYearsDrift)
          .insert(
            AcademicYearsDriftCompanion.insert(
              id: y.id,
              name: y.name,
              startDate: y.startDate,
              endDate: y.endDate,
            ),
          );
    }

    uidGeneratorMock = getIt<UidGenerator>();
    when(uidGeneratorMock.generate).thenReturn(createdYear.id);

    repository = AcademicYearRepository(
      db: database,
      uidGenerator: uidGeneratorMock,
    );
  });

  tearDown(() async {
    await database.delete(database.academicYearsDrift).go();
  });

  group('AcademicYearRepository', () {
    group('save', () {
      final createArgs = CreateAcademicYearParams(
        name: '2025/2026',
        startDate: yearStart,
        endDate: yearEnd,
      );

      test('returns correct new academic year and saves it', () async {
        final now = DateTime.now();
        await withClock(Clock.fixed(now), () async {
          final result = await repository.save(createArgs);

          expect(result, AppResult.success(createdYear));

          final query = database.select(database.academicYearsDrift)
            ..where((tbl) => tbl.id.equals(createdYear.id));
          final exists = await query.getSingleOrNull();
          expect(exists, isNotNull);
          expect(exists!.name, createArgs.name);
          expect(exists.startDate, createArgs.startDate);
          expect(exists.endDate, createArgs.endDate);
          expect(exists.createdAt, now);
          expect(exists.updatedAt, now);
        });
      });

      test(
        'returns failure with academicYearAlreadyExists code '
        'when save with existing name',
        () async {
          await repository.save(createArgs);

          final result = await repository.save(createArgs);

          result.expectFailureWithCode(
            AppExceptionCode.academicYearAlreadyExists,
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
      test('returns success and deletes requested academic year', () async {
        final query = database.select(database.academicYearsDrift);
        final before = await query.get();
        expect(before.map((it) => it.toDomain()), seededYears);

        final result = await repository.delete(seededYears.first.id);

        expect(result, AppResult.success(null));

        final after = await query.get();
        expect(after.map((it) => it.toDomain()), seededYears.sublist(1));
      });

      test(
        'returns success when deleting non-existent academic year',
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
      test('emits correct academic years', () async {
        final stream = repository.watch();

        expect(stream, emits(AppResult.success(seededYears)));
      });

      test('emits failure when exception occurs', () async {
        whenCalling(Invocation.method(#watch, null))
            .on(repository)
            .thenThrow(Exception());

        final stream = repository.watch();

        expect(
          stream,
          emits(
            isA<AppFailure<List<AcademicYear>>>().having(
              (e) => e.exception.code,
              'exception.code',
              AppExceptionCode.internal,
            ),
          ),
        );
      });
    });

    group('watchSingle', () {
      test('emits correct academic year when exists', () {
        final result = repository.watchSingle(seededYears.first.id);

        expect(result, emits(AppResult.success(seededYears.first)));
      });

      test('emits failure with academicYearNotFound when not exists', () {
        final result = repository.watchSingle('not-exists');

        expect(
          result,
          emits(
            isA<AppFailure<AcademicYear>>().having(
              (e) => e.exception.code,
              'exception.code',
              AppExceptionCode.academicYearNotFound,
            ),
          ),
        );
      });
    });

    group('update', () {
      test('returns updated academic year and saves changes in db', () async {
        final expectedUpdated = AcademicYear(
          id: seededYears.first.id,
          name: 'Updated 2020/2021',
          startDate: seededYears.first.startDate,
          endDate: seededYears.first.endDate,
        );

        final updated = await repository.update(
          seededYears.first.id,
          args: UpdateAcademicYearParams(
            seededYears.first,
            name: 'Updated 2020/2021',
          ),
        );

        expect(updated, AppResult.success(expectedUpdated));

        final query = database.select(database.academicYearsDrift)
          ..where((tbl) => tbl.id.equals(seededYears.first.id));
        final inDb = await query.getSingle();
        expect(inDb.name, 'Updated 2020/2021');
      });

      test(
        'returns failure with academicYearNotFound when updating non-existent',
        () async {
          final result = await repository.update(
            'not-exists',
            args: UpdateAcademicYearParams(
              createdYear,
              name: 'New Name',
            ),
          );

          result.expectFailureWithCode(AppExceptionCode.academicYearNotFound);
        },
      );

      test(
        'returns failure with academicYearAlreadyExists '
        'when updating duplicate',
        () async {
          final result = await repository.update(
            seededYears.first.id,
            args: UpdateAcademicYearParams(
              seededYears.first,
              name: seededYears[1].name,
            ),
          );

          result.expectFailureWithCode(
            AppExceptionCode.academicYearAlreadyExists,
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
            seededYears.first.id,
            args: UpdateAcademicYearParams(
              seededYears.first,
              name: 'New Name',
            ),
          );

          result.expectFailureWithCode(AppExceptionCode.internal);
        },
      );
    });
  });
}
