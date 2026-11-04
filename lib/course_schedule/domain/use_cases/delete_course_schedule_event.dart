import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/domain/entities.dart';
import 'package:sistem_admin/course_schedule/domain/repository.dart';

/// Use case for deleting a [CourseSchedule]
@LazySingleton(env: [Environment.prod])
class DeleteCourseScheduleUseCase
    with AppLoggerMixin
    implements FutureBaseUseCase<CourseSchedule, Null> {
  /// Creates new [DeleteCourseScheduleUseCase]
  new({required this._courseScheduleRepository});

  final ICourseScheduleRepository _courseScheduleRepository;

  @override
  Future<AppResult<Null>> call(CourseSchedule params) async {
    logDebug(
      'start deleting course schedule',
      extra: {'id': params.id},
    );
    final result = await _courseScheduleRepository.delete(params.id);
    switch (result) {
      case AppSuccess():
        logDebug('course schedule deleted');
        return AppResult.success(null);
      case AppFailure<Null>(:final exception):
        logDebug('course schedule deletion failed');
        return AppResult.failure(exception);
    }
  }
}
