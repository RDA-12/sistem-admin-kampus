import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course/domain/entities.dart';
import 'package:sistem_admin/course/domain/repository.dart';

/// Use case to watch for [Course] data changes for specific program
@LazySingleton(env: [Environment.prod])
class WatchCoursesByProgramUseCase
    with AppLoggerMixin
    implements StreamBaseUseCase<String, List<Course>> {
  /// Creates new [WatchCoursesByProgramUseCase]
  new({required this._courseRepository});

  final ICourseRepository _courseRepository;

  @override
  Stream<AppResult<List<Course>>> call(String params) {
    logDebug(
      'start watching courses by program',
      extra: {'programId': params},
    );
    return _courseRepository.watchByProgram(params);
  }
}
