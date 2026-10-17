import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/academic_calendar/domain/entities.dart';
import 'package:sistem_admin/academic_calendar/domain/repository.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

/// Params for creating an [AcademicYear]
final class CreateAcademicYearParams extends Equatable {
  /// Creates new [CreateAcademicYearParams]
  const new({
    required this.name,
    required this.startDate,
    required this.endDate,
  });

  /// Name of the academic year
  final String name;

  /// Start date of the academic year
  final DateTime startDate;

  /// End date of the academic year
  final DateTime endDate;

  @override
  List<Object?> get props => [name, startDate, endDate];
}

/// Use case for creating new [AcademicYear]
@LazySingleton(env: [Environment.prod])
class CreateAcademicYearUseCase
    with AppLoggerMixin
    implements FutureBaseUseCase<CreateAcademicYearParams, AcademicYear> {
  /// Creates new [CreateAcademicYearUseCase]
  new({required this._academicYearRepository});

  final IAcademicYearRepository _academicYearRepository;

  /// Run creating new [AcademicYear]
  @override
  Future<AppResult<AcademicYear>> call(CreateAcademicYearParams params) async {
    logDebug(
      'start creating academic year',
      extra: {
        'name': params.name,
        'startDate': params.startDate,
        'endDate': params.endDate,
      },
    );
    final result = await _academicYearRepository.save(params);
    switch (result) {
      case AppSuccess(:final data):
        logDebug('academic year created');
        return AppResult.success(data);
      case AppFailure<AcademicYear>(:final exception):
        logDebug('academic year creation failed');
        return AppResult.failure(exception);
    }
  }
}
