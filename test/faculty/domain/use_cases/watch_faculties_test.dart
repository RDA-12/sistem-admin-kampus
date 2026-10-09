import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/faculty.dart';

import '../../../common/di_mocks.dart';

void main() {
  final faculties = List.generate(
    5,
    (index) => Faculty(id: '$index', name: 'name $index'),
  );
  late IFacultyRepository facultyRepositoryMock;
  late WatchFacultiesUseCase useCase;

  setUpAll(initializeMockDependencies);

  setUp(() {
    facultyRepositoryMock = getItMock<IFacultyRepository>();
    when(() => facultyRepositoryMock.watch())
        .thenAnswer((_) => Stream.value(AppResult.success(faculties)));

    useCase = WatchFacultiesUseCase(
      facultyRepository: facultyRepositoryMock,
    );
  });

  group('WatchFacultiesUseCase', () {
    test('emits correct list of Faculty', () async {
      final stream = useCase(null);

      expect(stream, emits(AppResult.success(faculties)));
    });

    test('emits failure when repo emits failure', () {
      when(() => facultyRepositoryMock.watch()).thenAnswer(
        (_) => Stream.value(
          AppFailure<List<Faculty>>(exception: AppException.test()),
        ),
      );

      final stream = useCase(null);

      expect(
        stream,
        emits(AppFailure<List<Faculty>>(exception: AppException.test())),
      );
    });
  });
}
