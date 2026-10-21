import 'package:injectable/injectable.dart';
import 'package:sistem_admin/cohort/domain/entities.dart';
import 'package:sistem_admin/cohort/domain/repository.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

/// Use case to watch for [Cohort] data changes
@LazySingleton(env: [Environment.prod])
class WatchCohortsUseCase
    with AppLoggerMixin
    implements StreamBaseUseCase<Null, List<Cohort>> {
  /// Creates new [WatchCohortsUseCase]
  new({required this._cohortRepository});

  final ICohortRepository _cohortRepository;

  @override
  Stream<AppResult<List<Cohort>>> call(Null params) {
    logDebug('start watching cohorts');
    return _cohortRepository.watch();
  }
}
