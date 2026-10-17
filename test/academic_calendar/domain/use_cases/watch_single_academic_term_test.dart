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
  late WatchSingleAcademicTermUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    repositoryMock = getIt<IAcademicTermRepository>();
    when(() => repositoryMock.watchSingle('id'))
        .thenAnswer((_) => Stream.value(AppResult.success(term)));

    useCase = WatchSingleAcademicTermUseCase(
      academicTermRepository: repositoryMock,
    );
  });

  tearDown(() {
    reset(repositoryMock);
  });

  group('WatchSingleAcademicTermUseCase', () {
    test('emits correct AcademicTerm', () async {
      final stream = useCase('id');

      expect(stream, emits(AppResult.success(term)));
    });

    test('emits failure when repo emits failure', () {
      when(() => repositoryMock.watchSingle('id')).thenAnswer(
        (_) => Stream.value(
          AppFailure<AcademicTerm>(exception: AppException.test()),
        ),
      );

      final stream = useCase('id');

      expect(
        stream,
        emits(AppFailure<AcademicTerm>(exception: AppException.test())),
      );
    });
  });
}
