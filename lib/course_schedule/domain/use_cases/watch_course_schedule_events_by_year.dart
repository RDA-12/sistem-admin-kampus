import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/domain/entities.dart';
import 'package:sistem_admin/course_schedule/domain/repository.dart';

/// Use case to watch for [CourseScheduleEvent] data changes for specific
/// academic year
@LazySingleton(env: [Environment.prod])
class WatchCourseScheduleEventsByYearUseCase
    with AppLoggerMixin
    implements StreamBaseUseCase<String, List<CourseScheduleEvent>> {
  /// Creates new [WatchCourseScheduleEventsByYearUseCase]
  new({required this._courseScheduleEventRepository});

  final ICourseScheduleEventRepository _courseScheduleEventRepository;

  @override
  Stream<AppResult<List<CourseScheduleEvent>>> call(String params) {
    logDebug(
      'start watching course schedule events by academic year',
      extra: {'academicYearId': params},
    );
    return _courseScheduleEventRepository.watchByAcademicYear(params);
  }
}
