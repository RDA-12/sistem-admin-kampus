import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/faculty.dart';

import '../../../common/di_mocks.dart';

void main() {
  const faculty = Faculty(id: 'id', name: 'name');
  late IFacultyRepository facultyRepositoryMock;
  late WatchSingleFacultyUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    facultyRepositoryMock = getIt<IFacultyRepository>();
    when(() => facultyRepositoryMock.watchSingle(faculty.id))
        .thenAnswer((_) => Stream.value(AppResult.success(faculty)));

    useCase = WatchSingleFacultyUseCase(
      facultyRepository: facultyRepositoryMock,
    );
  });

  tearDown(() {
    reset(facultyRepositoryMock);
  });

  group('WatchSingleFacultyUseCase', () {
    test('emits correct list of Faculty', () async {
      final stream = useCase(faculty.id);

      expect(stream, emits(AppResult.success(faculty)));
      verify(() => facultyRepositoryMock.watchSingle(faculty.id)).called(1);
    });

    test('emits failure when repo emits failure', () {
      when(() => facultyRepositoryMock.watchSingle(faculty.id)).thenAnswer(
        (_) => Stream.value(
          AppFailure<Faculty>(exception: AppException.test()),
        ),
      );

      final stream = useCase(faculty.id);

      expect(
        stream,
        emits(AppFailure<Faculty>(exception: AppException.test())),
      );
    });
  });
}
