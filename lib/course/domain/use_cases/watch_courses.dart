import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course/domain/entities.dart';
import 'package:sistem_admin/course/domain/filters/course_filter.dart';
import 'package:sistem_admin/course/domain/repository.dart';

/// Use case to watch for [Course] data changes
@LazySingleton(env: [Environment.prod])
class WatchCoursesUseCase
    with AppLoggerMixin
    implements StreamBaseUseCase<CourseFilter?, List<Course>> {
  /// Creates new [WatchCoursesUseCase]
  new({required this._courseRepository});

  final ICourseRepository _courseRepository;

  @override
  Stream<AppResult<List<Course>>> call([CourseFilter? params]) {
    logDebug(
      'start watching courses',
      extra: params != null ? {'filter': params} : null,
    );
    return _courseRepository.watch(params);
  }
}
