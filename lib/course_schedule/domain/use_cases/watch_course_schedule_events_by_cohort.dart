import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/domain/entities.dart';
import 'package:sistem_admin/course_schedule/domain/repository.dart';

/// Use case to watch for [CourseScheduleEvent] data changes for specific
/// cohort
@LazySingleton(env: [Environment.prod])
class WatchCourseScheduleEventsByCohortUseCase
    with AppLoggerMixin
    implements StreamBaseUseCase<String, List<CourseScheduleEvent>> {
  /// Creates new [WatchCourseScheduleEventsByCohortUseCase]
  new({required this._courseScheduleEventRepository});

  final ICourseScheduleEventRepository _courseScheduleEventRepository;

  @override
  Stream<AppResult<List<CourseScheduleEvent>>> call(String params) {
    logDebug(
      'start watching course schedule events by cohort',
      extra: {'cohortId': params},
    );
    return _courseScheduleEventRepository.watchByCohort(params);
  }
}
