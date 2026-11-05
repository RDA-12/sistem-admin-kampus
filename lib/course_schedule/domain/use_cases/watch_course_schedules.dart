import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/domain/entities.dart';
import 'package:sistem_admin/course_schedule/domain/filters/course_schedule_filter.dart';
import 'package:sistem_admin/course_schedule/domain/repository.dart';

/// Use case to watch for [CourseSchedule] data changes
@LazySingleton(env: [Environment.prod])
class WatchCourseSchedulesUseCase
    with AppLoggerMixin
    implements StreamBaseUseCase<CourseScheduleFilter?, List<CourseSchedule>> {
  /// Creates new [WatchCourseSchedulesUseCase]
  new({required this._courseScheduleRepository});

  final ICourseScheduleRepository _courseScheduleRepository;

  @override
  Stream<AppResult<List<CourseSchedule>>> call([
    CourseScheduleFilter? params,
  ]) {
    logDebug(
      'start watching course schedules',
      extra: params != null ? {'filter': params} : null,
    );
    return _courseScheduleRepository.watch(params);
  }
}
