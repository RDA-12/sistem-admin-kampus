import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course/domain/entities.dart';
import 'package:sistem_admin/course/domain/repository.dart';

/// Use case for watching single [Course] data changes
@LazySingleton(env: [Environment.prod])
class WatchSingleCourseUseCase
    with AppLoggerMixin
    implements StreamBaseUseCase<String, Course> {
  /// Creates new [WatchSingleCourseUseCase]
  new({required this._courseRepository});

  final ICourseRepository _courseRepository;

  @override
  Stream<AppResult<Course>> call(String params) {
    logDebug('start watching single course', extra: {'id': params});
    return _courseRepository.watchSingle(params);
  }
}
