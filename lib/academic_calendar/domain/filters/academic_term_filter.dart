import 'package:sistem_admin/academic_calendar/domain/entities.dart';
import 'package:sistem_admin/common/common.dart';

/// Filter criteria for querying [AcademicTerm]
final class AcademicTermFilter extends Filter {
  /// Creates new [AcademicTermFilter]
  const new({this.academicYearId});

  /// Optional academic year ID to filter academic terms by
  final String? academicYearId;

  @override
  List<Object?> get props => [academicYearId];
}
