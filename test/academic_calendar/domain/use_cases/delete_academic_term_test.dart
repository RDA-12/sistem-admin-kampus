import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../../../common/di_mocks.dart';

void main() {
  final term = AcademicTerm(
    id: 'id',
    academicYearId: 'year_1',
    name: 'Ganjil',
    startDate: DateTime(2025, 9),
    endDate: DateTime(2026, 1, 31),
  );
  late IAcademicTermRepository repositoryMock;
  late DeleteAcademicTermUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    repositoryMock = getIt<IAcademicTermRepository>();
    when(() => repositoryMock.delete(term.id))
        .thenAnswer((_) async => AppResult.success(null));

    useCase = DeleteAcademicTermUseCase(
      academicTermRepository: repositoryMock,
    );
  });

  tearDown(() {
    reset(repositoryMock);
  });

  group('DeleteAcademicTermUseCase', () {
    test(
      'returns failure when IAcademicTermRepository.delete fails',
      () async {
        when(() => repositoryMock.delete(term.id)).thenAnswer(
          (_) async => AppResult<Null>.failure(
            AppException.test(),
          ),
        );

        final result = await useCase(term);

        expect(
          result,
          isA<AppFailure<Null>>().having(
            (e) => e.exception,
            'exception',
            AppException.test(),
          ),
        );
      },
    );

    test('returns correct null when all operations success', () async {
      final result = await useCase(term);

      expect(result, AppResult.success(null));
      verify(() => repositoryMock.delete(term.id)).called(1);
    });
  });
}
