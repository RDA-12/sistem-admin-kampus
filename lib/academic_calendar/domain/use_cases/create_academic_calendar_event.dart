import 'package:equatable/equatable.dart';
import 'package:sistem_admin/academic_calendar/domain/entities.dart';
import 'package:sistem_admin/common/common.dart';

/// Params for creating an [AcademicCalendarEvent]
final class CreateAcademicCalendarEventParams extends Equatable {
  /// Creates new [CreateAcademicCalendarEventParams]
  const new({
    required this.academicYearId,
    required this.name,
    required this.type,
    required this.start,
    required this.end,
    this.recurrence = const [],
  });

  /// ID of the parent academic year
  final String academicYearId;

  /// Name of the event
  final String name;

  /// Type of the event
  final AcademicCalendarEventType type;

  /// When the event start
  final EventDateTime start;

  /// When the event end
  final EventDateTime end;

  /// Recurrence rules (RFC5545)
  final List<String> recurrence;

  @override
  List<Object?> get props => [
    academicYearId,
    name,
    type,
    start,
    end,
    recurrence,
  ];
}
