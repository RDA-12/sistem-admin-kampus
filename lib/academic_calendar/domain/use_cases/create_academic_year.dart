import 'package:equatable/equatable.dart';
import 'package:sistem_admin/academic_calendar/domain/entities.dart';

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
