import 'package:equatable/equatable.dart';
import 'package:sistem_admin/academic_calendar/domain/entities.dart';

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
