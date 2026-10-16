import 'package:injectable/injectable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/course/course.dart';

@LazySingleton(as: ICourseRepository, env: [Environment.test])
class MockCourseRepository extends Mock implements ICourseRepository;

@LazySingleton(as: WatchCoursesUseCase, env: [Environment.test])
class MockWatchCoursesUseCase extends Mock implements WatchCoursesUseCase;

@LazySingleton(as: WatchCoursesByProgramUseCase, env: [Environment.test])
class MockWatchCoursesByProgramUseCase extends Mock
    implements WatchCoursesByProgramUseCase;

@LazySingleton(as: WatchSingleCourseUseCase, env: [Environment.test])
class MockWatchSingleCourseUseCase extends Mock
    implements WatchSingleCourseUseCase;

@LazySingleton(as: CreateCourseUseCase, env: [Environment.test])
class MockCreateCourseUseCase extends Mock implements CreateCourseUseCase;

@LazySingleton(as: UpdateCourseUseCase, env: [Environment.test])
class MockUpdateCourseUseCase extends Mock implements UpdateCourseUseCase;

@LazySingleton(as: DeleteCourseUseCase, env: [Environment.test])
class MockDeleteCourseUseCase extends Mock implements DeleteCourseUseCase;

final coursesMock = List<Course>.generate(
  5,
  (index) => Course(
    id: '$index',
    programId: 'program_1',
    code: 'CS10$index',
    name: 'Course $index',
    semester: index + 1,
    credit: 3,
  ),
);
const courseMock = Course(
  id: 'id',
  programId: 'program_1',
  code: 'CS101',
  name: 'Course',
  semester: 1,
  credit: 3,
);
