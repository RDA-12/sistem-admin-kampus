import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/cohort/domain/entities.dart';
import 'package:sistem_admin/cohort/domain/repository.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

/// Params for creating a [Cohort]
final class CreateCohortParams extends Equatable {
  /// Creates new [CreateCohortParams]
  const new({
    required this.name,
    required this.entryYear,
  });

  /// Name of the cohort
  final String name;

  /// Entry year of the cohort
  final int entryYear;

  @override
  List<Object?> get props => [name, entryYear];
}

/// Use case for creating new [Cohort]
@LazySingleton(env: [Environment.prod])
class CreateCohortUseCase
    with AppLoggerMixin
    implements FutureBaseUseCase<CreateCohortParams, Cohort> {
  /// Creates new [CreateCohortUseCase]
  new({required this._cohortRepository});

  final ICohortRepository _cohortRepository;

  /// Run creating new [Cohort]
  @override
  Future<AppResult<Cohort>> call(CreateCohortParams params) async {
    logDebug(
      'start creating cohort',
      extra: {
        'name': params.name,
        'entryYear': params.entryYear,
      },
    );
    final result = await _cohortRepository.save(params);
    switch (result) {
      case AppSuccess(:final data):
        logDebug('cohort created');
        return AppResult.success(data);
      case AppFailure<Cohort>(:final exception):
        logDebug('cohort creation failed');
        return AppResult.failure(exception);
    }
  }
}
