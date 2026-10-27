import 'package:equatable/equatable.dart';

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

/// Represent an academic calendar for [year] and its [terms]
class AcademicCalendar extends Equatable {
  /// Creates new [AcademicCalendar]
  const new({
    required this.year,
    required this.terms,
  });

  /// Year for this calendar
  final AcademicYear year;

  /// Terms within [year]
  final List<AcademicTerm> terms;

  /// Whether new term can be added to this calendar based on
  /// [startDate] and [endDate]
  bool canAddNewTerm({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    for (final term in terms) {
      final overlapped = term.overlapWith(
        startDate: startDate,
        endDate: endDate,
      );
      if (overlapped) {
        return false;
      }
    }
    return true;
  }

  /// Whether an existing term can be updated in this calendar based on
  /// [startDate] and [endDate]
  bool canUpdateTerm({
    required AcademicTerm term,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    for (final existingTerm in terms) {
      if (existingTerm.id == term.id) {
        continue;
      }
      final overlapped = existingTerm.overlapWith(
        startDate: startDate,
        endDate: endDate,
      );
      if (overlapped) {
        return false;
      }
    }
    return true;
  }

  @override
  List<Object?> get props => [year, terms];
}
