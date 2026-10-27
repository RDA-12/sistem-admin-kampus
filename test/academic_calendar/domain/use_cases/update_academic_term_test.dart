import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../../../common/di_mocks.dart';

void main() {
  final academicYear = AcademicYear(
    id: 'year_1',
    name: '2025/2026',
    startDate: DateTime(2025, 9),
    endDate: DateTime(2026, 8, 31),
  );
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

  late IAcademicYearRepository academicYearRepositoryMock;
  late IAcademicTermRepository academicTermRepositoryMock;
  late UpdateAcademicTermUseCase useCase;

  setUpAll(() {
    initializeMockDependencies();
    registerFallbackValue(params);
  });

  setUp(() {
    academicYearRepositoryMock = getIt<IAcademicYearRepository>();
    academicTermRepositoryMock = getIt<IAcademicTermRepository>();

    when(
      () => academicYearRepositoryMock.watchSingle('year_1'),
    ).thenAnswer((_) => Stream.value(AppResult.success(academicYear)));

    when(
      () => academicTermRepositoryMock.watchByAcademicYear('year_1'),
    ).thenAnswer((_) => Stream.value(AppResult.success([term])));

    when(
      () => academicTermRepositoryMock.update(term.id, args: params),
    ).thenAnswer((_) async => AppResult.success(term));

    useCase = UpdateAcademicTermUseCase(
      academicTermRepository: academicTermRepositoryMock,
      academicYearRepository: academicYearRepositoryMock,
    );
  });

  tearDown(() {
    reset(academicYearRepositoryMock);
    reset(academicTermRepositoryMock);
  });

  group('UpdateAcademicTermUseCase', () {
    test(
      'returns failure when IAcademicYearRepository.watchSingle fails',
      () async {
        when(
          () => academicYearRepositoryMock.watchSingle('year_1'),
        ).thenAnswer(
          (_) => Stream.value(
            AppFailure<AcademicYear>(exception: AppException.test()),
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
        verifyNever(
          () => academicTermRepositoryMock.watchByAcademicYear(any()),
        );
        verifyNever(
          () => academicTermRepositoryMock.update(
            any(),
            args: any(named: 'args'),
          ),
        );
      },
    );

    test(
      'returns failure when IAcademicTermRepository.watchByAcademicYear fails',
      () async {
        when(
          () => academicTermRepositoryMock.watchByAcademicYear('year_1'),
        ).thenAnswer(
          (_) => Stream.value(
            AppFailure<List<AcademicTerm>>(exception: AppException.test()),
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
        verifyNever(
          () => academicTermRepositoryMock.update(
            any(),
            args: any(named: 'args'),
          ),
        );
      },
    );

    test(
      'returns failure with academicTermOverlapped when updated term overlaps '
      'with another term',
      () async {
        final otherTerm = AcademicTerm(
          id: 'other_term_id',
          academicYearId: 'year_1',
          name: 'Genap',
          startDate: DateTime(2026, 2),
          endDate: DateTime(2026, 6, 30),
        );
        when(
          () => academicTermRepositoryMock.watchByAcademicYear('year_1'),
        ).thenAnswer((_) => Stream.value(AppResult.success([term, otherTerm])));

        final overlappingParams = UpdateAcademicTermParams(
          term,
          startDate: DateTime(2026, 2),
          endDate: DateTime(2026, 5),
        );

        final result = await useCase(overlappingParams);

        expect(
          result,
          isA<AppFailure<AcademicTerm>>().having(
            (e) => e.exception.code,
            'code',
            AppExceptionCode.academicTermOverlapped,
          ),
        );
        verifyNever(
          () => academicTermRepositoryMock.update(
            any(),
            args: any(named: 'args'),
          ),
        );
      },
    );

    test(
      'returns failure when IAcademicTermRepository.update fails',
      () async {
        when(
          () => academicTermRepositoryMock.update(term.id, args: params),
        ).thenAnswer(
          (_) async => AppResult<AcademicTerm>.failure(AppException.test()),
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

    test('returns correct AcademicTerm when all operations succeed', () async {
      final result = await useCase(params);

      expect(result, AppResult.success(term));
      verify(() => academicYearRepositoryMock.watchSingle('year_1')).called(1);
      verify(
        () => academicTermRepositoryMock.watchByAcademicYear('year_1'),
      ).called(1);
      verify(
        () => academicTermRepositoryMock.update(term.id, args: params),
      ).called(1);
    });
  });
}
