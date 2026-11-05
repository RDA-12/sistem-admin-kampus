import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/lecturer/domain/entities.dart';
import 'package:sistem_admin/lecturer/domain/filters/lecturer_filter.dart';
import 'package:sistem_admin/lecturer/domain/repository.dart';

/// Use case to watch for [Lecturer] data changes for specific program
@LazySingleton(env: [Environment.prod])
class WatchLecturersByProgramUseCase
    with AppLoggerMixin
    implements StreamBaseUseCase<String, List<Lecturer>> {
  /// Creates new [WatchLecturersByProgramUseCase]
  new({required this._lecturerRepository});

  final ILecturerRepository _lecturerRepository;

  @override
  Stream<AppResult<List<Lecturer>>> call(String params) {
    logDebug(
      'start watching lecturers by program',
      extra: {'programId': params},
    );
    return _lecturerRepository.watch(LecturerFilter(programId: params));
  }
}
