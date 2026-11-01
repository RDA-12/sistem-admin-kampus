import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/domain/entities.dart';
import 'package:sistem_admin/course_schedule/domain/repository.dart';

/// Use case to watch for [CourseScheduleEvent] data changes
@LazySingleton(env: [Environment.prod])
class WatchCourseScheduleEventsUseCase
    with AppLoggerMixin
    implements StreamBaseUseCase<Null, List<CourseScheduleEvent>> {
  /// Creates new [WatchCourseScheduleEventsUseCase]
  new({required this._courseScheduleEventRepository});

  final ICourseScheduleEventRepository _courseScheduleEventRepository;

  @override
  Stream<AppResult<List<CourseScheduleEvent>>> call(Null params) {
    logDebug('start watching course schedule events');
    return _courseScheduleEventRepository.watch();
  }
}
