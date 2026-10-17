import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/academic_calendar/domain/entities.dart';
import 'package:sistem_admin/academic_calendar/domain/repository.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

/// Params for updating an [AcademicTerm]
final class UpdateAcademicTermParams extends Equatable {
  /// Creates new [UpdateAcademicTermParams]
  const new(
    this.academicTerm, {
    this.academicYearId,
    this.name,
    this.startDate,
    this.endDate,
  });

  /// Academic term that will be updated
  final AcademicTerm academicTerm;

  /// Updated parent academic year ID
  final String? academicYearId;

  /// Updated name
  final String? name;

  /// Updated start date
  final DateTime? startDate;

  /// Updated end date
  final DateTime? endDate;

  @override
  List<Object?> get props => [
    academicTerm,
    academicYearId,
    name,
    startDate,
    endDate,
  ];
}

/// Use case for updating an [AcademicTerm]
@LazySingleton(env: [Environment.prod])
class UpdateAcademicTermUseCase
    with AppLoggerMixin
    implements FutureBaseUseCase<UpdateAcademicTermParams, AcademicTerm> {
  /// Creates new [UpdateAcademicTermUseCase]
  new({required this._academicTermRepository});

  final IAcademicTermRepository _academicTermRepository;

  @override
  Future<AppResult<AcademicTerm>> call(UpdateAcademicTermParams params) async {
    logDebug(
      'start updating academic term',
      extra: {
        'id': params.academicTerm.id,
        'academicYearId': params.academicYearId,
        'name': params.name,
        'startDate': params.startDate,
        'endDate': params.endDate,
      },
    );
    final result = await _academicTermRepository.update(
      params.academicTerm.id,
      args: params,
    );
    switch (result) {
      case AppSuccess(:final data):
        logDebug('academic term updated');
        return AppResult.success(data);
      case AppFailure<AcademicTerm>(:final exception):
        logDebug('academic term update failed');
        return AppResult.failure(exception);
    }
  }
}
