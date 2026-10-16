import 'package:equatable/equatable.dart';
import 'package:sistem_admin/academic_calendar/domain/entities.dart';

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
