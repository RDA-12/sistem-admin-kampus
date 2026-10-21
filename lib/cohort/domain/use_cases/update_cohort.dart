import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/cohort/domain/entities.dart';
import 'package:sistem_admin/cohort/domain/repository.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

/// Params for updating a [Cohort]
final class UpdateCohortParams extends Equatable {
  /// Creates new [UpdateCohortParams]
  const new(
    this.cohort, {
    this.name,
    this.entryYear,
  });

  /// Cohort that will be updated
  final Cohort cohort;

  /// Updated name
  final String? name;

  /// Updated entry year
  final int? entryYear;

  @override
  List<Object?> get props => [cohort, name, entryYear];
}

/// Use case for updating a [Cohort]
@LazySingleton(env: [Environment.prod])
class UpdateCohortUseCase
    with AppLoggerMixin
    implements FutureBaseUseCase<UpdateCohortParams, Cohort> {
  /// Creates new [UpdateCohortUseCase]
  new({required this._cohortRepository});

  final ICohortRepository _cohortRepository;

  @override
  Future<AppResult<Cohort>> call(UpdateCohortParams params) async {
    logDebug(
      'start updating cohort',
      extra: {
        'id': params.cohort.id,
        'name': params.name,
        'entryYear': params.entryYear,
      },
    );
    final result = await _cohortRepository.update(
      params.cohort.id,
      args: params,
    );
    switch (result) {
      case AppSuccess(:final data):
        logDebug('cohort updated');
        return AppResult.success(data);
      case AppFailure<Cohort>(:final exception):
        logDebug('cohort update failed');
        return AppResult.failure(exception);
    }
  }
}
