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

  final termStart = DateTime(2025, 9);
  final termEnd = DateTime(2026, 1, 31);
  final createdTerm = AcademicTerm(
    id: 'uid_term',
    academicYearId: year.id,
    name: 'Ganjil',
    startDate: termStart,
    endDate: termEnd,
  );
  final seededTerms = List.generate(
    2,
    (index) => AcademicTerm(
      id: 'term_$index',
      academicYearId: year.id,
      name: index == 0 ? 'Semester 1' : 'Semester 2',
      startDate: DateTime(2025, index == 0 ? 9 : 2),
      endDate: DateTime(2026, index == 0 ? 1 : 6, 30),
    ),
  );

  late AcademicTermRepository repository;
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
    for (final t in seededTerms) {
      await database
          .into(database.academicTermsDrift)
          .insert(
            AcademicTermsDriftCompanion.insert(
              id: t.id,
              academicYearId: t.academicYearId,
              name: t.name,
              startDate: t.startDate,
              endDate: t.endDate,
            ),
          );
    }

    uidGeneratorMock = getIt<UidGenerator>();
    when(uidGeneratorMock.generate).thenReturn(createdTerm.id);

    repository = AcademicTermRepository(
      db: database,
      uidGenerator: uidGeneratorMock,
    );
  });

  tearDown(() async {
    await database.delete(database.academicTermsDrift).go();
    await database.delete(database.academicYearsDrift).go();
  });

  group('AcademicTermRepository', () {
    group('save', () {
      final createArgs = CreateAcademicTermParams(
        academicYearId: year.id,
        name: 'Ganjil',
        startDate: termStart,
        endDate: termEnd,
      );

      test('returns correct new academic term and saves it', () async {
        when(uidGeneratorMock.generate).thenReturn(createdTerm.id);
        final now = DateTime.now();
        await withClock(Clock.fixed(now), () async {
          final result = await repository.save(createArgs);

          expect(result, AppResult.success(createdTerm));

          final query = database.select(database.academicTermsDrift)
            ..where((tbl) => tbl.id.equals(createdTerm.id));
          final exists = await query.getSingleOrNull();
          expect(exists, isNotNull);
          expect(exists!.name, createArgs.name);
          expect(exists.academicYearId, createArgs.academicYearId);
          expect(exists.startDate, createArgs.startDate);
          expect(exists.endDate, createArgs.endDate);
          expect(exists.createdAt, now);
          expect(exists.updatedAt, now);
        });
      });

      test(
        'returns failure with academicTermAlreadyExists code '
        'when save term with existing name in same academic year',
        () async {
          when(uidGeneratorMock.generate).thenReturn('some_id');
          await repository.save(createArgs);

          final result = await repository.save(createArgs);

          result.expectFailureWithCode(
            AppExceptionCode.academicTermAlreadyExists,
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
      test('returns success and deletes requested academic term', () async {
        final query = database.select(database.academicTermsDrift);
        final before = await query.get();
        expect(before.map((it) => it.toDomain()), seededTerms);

        final result = await repository.delete(seededTerms.first.id);

        expect(result, AppResult.success(null));

        final after = await query.get();
        expect(after.map((it) => it.toDomain()), seededTerms.sublist(1));
      });

      test(
        'returns success when deleting non-existent academic term',
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
      test('emits correct academic terms', () async {
        final stream = repository.watch();

        expect(stream, emits(AppResult.success(seededTerms)));
      });

      test('emits failure when exception occurs', () async {
        whenCalling(Invocation.method(#watch, null))
            .on(repository)
            .thenThrow(Exception());

        final stream = repository.watch();

        expect(
          stream,
          emits(
            isA<AppFailure<List<AcademicTerm>>>().having(
              (e) => e.exception.code,
              'exception.code',
              AppExceptionCode.internal,
            ),
          ),
        );
      });
    });

    group('watch with filter', () {
      test('emits correct academic terms for academic year', () async {
        final stream = repository.watch(
          AcademicTermFilter(academicYearId: year.id),
        );

        expect(stream, emits(AppResult.success(seededTerms)));
      });

      test('emits failure when exception occurs', () async {
        whenCalling(Invocation.method(#watch, null))
            .on(repository)
            .thenThrow(Exception());

        final stream = repository.watch(
          AcademicTermFilter(academicYearId: year.id),
        );

        expect(
          stream,
          emits(
            isA<AppFailure<List<AcademicTerm>>>().having(
              (e) => e.exception.code,
              'exception.code',
              AppExceptionCode.internal,
            ),
          ),
        );
      });
    });

    group('watchSingle', () {
      test('emits correct academic term when exists', () {
        final result = repository.watchSingle(seededTerms.first.id);

        expect(result, emits(AppResult.success(seededTerms.first)));
      });

      test('emits failure with academicTermNotFound when not exists', () {
        final result = repository.watchSingle('not-exists');

        expect(
          result,
          emits(
            isA<AppFailure<AcademicTerm>>().having(
              (e) => e.exception.code,
              'exception.code',
              AppExceptionCode.academicTermNotFound,
            ),
          ),
        );
      });
    });

    group('update', () {
      test('returns updated academic term and saves changes in db', () async {
        final expectedUpdated = AcademicTerm(
          id: seededTerms.first.id,
          academicYearId: seededTerms.first.academicYearId,
          name: 'Updated Term 1',
          startDate: seededTerms.first.startDate,
          endDate: seededTerms.first.endDate,
        );

        final updated = await repository.update(
          seededTerms.first.id,
          args: UpdateAcademicTermParams(
            seededTerms.first,
            name: 'Updated Term 1',
          ),
        );

        expect(updated, AppResult.success(expectedUpdated));

        final query = database.select(database.academicTermsDrift)
          ..where((tbl) => tbl.id.equals(seededTerms.first.id));
        final inDb = await query.getSingle();
        expect(inDb.name, 'Updated Term 1');
      });

      test(
        'returns failure with academicTermNotFound when updating non-existent',
        () async {
          final result = await repository.update(
            'not-exists',
            args: UpdateAcademicTermParams(
              createdTerm,
              name: 'New Name',
            ),
          );

          result.expectFailureWithCode(AppExceptionCode.academicTermNotFound);
        },
      );

      test(
        'returns failure with academicTermAlreadyExists '
        'when updating duplicate',
        () async {
          final result = await repository.update(
            seededTerms.first.id,
            args: UpdateAcademicTermParams(
              seededTerms.first,
              name: seededTerms[1].name,
            ),
          );

          result.expectFailureWithCode(
            AppExceptionCode.academicTermAlreadyExists,
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
            seededTerms.first.id,
            args: UpdateAcademicTermParams(
              seededTerms.first,
              name: 'New Name',
            ),
          );

          result.expectFailureWithCode(AppExceptionCode.internal);
        },
      );
    });
  });
}
