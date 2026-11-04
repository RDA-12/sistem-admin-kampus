import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/domain/entities.dart';
import 'package:sistem_admin/course_schedule/domain/repository.dart';

/// Use case to watch for [CourseSchedule] data changes for specific
/// academic year
@LazySingleton(env: [Environment.prod])
class WatchCourseSchedulesByYearUseCase
    with AppLoggerMixin
    implements StreamBaseUseCase<String, List<CourseSchedule>> {
  /// Creates new [WatchCourseSchedulesByYearUseCase]
  new({required this._courseScheduleRepository});

  final ICourseScheduleRepository _courseScheduleRepository;

  @override
  Stream<AppResult<List<CourseSchedule>>> call(String params) {
    logDebug(
      'start watching course schedules by academic year',
      extra: {'academicYearId': params},
    );
    return _courseScheduleRepository.watchByAcademicYear(params);
  }
}
