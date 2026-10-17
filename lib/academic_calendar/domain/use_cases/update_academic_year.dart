import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/academic_calendar/domain/entities.dart';
import 'package:sistem_admin/academic_calendar/domain/repository.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

/// Params for updating an [AcademicYear]
final class UpdateAcademicYearParams extends Equatable {
  /// Creates new [UpdateAcademicYearParams]
  const new(
    this.academicYear, {
    this.name,
    this.startDate,
    this.endDate,
  });

  /// Academic year that will be updated
  final AcademicYear academicYear;

  /// Updated name
  final String? name;

  /// Updated start date
  final DateTime? startDate;

  /// Updated end date
  final DateTime? endDate;

  @override
  List<Object?> get props => [academicYear, name, startDate, endDate];
}

/// Use case for updating an [AcademicYear]
@LazySingleton(env: [Environment.prod])
class UpdateAcademicYearUseCase
    with AppLoggerMixin
    implements FutureBaseUseCase<UpdateAcademicYearParams, AcademicYear> {
  /// Creates new [UpdateAcademicYearUseCase]
  new({required this._academicYearRepository});

  final IAcademicYearRepository _academicYearRepository;

  @override
  Future<AppResult<AcademicYear>> call(UpdateAcademicYearParams params) async {
    logDebug(
      'start updating academic year',
      extra: {
        'id': params.academicYear.id,
        'name': params.name,
        'startDate': params.startDate,
        'endDate': params.endDate,
      },
    );
    final result = await _academicYearRepository.update(
      params.academicYear.id,
      args: params,
    );
    switch (result) {
      case AppSuccess(:final data):
        logDebug('academic year updated');
        return AppResult.success(data);
      case AppFailure<AcademicYear>(:final exception):
        logDebug('academic year update failed');
        return AppResult.failure(exception);
    }
  }
}
