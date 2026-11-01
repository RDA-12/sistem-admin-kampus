import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/domain/entities.dart';
import 'package:sistem_admin/course_schedule/domain/repository.dart';

/// Use case for deleting a [CourseScheduleEvent]
@LazySingleton(env: [Environment.prod])
class DeleteCourseScheduleEventUseCase
    with AppLoggerMixin
    implements FutureBaseUseCase<CourseScheduleEvent, Null> {
  /// Creates new [DeleteCourseScheduleEventUseCase]
  new({required this._courseScheduleEventRepository});

  final ICourseScheduleEventRepository _courseScheduleEventRepository;

  @override
  Future<AppResult<Null>> call(CourseScheduleEvent params) async {
    logDebug(
      'start deleting course schedule event',
      extra: {'id': params.id},
    );
    final result = await _courseScheduleEventRepository.delete(params.id);
    switch (result) {
      case AppSuccess():
        logDebug('course schedule event deleted');
        return AppResult.success(null);
      case AppFailure<Null>(:final exception):
        logDebug('course schedule event deletion failed');
        return AppResult.failure(exception);
    }
  }
}
