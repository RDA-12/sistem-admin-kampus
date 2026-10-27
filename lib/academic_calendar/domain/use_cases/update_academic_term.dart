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
  new({
    required this._academicTermRepository,
    required this._academicYearRepository,
  });

  final IAcademicYearRepository _academicYearRepository;
  final IAcademicTermRepository _academicTermRepository;

  @override
  Future<AppResult<AcademicTerm>> call(UpdateAcademicTermParams params) async {
    final academicYearId =
        params.academicYearId ?? params.academicTerm.academicYearId;
    final startDate = params.startDate ?? params.academicTerm.startDate;
    final endDate = params.endDate ?? params.academicTerm.endDate;

    logDebug(
      'start getting academic year',
      extra: {'academicYearId': academicYearId},
    );
    late final AcademicYear year;
    final academicYearResult = await _academicYearRepository
        .watchSingle(academicYearId)
        .first;
    switch (academicYearResult) {
      case AppFailure<AcademicYear>(:final exception):
        logDebug('failed to get academic year');
        return AppResult.failure(exception);
      case AppSuccess<AcademicYear>(:final data):
        year = data;
    }

    logDebug('start getting existing terms from year');
    late final List<AcademicTerm> terms;
    final termsResult = await _academicTermRepository
        .watchByAcademicYear(year.id)
        .first;
    switch (termsResult) {
      case AppFailure<List<AcademicTerm>>(:final exception):
        logDebug('failed to get terms');
        return AppResult.failure(exception);
      case AppSuccess<List<AcademicTerm>>(:final data):
        terms = data;
    }

    logDebug(
      'start checking whether term can be updated or not',
      extra: {
        'startDate': startDate,
        'endDate': endDate,
      },
    );
    final calendar = AcademicCalendar(year: year, terms: terms);
    final allowed = calendar.canUpdateTerm(
      term: params.academicTerm,
      startDate: startDate,
      endDate: endDate,
    );
    if (!allowed) {
      logDebug(
        'updated term overlapped with existing terms. '
        'failed to update academic term',
      );
      return AppResult.failure(
        const AppException(
          'updated term overlapped with existing term',
          code: .academicTermOverlapped,
        ),
      );
    }

    logDebug(
      'term update allowed. start updating academic term',
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
