import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/academic_calendar/domain/entities.dart';
import 'package:sistem_admin/academic_calendar/domain/filters/academic_term_filter.dart';
import 'package:sistem_admin/academic_calendar/domain/repository.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

/// Params for creating an [AcademicTerm]
final class CreateAcademicTermParams extends Equatable {
  /// Creates new [CreateAcademicTermParams]
  const new({
    required this.academicYearId,
    required this.name,
    required this.startDate,
    required this.endDate,
  });

  /// ID of the parent academic year
  final String academicYearId;

  /// Name of the academic term
  final String name;

  /// Start date of the academic term
  final DateTime startDate;

  /// End date of the academic term
  final DateTime endDate;

  @override
  List<Object?> get props => [
    academicYearId,
    name,
    startDate,
    endDate,
  ];
}

/// Use case for creating new [AcademicTerm]
@LazySingleton(env: [Environment.prod])
class CreateAcademicTermUseCase
    with AppLoggerMixin
    implements FutureBaseUseCase<CreateAcademicTermParams, AcademicTerm> {
  /// Creates new [CreateAcademicTermUseCase]
  new({
    required this._academicTermRepository,
    required this._academicYearRepository,
  });

  final IAcademicYearRepository _academicYearRepository;
  final IAcademicTermRepository _academicTermRepository;

  /// Run creating new [AcademicTerm]
  @override
  Future<AppResult<AcademicTerm>> call(CreateAcademicTermParams params) async {
    logDebug(
      'start getting academic year',
      extra: {'academicYearId': params.academicYearId},
    );
    late final AcademicYear year;
    final academicYearResult = await _academicYearRepository
        .watchSingle(
          params.academicYearId,
        )
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
        .watch(AcademicTermFilter(academicYearId: year.id))
        .first;
    switch (termsResult) {
      case AppFailure<List<AcademicTerm>>(:final exception):
        logDebug('failed to get terms');
        return AppResult.failure(exception);
      case AppSuccess<List<AcademicTerm>>(:final data):
        terms = data;
    }

    logDebug(
      'start checking whether new term can be added or not',
      extra: {
        'startDate': params.startDate,
        'endDate': params.endDate,
      },
    );
    final calendar = AcademicCalendar(year: year, terms: terms);
    final allowedResult = calendar.canAddTerm(
      startDate: params.startDate,
      endDate: params.endDate,
    );
    switch (allowedResult) {
      case AppFailure<Null>(:final exception):
        logDebug('failed to add new term');
        return AppResult.failure(exception);
      case AppSuccess<Null>():
    }

    logDebug(
      'new term allowed. start creating academic term',
      extra: {
        'academicYearId': params.academicYearId,
        'name': params.name,
        'startDate': params.startDate,
        'endDate': params.endDate,
      },
    );
    final result = await _academicTermRepository.save(params);
    switch (result) {
      case AppSuccess(:final data):
        logDebug('academic term created');
        return AppResult.success(data);
      case AppFailure<AcademicTerm>(:final exception):
        logDebug('academic term creation failed');
        return AppResult.failure(exception);
    }
  }
}
