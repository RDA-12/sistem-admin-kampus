import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course/domain/entities.dart';
import 'package:sistem_admin/course/domain/repository.dart';

/// Use case to watch for [Course] data changes
@LazySingleton(env: [Environment.prod])
class WatchCoursesUseCase
    with AppLoggerMixin
    implements StreamBaseUseCase<Null, List<Course>> {
  /// Creates new [WatchCoursesUseCase]
  new({required this._courseRepository});

  final ICourseRepository _courseRepository;

  @override
  Stream<AppResult<List<Course>>> call(Null params) {
    logDebug('start watching courses');
    return _courseRepository.watch();
  }
}
