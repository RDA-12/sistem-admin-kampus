import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';

import '../../../common/di_mocks.dart';

void main() {
  const lecturer = Lecturer(
    id: 'id',
    programId: 'program_1',
    name: 'name',
    pangkatGolongan: 'III/a',
  );
  late ILecturerRepository lecturerRepositoryMock;
  late WatchSingleLecturerUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    lecturerRepositoryMock = getIt<ILecturerRepository>();
    when(() => lecturerRepositoryMock.watchSingle('id'))
        .thenAnswer((_) => Stream.value(AppResult.success(lecturer)));

    useCase = WatchSingleLecturerUseCase(
      lecturerRepository: lecturerRepositoryMock,
    );
  });

  tearDown(() {
    reset(lecturerRepositoryMock);
  });

  group('WatchSingleLecturerUseCase', () {
    test('emits correct Lecturer', () async {
      final stream = useCase('id');

      expect(stream, emits(AppResult.success(lecturer)));
    });

    test('emits failure when repo emits failure', () {
      when(() => lecturerRepositoryMock.watchSingle('id')).thenAnswer(
        (_) => Stream.value(
          AppFailure<Lecturer>(exception: AppException.test()),
        ),
      );

      final stream = useCase('id');

      expect(
        stream,
        emits(AppFailure<Lecturer>(exception: AppException.test())),
      );
    });
  });
}
