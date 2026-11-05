import 'package:sistem_admin/academic_calendar/domain/entities.dart';
import 'package:sistem_admin/common/common.dart';

/// Filter criteria for querying [AcademicCalendarEvent]
final class AcademicCalendarEventFilter extends Filter {
  /// Creates new [AcademicCalendarEventFilter]
  const new({this.academicYearId});

  /// Optional academic year ID to filter academic calendar events by
  final String? academicYearId;

  @override
  List<Object?> get props => [academicYearId];
}
