import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course/domain/entities.dart';
import 'package:sistem_admin/course/domain/repository.dart';

/// Use case for deleting a [Course]
@LazySingleton(env: [Environment.prod])
class DeleteCourseUseCase
    with AppLoggerMixin
    implements FutureBaseUseCase<Course, Null> {
  /// Creates new [DeleteCourseUseCase]
  new({required this._courseRepository});

  final ICourseRepository _courseRepository;

  @override
  Future<AppResult<Null>> call(Course params) async {
    logDebug('start deleting course', extra: {'id': params.id});
    final result = await _courseRepository.delete(params.id);
    switch (result) {
      case AppSuccess():
        logDebug('course deleted');
        return AppResult.success(null);
      case AppFailure<Null>(:final exception):
        logDebug('course deletion failed');
        return AppResult.failure(exception);
    }
  }
}
