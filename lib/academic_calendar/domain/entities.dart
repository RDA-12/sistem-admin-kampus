import 'package:equatable/equatable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

/// Represent single Academic Year data
class AcademicYear extends Equatable {
  /// Creates new [AcademicYear]
  const new({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
  });

  /// ID of this academic year
  final String id;

  /// Name of this academic year
  final String name;

  /// Start date of this academic year
  final DateTime startDate;

  /// End date of this academic year
  final DateTime endDate;

  /// Returns whether [date] is within this academic year
  bool includes(DateTime date) {
    return !date.isBefore(startDate) && !date.isAfter(endDate);
  }

  @override
  List<Object?> get props => [id, name, startDate, endDate];
}

/// Represent single Academic Term data
class AcademicTerm extends Equatable {
  /// Creates new [AcademicTerm]
  const new({
    required this.id,
    required this.academicYearId,
    required this.name,
    required this.startDate,
    required this.endDate,
  });

  /// ID of this academic term
  final String id;

  /// ID of the parent academic year
  final String academicYearId;

  /// Name of this academic term
  final String name;

  /// Start date of this academic term
  final DateTime startDate;

  /// End date of this academic term
  final DateTime endDate;

  /// Return whether [startDate] and/or [endDate] overlap with
  /// this AcademicTerm
  bool overlapWith({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    if (startDate != null && endDate != null) {
      return !startDate.isAfter(this.endDate) &&
          !endDate.isBefore(this.startDate);
    }
    if (startDate != null) {
      return !startDate.isBefore(this.startDate) &&
          !startDate.isAfter(this.endDate);
    }
    if (endDate != null) {
      return !endDate.isBefore(this.startDate) &&
          !endDate.isAfter(this.endDate);
    }
    return false;
  }

  @override
  List<Object?> get props => [
    id,
    academicYearId,
    name,
    startDate,
    endDate,
  ];
}

/// Types of [AcademicCalendarEvent]
enum AcademicCalendarEventType {
  /// Type for holiday event
  holiday,

  /// Type for mid term test
  midTermTest,

  /// Type for final test
  finalTest,

  /// Type for general event
  general,

  /// Type for lecturing event
  lectures,
}

/// Representing single event on AcademicCalendar
class AcademicCalendarEvent extends Equatable {
  /// Creates new [AcademicCalendarEvent]
  const new({
    required this.id,
    required this.academicYearId,
    required this.name,
    required this.type,
    required this.start,
    required this.end,
    this.recurrence = const [],
  });

  /// ID of the event
  final String id;

  /// Academic year this event belong to
  final String academicYearId;

  /// Name of the event
  final String name;

  /// Type of the event
  final AcademicCalendarEventType type;

  /// When the event start
  final EventDateTime start;

  /// When the event end
  final EventDateTime end;

  /// List of RRULE, EXRULE, RDATE and EXDATE lines for a recurring event,
  /// as specified in RFC5545.
  ///
  /// It will omit DTSTART and DTEND as it will use [start] and [end]
  final List<String> recurrence;

  @override
  List<Object?> get props => [
    id,
    academicYearId,
    name,
    type,
    start,
    end,
    recurrence,
  ];
}

/// Represent an academic calendar for [year], its [terms], and its [events]
class AcademicCalendar extends Equatable {
  /// Creates new [AcademicCalendar]
  const new({
    required this.year,
    this.terms = const [],
    this.events = const [],
  });

  /// Year for this calendar
  final AcademicYear year;

  /// Terms within [year]
  final List<AcademicTerm> terms;

  /// Events within [year]
  final List<AcademicCalendarEvent> events;

  /// Whether new term can be added to this calendar based on
  /// [startDate] and [endDate]
  AppResult<Null> canAddTerm({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!year.includes(startDate) || !year.includes(endDate)) {
      return AppResult.failure(
        const AppException(
          'term date is outside academic year',
          code: .academicTermOutsideYear,
        ),
      );
    }
    for (final term in terms) {
      final overlapped = term.overlapWith(
        startDate: startDate,
        endDate: endDate,
      );
      if (overlapped) {
        return AppResult.failure(
          const AppException(
            'term overlapped with existing term',
            code: .academicTermOverlapped,
          ),
        );
      }
    }
    return AppResult.success(null);
  }

  /// Whether an existing term can be updated in this calendar based on
  /// [startDate] and [endDate]
  AppResult<Null> canUpdateTerm({
    required AcademicTerm term,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!year.includes(startDate) || !year.includes(endDate)) {
      return AppResult.failure(
        const AppException(
          'term date is outside academic year',
          code: .academicTermOutsideYear,
        ),
      );
    }
    for (final existingTerm in terms) {
      if (existingTerm.id == term.id) {
        continue;
      }
      final overlapped = existingTerm.overlapWith(
        startDate: startDate,
        endDate: endDate,
      );
      if (overlapped) {
        return AppResult.failure(
          const AppException(
            'term overlapped with existing term',
            code: .academicTermOverlapped,
          ),
        );
      }
    }
    return AppResult.success(null);
  }

  /// Whether new event can be added to this calendar based on
  /// [startDate] and [endDate]
  AppResult<Null> canAddEvent({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!year.includes(startDate) || !year.includes(endDate)) {
      return AppResult.failure(
        const AppException(
          'event date is outside academic year',
          code: .academicCalendarEventOutsideYear,
        ),
      );
    }
    return AppResult.success(null);
  }

  /// Whether an existing event can be updated in this calendar based on
  /// [startDate] and [endDate]
  AppResult<Null> canUpdateEvent({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!year.includes(startDate) || !year.includes(endDate)) {
      return AppResult.failure(
        const AppException(
          'event date is outside academic year',
          code: .academicCalendarEventOutsideYear,
        ),
      );
    }
    return AppResult.success(null);
  }

  @override
  List<Object?> get props => [year, terms, events];
}
