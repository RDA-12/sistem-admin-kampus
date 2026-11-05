import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../../../common/di_mocks.dart';

void main() {
  final terms = List.generate(
    2,
    (index) => AcademicTerm(
      id: '$index',
      academicYearId: 'year_1',
      name: 'Semester ${index + 1}',
      startDate: DateTime(2025, index == 0 ? 9 : 2),
      endDate: DateTime(2026, index == 0 ? 1 : 6, 30),
    ),
  );
  late IAcademicTermRepository repositoryMock;
  late WatchAcademicTermsByYearUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    repositoryMock = getIt<IAcademicTermRepository>();
    when(
      () => repositoryMock.watch(
        const AcademicTermFilter(academicYearId: 'year_1'),
      ),
    ).thenAnswer((_) => Stream.value(AppResult.success(terms)));

    useCase = WatchAcademicTermsByYearUseCase(
      academicTermRepository: repositoryMock,
    );
  });

  tearDown(() {
    reset(repositoryMock);
  });

  group('WatchAcademicTermsByYearUseCase', () {
    test('emits correct list of AcademicTerm for academic year', () async {
      final stream = useCase('year_1');

      expect(stream, emits(AppResult.success(terms)));
    });

    test('emits failure when repo emits failure', () {
      when(
        () => repositoryMock.watch(
          const AcademicTermFilter(academicYearId: 'year_1'),
        ),
      ).thenAnswer(
        (_) => Stream.value(
          AppFailure<List<AcademicTerm>>(exception: AppException.test()),
        ),
      );

      final stream = useCase('year_1');

      expect(
        stream,
        emits(AppFailure<List<AcademicTerm>>(exception: AppException.test())),
      );
    });
  });
}
