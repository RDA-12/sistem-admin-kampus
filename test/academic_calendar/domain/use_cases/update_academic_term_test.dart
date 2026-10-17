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
  final params = UpdateAcademicTermParams(
    term,
    name: 'Genap',
  );
  late IAcademicTermRepository repositoryMock;
  late UpdateAcademicTermUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    repositoryMock = getIt<IAcademicTermRepository>();
    when(() => repositoryMock.update(term.id, args: params))
        .thenAnswer((_) async => AppResult.success(term));

    useCase = UpdateAcademicTermUseCase(
      academicTermRepository: repositoryMock,
    );
  });

  tearDown(() {
    reset(repositoryMock);
  });

  group('UpdateAcademicTermUseCase', () {
    test(
      'returns failure when IAcademicTermRepository.update fails',
      () async {
        when(() => repositoryMock.update(term.id, args: params)).thenAnswer(
          (_) async => AppResult<AcademicTerm>.failure(
            AppException.test(),
          ),
        );

        final result = await useCase(params);

        expect(
          result,
          isA<AppFailure<AcademicTerm>>().having(
            (e) => e.exception,
            'exception',
            AppException.test(),
          ),
        );
      },
    );

    test('returns correct AcademicTerm when all operations success', () async {
      final result = await useCase(params);

      expect(result, AppResult.success(term));
      verify(() => repositoryMock.update(term.id, args: params)).called(1);
    });
  });
}
