part of 'academic_calendar_mutation_bloc.dart';

/// Event for [AcademicCalendarMutationBloc]
sealed class AcademicCalendarMutationEvent extends Equatable {
  /// Creates new [AcademicCalendarMutationEvent]
  const new();
}

/// Event for creating new [AcademicYear]
final class AcademicCalendarYearCreateRequested
    extends AcademicCalendarMutationEvent {
  /// Creates new [AcademicCalendarYearCreateRequested]
  const new({
    required this.name,
    required this.startDate,
    required this.endDate,
  });

  /// Name for new [AcademicYear]
  final String name;

  /// Start date for new [AcademicYear]
  final DateTime startDate;

  /// End date for new [AcademicYear]
  final DateTime endDate;

  @override
  List<Object?> get props => [name, startDate, endDate];
}

/// Event for updating an [AcademicYear]
final class AcademicCalendarYearUpdateRequested
    extends AcademicCalendarMutationEvent {
  /// Creates new [AcademicCalendarYearUpdateRequested]
  const new({
    required this.academicYear,
    this.name,
    this.startDate,
    this.endDate,
  });

  /// [AcademicYear] that will be updated
  final AcademicYear academicYear;

  /// New name for [academicYear]
  final String? name;

  /// New start date for [academicYear]
  final DateTime? startDate;

  /// New end date for [academicYear]
  final DateTime? endDate;

  @override
  List<Object?> get props => [academicYear, name, startDate, endDate];
}

/// Event for deleting an [AcademicYear]
final class AcademicCalendarYearDeleteRequested
    extends AcademicCalendarMutationEvent {
  /// Creates new [AcademicCalendarYearDeleteRequested]
  const new({required this.academicYear});

  /// [AcademicYear] that will be deleted
  final AcademicYear academicYear;

  @override
  List<Object?> get props => [academicYear];
}

/// Event for creating new [AcademicTerm]
final class AcademicCalendarTermCreateRequested
    extends AcademicCalendarMutationEvent {
  /// Creates new [AcademicCalendarTermCreateRequested]
  const new({
    required this.academicYearId,
    required this.name,
    required this.startDate,
    required this.endDate,
  });

  /// Academic year ID for new [AcademicTerm]
  final String academicYearId;

  /// Name for new [AcademicTerm]
  final String name;

  /// Start date for new [AcademicTerm]
  final DateTime startDate;

  /// End date for new [AcademicTerm]
  final DateTime endDate;

  @override
  List<Object?> get props => [academicYearId, name, startDate, endDate];
}

/// Event for updating an [AcademicTerm]
final class AcademicCalendarTermUpdateRequested
    extends AcademicCalendarMutationEvent {
  /// Creates new [AcademicCalendarTermUpdateRequested]
  const new({
    required this.academicTerm,
    this.academicYearId,
    this.name,
    this.startDate,
    this.endDate,
  });

  /// [AcademicTerm] that will be updated
  final AcademicTerm academicTerm;

  /// New academic year ID for [academicTerm]
  final String? academicYearId;

  /// New name for [academicTerm]
  final String? name;

  /// New start date for [academicTerm]
  final DateTime? startDate;

  /// New end date for [academicTerm]
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

/// Event for deleting an [AcademicTerm]
final class AcademicCalendarTermDeleteRequested
    extends AcademicCalendarMutationEvent {
  /// Creates new [AcademicCalendarTermDeleteRequested]
  const new({required this.academicTerm});

  /// [AcademicTerm] that will be deleted
  final AcademicTerm academicTerm;

  @override
  List<Object?> get props => [academicTerm];
}

/// Event for creating new [AcademicCalendarEvent]
final class AcademicCalendarEventCreateRequested
    extends AcademicCalendarMutationEvent {
  /// Creates new [AcademicCalendarEventCreateRequested]
  const new({
    required this.academicYearId,
    required this.name,
    required this.type,
    required this.start,
    required this.end,
    this.recurrence = const [],
  });

  /// Academic year ID for new [AcademicCalendarEvent]
  final String academicYearId;

  /// Name for new [AcademicCalendarEvent]
  final String name;

  /// Type for new [AcademicCalendarEvent]
  final AcademicCalendarEventType type;

  /// Start date and time for new [AcademicCalendarEvent]
  final EventDateTime start;

  /// End date and time for new [AcademicCalendarEvent]
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

/// Event for updating an [AcademicCalendarEvent]
final class AcademicCalendarEventUpdateRequested
    extends AcademicCalendarMutationEvent {
  /// Creates new [AcademicCalendarEventUpdateRequested]
  const new({
    required this.event,
    this.academicYearId,
    this.name,
    this.type,
    this.start,
    this.end,
    this.recurrence,
  });

  /// [AcademicCalendarEvent] that will be updated
  final AcademicCalendarEvent event;

  /// New academic year ID for [event]
  final String? academicYearId;

  /// New name for [event]
  final String? name;

  /// New type for [event]
  final AcademicCalendarEventType? type;

  /// New start date and time for [event]
  final EventDateTime? start;

  /// New end date and time for [event]
  final EventDateTime? end;

  /// New recurrence rules for [event]
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

/// Event for deleting an [AcademicCalendarEvent]
final class AcademicCalendarEventDeleteRequested
    extends AcademicCalendarMutationEvent {
  /// Creates new [AcademicCalendarEventDeleteRequested]
  const new({required this.event});

  /// [AcademicCalendarEvent] that will be deleted
  final AcademicCalendarEvent event;

  @override
  List<Object?> get props => [event];
}
