import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/faculty.dart';
import 'package:sistem_admin/program/program.dart';

import '../../common/di_mocks.dart';

void main() {
  const faculty = Faculty(id: 'faculty_1', name: 'Faculty 1');
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
