import 'package:injectable/injectable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/course/course.dart';

@LazySingleton(as: CoursesBloc, env: [Environment.test])
class MockCoursesBloc extends Mock implements CoursesBloc;

@LazySingleton(as: CourseDetailBloc, env: [Environment.test])
class MockCourseDetailBloc extends Mock implements CourseDetailBloc;

@LazySingleton(as: CourseMutationBloc, env: [Environment.test])
class MockCourseMutationBloc extends Mock implements CourseMutationBloc;
