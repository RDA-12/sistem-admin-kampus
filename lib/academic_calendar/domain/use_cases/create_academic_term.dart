import 'package:equatable/equatable.dart';
import 'package:sistem_admin/academic_calendar/domain/entities.dart';

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
