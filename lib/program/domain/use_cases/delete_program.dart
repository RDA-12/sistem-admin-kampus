import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/program/domain/entities.dart';
import 'package:sistem_admin/program/domain/repository.dart';

/// Use case for deleting a Program
@LazySingleton(env: [Environment.prod])
class DeleteProgramUseCase with AppLoggerMixin
    implements FutureBaseUseCase<Program, Null> {
  /// Creates new [DeleteProgramUseCase]
  new({required this._programRepository});

  final IProgramRepository _programRepository;

  @override
  Future<AppResult<Null>> call(Program params) async {
    logDebug('start deleting program', extra: {'id': params.id});
    final result = await _programRepository.delete(params.id);
    switch (result) {
      case AppSuccess():
        logDebug('program deleted');
        return AppResult.success(null);
      case AppFailure<Null>(:final exception):
        logDebug('program deletion failed');
        return AppResult.failure(exception);
    }
  }
}
