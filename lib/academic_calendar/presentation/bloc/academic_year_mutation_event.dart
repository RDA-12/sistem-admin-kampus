part of 'academic_year_mutation_bloc.dart';

/// Event for [AcademicYearMutationBloc]
sealed class AcademicYearMutationEvent extends Equatable {
  /// Creates new [AcademicYearMutationEvent]
  const new();
}

/// Event for updating an [AcademicYear]
final class AcademicYearMutationUpdateRequested
    extends AcademicYearMutationEvent {
  /// Creates new [AcademicYearMutationUpdateRequested]
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

/// Event for creating new [AcademicYear]
final class AcademicYearMutationCreateRequested
    extends AcademicYearMutationEvent {
  /// Creates new [AcademicYearMutationCreateRequested]
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

/// Event for deleting an [AcademicYear]
final class AcademicYearMutationDeleteRequested
    extends AcademicYearMutationEvent {
  /// Creates new [AcademicYearMutationDeleteRequested]
  const new({required this.academicYear});

  /// [AcademicYear] that will be deleted
  final AcademicYear academicYear;

  @override
  List<Object?> get props => [academicYear];
}
