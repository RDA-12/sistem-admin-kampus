import 'package:injectable/injectable.dart';
import 'package:sistem_admin/cohort/domain/entities.dart';
import 'package:sistem_admin/cohort/domain/repository.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

/// Use case for deleting a [Cohort]
@LazySingleton(env: [Environment.prod])
class DeleteCohortUseCase
    with AppLoggerMixin
    implements FutureBaseUseCase<Cohort, Null> {
  /// Creates new [DeleteCohortUseCase]
  new({required this._cohortRepository});

  final ICohortRepository _cohortRepository;

  @override
  Future<AppResult<Null>> call(Cohort params) async {
    logDebug('start deleting cohort', extra: {'id': params.id});
    final result = await _cohortRepository.delete(params.id);
    switch (result) {
      case AppSuccess():
        logDebug('cohort deleted');
        return AppResult.success(null);
      case AppFailure<Null>(:final exception):
        logDebug('cohort deletion failed');
        return AppResult.failure(exception);
    }
  }
}
