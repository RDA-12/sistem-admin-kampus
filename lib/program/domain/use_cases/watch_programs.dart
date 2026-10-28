import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/program/domain/entities.dart';
import 'package:sistem_admin/program/domain/repository.dart';

/// Use case to watch for [Program] data changes
@LazySingleton(env: [Environment.prod])
class WatchProgramsUseCase
    with AppLoggerMixin
    implements StreamBaseUseCase<Null, List<Program>> {
  /// Creates new [WatchProgramsUseCase]
  new({required this._programRepository});

  final IProgramRepository _programRepository;

  @override
  Stream<AppResult<List<Program>>> call(Null params) {
    logDebug('start watching programs');
    return _programRepository.watch();
  }
}
