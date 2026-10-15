import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/program/domain/entities.dart';
import 'package:sistem_admin/program/domain/repository.dart';

/// Use case to watch for [Program] data changes for specific faculty
@LazySingleton(env: [Environment.prod])
class WatchProgramsByFacultyUseCase
    with AppLoggerMixin
    implements StreamBaseUseCase<String, List<Program>> {
  /// Creates new [WatchProgramsByFacultyUseCase]
  new({required this._programRepository});

  final IProgramRepository _programRepository;

  @override
  Stream<AppResult<List<Program>>> call(String params) {
    logDebug(
      'start watching programs by faculty',
      extra: {'facultyId': params},
    );
    return _programRepository.watchByFaculty(params);
  }
}
