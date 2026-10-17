import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/academic_calendar/domain/entities.dart';
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
  new({required this._academicTermRepository});

  final IAcademicTermRepository _academicTermRepository;

  /// Run creating new [AcademicTerm]
  @override
  Future<AppResult<AcademicTerm>> call(CreateAcademicTermParams params) async {
    logDebug(
      'start creating academic term',
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
