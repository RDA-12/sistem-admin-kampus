import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';

import '../../../common/di_mocks.dart';

void main() {
  final lecturers = List.generate(
    5,
    (index) => Lecturer(
      id: '$index',
      programId: 'program_1',
      name: 'name $index',
      pangkatGolongan: 'III/a',
    ),
  );
  late ILecturerRepository lecturerRepositoryMock;
  late WatchLecturersUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    lecturerRepositoryMock = getIt<ILecturerRepository>();
    when(lecturerRepositoryMock.watch)
        .thenAnswer((_) => Stream.value(AppResult.success(lecturers)));

    useCase = WatchLecturersUseCase(
      lecturerRepository: lecturerRepositoryMock,
    );
  });

  tearDown(() {
    reset(lecturerRepositoryMock);
  });

  group('WatchLecturersUseCase', () {
    test('emits correct list of Lecturer when no filter provided', () async {
      final stream = useCase();

      expect(stream, emits(AppResult.success(lecturers)));
    });

    test('emits correct list of Lecturer when filter provided', () async {
      const filter = LecturerFilter(programId: 'program_1');
      when(() => lecturerRepositoryMock.watch(filter))
          .thenAnswer((_) => Stream.value(AppResult.success(lecturers)));

      final stream = useCase(filter);

      expect(stream, emits(AppResult.success(lecturers)));
    });

    test('emits failure when repo emits failure', () {
      when(lecturerRepositoryMock.watch).thenAnswer(
        (_) => Stream.value(
          AppFailure<List<Lecturer>>(exception: AppException.test()),
        ),
      );

      final stream = useCase();

      expect(
        stream,
        emits(AppFailure<List<Lecturer>>(exception: AppException.test())),
      );
    });
  });
}
