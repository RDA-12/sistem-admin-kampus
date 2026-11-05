import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../../../common/di_mocks.dart';

void main() {
  final params = CreateAcademicTermParams(
    academicYearId: 'year_1',
    name: 'Ganjil',
    startDate: DateTime(2025, 9),
    endDate: DateTime(2026, 1, 31),
  );
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

  late IAcademicYearRepository academicYearRepositoryMock;
  late IAcademicTermRepository academicTermRepositoryMock;
  late CreateAcademicTermUseCase useCase;

  setUpAll(() {
    initializeMockDependencies();
    registerFallbackValue(params);
    registerFallbackValue(const AcademicTermFilter());
  });

  setUp(() {
    academicYearRepositoryMock = getIt<IAcademicYearRepository>();
    academicTermRepositoryMock = getIt<IAcademicTermRepository>();

    when(
      () => academicYearRepositoryMock.watchSingle('year_1'),
    ).thenAnswer((_) => Stream.value(AppResult.success(academicYear)));

    when(
      () => academicTermRepositoryMock.watch(
        const AcademicTermFilter(academicYearId: 'year_1'),
      ),
    ).thenAnswer((_) => Stream.value(AppResult.success(const [])));

    when(
      () => academicTermRepositoryMock.save(params),
    ).thenAnswer((_) async => AppResult.success(term));

    useCase = CreateAcademicTermUseCase(
      academicTermRepository: academicTermRepositoryMock,
      academicYearRepository: academicYearRepositoryMock,
    );
  });

  tearDown(() {
    reset(academicYearRepositoryMock);
    reset(academicTermRepositoryMock);
  });

  group('CreateAcademicTermUseCase', () {
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
          () => academicTermRepositoryMock.watch(any()),
        );
        verifyNever(() => academicTermRepositoryMock.save(any()));
      },
    );

    test(
      'returns failure when IAcademicTermRepository.watch fails',
      () async {
        when(
          () => academicTermRepositoryMock.watch(
            const AcademicTermFilter(academicYearId: 'year_1'),
          ),
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
        verifyNever(() => academicTermRepositoryMock.save(any()));
      },
    );

    test(
      'returns failure with academicTermOutsideYear when new term is outside '
      'academic year',
      () async {
        final outsideParams = CreateAcademicTermParams(
          academicYearId: 'year_1',
          name: 'Ganjil',
          startDate: DateTime(2025, 8),
          endDate: DateTime(2026, 1, 31),
        );

        final result = await useCase(outsideParams);

        expect(
          result,
          isA<AppFailure<AcademicTerm>>().having(
            (e) => e.exception.code,
            'code',
            AppExceptionCode.academicTermOutsideYear,
          ),
        );
        verifyNever(() => academicTermRepositoryMock.save(any()));
      },
    );

    test(
      'returns failure with academicTermOverlapped when new term overlaps '
      'with existing terms',
      () async {
        final existingTerm = AcademicTerm(
          id: 'existing_term_1',
          academicYearId: 'year_1',
          name: 'Ganjil Existing',
          startDate: DateTime(2025, 9),
          endDate: DateTime(2026, 1, 31),
        );
        when(
          () => academicTermRepositoryMock.watch(
            const AcademicTermFilter(academicYearId: 'year_1'),
          ),
        ).thenAnswer((_) => Stream.value(AppResult.success([existingTerm])));

        final result = await useCase(params);

        expect(
          result,
          isA<AppFailure<AcademicTerm>>().having(
            (e) => e.exception.code,
            'code',
            AppExceptionCode.academicTermOverlapped,
          ),
        );
        verifyNever(() => academicTermRepositoryMock.save(any()));
      },
    );

    test('returns failure when IAcademicTermRepository.save fails', () async {
      when(() => academicTermRepositoryMock.save(params)).thenAnswer(
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
    });

    test('returns correct AcademicTerm when all operations succeed', () async {
      final result = await useCase(params);

      expect(result, AppResult.success(term));
      verify(() => academicYearRepositoryMock.watchSingle('year_1')).called(1);
      verify(
        () => academicTermRepositoryMock.watch(
          const AcademicTermFilter(academicYearId: 'year_1'),
        ),
      ).called(1);
      verify(() => academicTermRepositoryMock.save(params)).called(1);
    });
  });
}
