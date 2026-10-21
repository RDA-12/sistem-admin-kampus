import 'package:injectable/injectable.dart';
import 'package:sistem_admin/cohort/domain/entities.dart';
import 'package:sistem_admin/cohort/domain/repository.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

/// Use case for watching single [Cohort] data changes
@LazySingleton(env: [Environment.prod])
class WatchSingleCohortUseCase
    with AppLoggerMixin
    implements StreamBaseUseCase<String, Cohort> {
  /// Creates new [WatchSingleCohortUseCase]
  new({required this._cohortRepository});

  final ICohortRepository _cohortRepository;

  @override
  Stream<AppResult<Cohort>> call(String params) {
    logDebug('start watching single cohort', extra: {'id': params});
    return _cohortRepository.watchSingle(params);
  }
}
