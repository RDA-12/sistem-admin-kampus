import 'package:equatable/equatable.dart';
import 'package:sistem_admin/academic_calendar/domain/entities.dart';
import 'package:sistem_admin/common/common.dart';

/// Params for updating an [AcademicCalendarEvent]
final class UpdateAcademicCalendarEventParams extends Equatable {
  /// Creates new [UpdateAcademicCalendarEventParams]
  const new(
    this.event, {
    this.academicYearId,
    this.name,
    this.type,
    this.start,
    this.end,
    this.recurrence,
  });

  /// Event that will be updated
  final AcademicCalendarEvent event;

  /// Updated parent academic year ID
  final String? academicYearId;

  /// Updated name
  final String? name;

  /// Updated type
  final AcademicCalendarEventType? type;

  /// Updated start date and time
  final EventDateTime? start;

  /// Updated end date and time
  final EventDateTime? end;

  /// Updated recurrence rules
  final List<String>? recurrence;

  @override
  List<Object?> get props => [
    event,
    academicYearId,
    name,
    type,
    start,
    end,
    recurrence,
  ];
}
