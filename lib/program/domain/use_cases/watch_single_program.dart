import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/program/domain/entities.dart';
import 'package:sistem_admin/program/domain/repository.dart';

/// Use case for watching single [Program] data changes
@LazySingleton(env: [Environment.prod])
class WatchSingleProgramUseCase
    with AppLoggerMixin
    implements StreamBaseUseCase<String, Program> {
  /// Creates new [WatchSingleProgramUseCase]
  new({required this._programRepository});

  final IProgramRepository _programRepository;

  @override
  Stream<AppResult<Program>> call(String params) {
    logDebug('start watching single program', extra: {'id': params});
    return _programRepository.watchSingle(params);
  }
}
