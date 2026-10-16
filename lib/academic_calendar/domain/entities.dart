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

  @override
  List<Object?> get props => [
    id,
    academicYearId,
    name,
    startDate,
    endDate,
  ];
}
